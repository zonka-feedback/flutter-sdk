import 'dart:core';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:zonkafeedback_sdk/src/session_database/sessions.dart';
import 'package:zonkafeedback_sdk/src/sharedpreference/preference_manager.dart';
import 'package:zonkafeedback_sdk/src/utils/app_util.dart';
import '../zonka_sdk.dart';
import 'constant.dart';
import 'model/contact_response/contact_response.dart';
import 'model/session_request_model/session_log.dart';
import 'model/session_request_model/update_session_request.dart';
import 'model/token_validation.dart';
import 'model/widget_response/distribution_info.dart';
import 'model/widget_response/embed_settings.dart';
import 'model/widget_response/include_segment.dart';
import 'network/api_manager.dart';
import 'network/api_response_callback.dart';
import 'model/widget_response/exclude_segment.dart';

class DataManager {
  late ApiManager _apiManager;
  String zfRegion = "";
  late ApiResponseCallbacks _callbacks;

  static final DataManager _dataManagerSingleton = DataManager._internal();

  final _zonkaSdkPlugin = ZonkaSdk();

  factory DataManager() {
    return _dataManagerSingleton;
  }

  DataManager._internal();

  Future<void> init() async {
    await PreferenceManager().init();
  }

  // Future<void> initMultipleToken(List<String>  token) async {
  //   await PreferenceManager().init(token);
  // }

  void initApiManager() {
    _apiManager = ApiManager.instance;
  }

  void setApiCallbacks(ApiResponseCallbacks callbacks) {
    _callbacks = callbacks;
  }

  /// Validates every token with one `distribution/validateCodes` request.
  ///
  /// Resolves to `null` when the request failed; no token can then be
  /// treated as valid.
  Future<List<TokenValidation>?> validateTokens(List<String> tokens) async {
    try {
      return await _apiManager.validateTokens(tokens);
    } catch (e) {
      if (kDebugMode) debugPrint('[ZF-SEG] validateCodes failed: $e');
      return null;
    }
  }

  /// Re-fetches the settings of a single [token] through `validateCodes`.
  /// Resolves to `false` when the server could not be reached, in which case
  /// the cached settings have been cleared and must not be treated as the
  /// server's answer.
  Future<bool> refreshToken(String token) async {
    final List<TokenValidation>? results = await validateTokens([token]);
    if (results == null) {
      await _clearDistributionSettings();
      return false;
    }

    final Iterable<TokenValidation> match =
        results.where((result) => result.token == token && result.valid);
    if (match.isEmpty) {
      await _clearDistributionSettings();
    } else {
      await applyValidDistribution(match.first.distributionInfo);
    }
    return true;
  }

  /// Makes [info], a distribution that `validateCodes` reported as valid, the
  /// one the segment check and the on-page delay read from.
  ///
  /// `validateCodes` has no `isWidgetActive`: a valid token is an active one,
  /// unless the field is present and says otherwise.
  Future<void> applyValidDistribution(DistributionInfo? info) async {
    await _clearDistributionSettings();
    await _saveDistributionSettings(info,
        widgetActive: info?.isWidgetActive ?? true);
  }

  /// The widget is reset to inactive too, so a validation that fails cannot
  /// leave an earlier token's active state behind.
  Future<void> _clearDistributionSettings() async {
    await clearExcludedList();
    await clearIncludeList();
    await clearIncludeType();
    await clearExcludeType();
    await clearPageDelay();
    setWidgetActivity(false);
  }

  Future<void> _saveDistributionSettings(DistributionInfo? info,
      {required bool widgetActive}) async {
    final EmbedSettings? embedSettings = info?.embedSettings;
    if (embedSettings != null) {
      final ExcludeSegment? excludeSegment = embedSettings.excludeSegment;
      final IncludeSegment? includeSegment = embedSettings.includeSegment;

      await saveExcludeType(excludeSegment?.type ?? "");
      await saveIncludeType(includeSegment?.type ?? "");
      await savePageDelay(embedSettings.trigger?.after ?? 0);

      // Both lists are kept: a distribution may include some segments and
      // exclude others at the same time.
      saveExcludedList(excludeSegment?.list ?? []);
      saveIncludedList(includeSegment?.list ?? []);
    }

    setWidgetActivity(widgetActive);
    setCompanyId(info?.companyId ?? "");
  }

  Future<void> createContactForDynamicAttribute(
    Map<String, dynamic> hashMapData,
    String token,
    bool isContactCreated,
  ) async {
    Map<String, String> hashMap = {
      Constant.COOKIE_ID: getCookieId(),
      Constant.FIRST_SEEN: getFirstSeen(),
      Constant.REQUEST_TYPE: 'ANDROID',
      Constant.LAST_SEEN: AppUtils.instance.getCurrentTime(
        DateTime.now().millisecondsSinceEpoch,
        'yyyy-MM-dd HH:mm:ss',
      ),
      Constant.IP_ADDRESS: await AppUtils.instance.getLocalIpAddress(),
    };

    if (getContactId().isNotEmpty) {
      hashMap[Constant.CONTACT_ID] = getContactId();
    } else {
      if (getExternalVisitorId().isNotEmpty) {
        hashMap[Constant.EXTERNAL_VISITOR_ID] = getExternalVisitorId();
      }
    }

    if (getEmailId().isNotEmpty) {
      hashMap[Constant.EMAIL_ID] = getEmailId();
    }

    if (getContactName().isNotEmpty) {
      hashMap[Constant.CONTACT_NAME] = getContactName();
    }

    if (getMobileNo().isNotEmpty) {
      hashMap[Constant.MOBILE_NO] = getMobileNo();
    }

    if (getUniqueId().isNotEmpty) {
      hashMap[Constant.UNIQUE_ID] = getUniqueId();
    }

    hashMap.addAll({
      Constant.UNIQUE_REF_CODE: token,
      Constant.JOB_TYPE: 'sdktd',
      Constant.COMPANY_ID: DataManager().getCompanyID(),
      Constant.CONTACT_DEVICE_OS: Constant.ANDROID,
      Constant.CONTACT_DEVICE_NAME: await _zonkaSdkPlugin.getModelName() ?? "",
      Constant.CONTACT_DEVICE_MODEL: await _zonkaSdkPlugin.getModelName() ?? "",
      Constant.CONTACT_DEVICE_BRAND: await _zonkaSdkPlugin.getBrandName() ?? "",
      Constant.CONTACT_DEVICE_OS_VERSION:
          await _zonkaSdkPlugin.getPlatformVersion() ?? "",
      Constant.CONTACT_DEVICE: (await _zonkaSdkPlugin.getIsTablet()).toString(),
    });

    hashMapData.addAll(hashMap);

    ContactResponse contactResponse =
        await ApiManager().hitCreateContactApiDynamic(hashMapData);

    if (kDebugMode) {
      debugPrint('[ZF-SEG] contact token=$token'
          ' id=${contactResponse.data?.contactInfo?.id}'
          ' lists=${contactResponse.data?.contactInfo?.lists}');
    }

    if (contactResponse.data != null) {
      if (contactResponse.data?.contactInfo != null) {
        if (contactResponse.data!.contactInfo!.id!.isNotEmpty) {
          if (contactResponse.data!.contactInfo!.lists != null) {
            await saveContactList(contactResponse.data!.contactInfo!.lists!);
          }
          await saveContactId(contactResponse.data!.contactInfo!.id!);
          _callbacks.onContactCreationSuccess(isContactCreated);
        }
      }
    }
  }

  Future<void> updateSessionToServer(
      String token, List<Sessions> sessionList) async {
    UpdateSessionRequest sessionRequest = UpdateSessionRequest(
      deviceType: Platform.isIOS ? Constant.IOS : Constant.ANDROID,
    );

    String contactIdValue = getContactId();
    List<SessionLog> sessionLogList = [];
    for (int i = 0; i < sessionList.length; i++) {
      if (sessionList[i].endTime != 0 && sessionList[i].startTime != 0) {
        SessionLog sessionLog = SessionLog(
          sessionStartedAt: AppUtils.instance
              .getCurrentTime(sessionList[i].startTime, Constant.DATE_FORMAT),
          sessionClosedAt: AppUtils.instance
              .getCurrentTime(sessionList[i].endTime, Constant.DATE_FORMAT),
          uniqueSessId: sessionList[i].id,
          cookieId: getCookieId(),
          ipAddress: await AppUtils.instance.getLocalIpAddress(),
          contactId: contactIdValue,
        );
        sessionLogList.add(sessionLog);
      }
    }

    sessionRequest.sessionLogs = sessionLogList;
    _apiManager.updateSessionToServer(token, sessionRequest).then((value) {});
  }

  void setSessionEndTime(int sessionEndTime) {
    PreferenceManager().putLong(Constant.SESSION_END_TIME, sessionEndTime);
  }

  void setWidgetActivity(bool isWidgetActive) {
    PreferenceManager().putBoolean(Constant.IS_WIDGET_ACTIVE, isWidgetActive);
  }

  void setCompanyId(String companyId) {
    PreferenceManager().putString(Constant.COMPANY_ID, companyId);
  }

  void saveFirstSeen() {
    if (getFirstSeen().isEmpty) {
      int firstSeenTimeStamp = DateTime.now().millisecond;
      String firstSeen = AppUtils.instance
          .getCurrentTime(firstSeenTimeStamp, "yyyy-MM-dd HH:mm:ss");
      PreferenceManager().putString(Constant.USER_FIRST_SEEN, firstSeen);
    }
  }

  void saveCookieId() {
    if (getCookieId().isNotEmpty) {
      String cookieId = AppUtils.instance.getCookieId(24);
      PreferenceManager().putString(Constant.COOKIE_ID, "ad-$cookieId");
    }
  }

  Future<void> saveContactId(String contactId) async {
    await PreferenceManager().putString(Constant.CONTACT_ID, contactId);
  }

  Future<void> saveExternalVisitorId(String evd) async {
    await PreferenceManager().putString(Constant.EXTERNAL_VISITOR_ID, evd);
  }

  Future<void> saveEmailId(String emailId) async {
    await PreferenceManager().putString(Constant.EMAIL_ID, emailId);
  }

  Future<void> saveMobileNo(String mobileNo) async {
    await PreferenceManager().putString(Constant.MOBILE_NO, mobileNo);
  }

  Future<void> saveUniqueId(String uniqueId) async {
    await PreferenceManager().putString(Constant.UNIQUE_ID, uniqueId);
  }

  Future<void> saveRegion(String zfRegion) async {
    await PreferenceManager().putString(Constant.ZF_REGION, zfRegion);
  }

  Future<void> saveContactName(String contactName) async {
    await PreferenceManager().putString(Constant.CONTACT_NAME, contactName);
  }

  bool isWidgetActive() {
    return PreferenceManager().getBoolean(Constant.IS_WIDGET_ACTIVE, false);
  }

  String getCompanyID() {
    return PreferenceManager().getString(Constant.COMPANY_ID, "");
  }

  int getSessionEndTime() {
    return PreferenceManager().getLong(Constant.SESSION_END_TIME);
  }

  String getFirstSeen() {
    return PreferenceManager().getString(Constant.USER_FIRST_SEEN, "");
  }

  String getCookieId() {
    return PreferenceManager().getString(Constant.COOKIE_ID, "");
  }

  String getContactId() {
    return PreferenceManager().getString(Constant.CONTACT_ID, "");
  }

  String getExternalVisitorId() {
    return PreferenceManager().getString(Constant.EXTERNAL_VISITOR_ID, "");
  }

  String getEmailId() {
    return PreferenceManager().getString(Constant.EMAIL_ID, "");
  }

  String getMobileNo() {
    // String encryptValue = EncryptionService().encryptData(PreferenceManager().getString(Constant.MOBILE_NO, ""));
    // return encryptValue;

    return PreferenceManager().getString(Constant.MOBILE_NO, "");
  }

  String getUniqueId() {
    return PreferenceManager().getString(Constant.UNIQUE_ID, "");
  }

  String getRegion() {
    return PreferenceManager().getString(Constant.ZF_REGION, "");
  }

  String getContactName() {
    return PreferenceManager().getString(Constant.CONTACT_NAME, "");
  }

  Future<void> saveContactList(List<String> lists) async {
    PreferenceManager().putStringList(Constant.CONTACT_LIST, lists);
  }

  List<String>? getContactList() {
    return PreferenceManager().getStringList(Constant.CONTACT_LIST, null);
  }

  void saveExcludedList(List<String> lists) {
    PreferenceManager().putStringList(Constant.EXCLUDED_LIST, lists);
  }

  Future<void> clearExcludedList() async {
    await PreferenceManager().putStringList(Constant.EXCLUDED_LIST, []);
  }

  List<String>? getExcludedList() {
    return PreferenceManager().getStringList(Constant.EXCLUDED_LIST, null);
  }

  void saveIncludedList(List<String> lists) {
    PreferenceManager().putStringList(Constant.INCLUDED_LIST, lists);
  }

  List<String>? getIncludedList() {
    return PreferenceManager().getStringList(Constant.INCLUDED_LIST, null);
  }

  Future<void> clearIncludeList() async {
    await PreferenceManager().putStringList(Constant.INCLUDED_LIST, []);
  }

  Future<void> clearIncludeType() async {
    await PreferenceManager().putString(Constant.INCLUDE_TYPE, "");
  }

  Future<void> clearExcludeType() async {
    await PreferenceManager().putString(Constant.EXCLUDE_TYPE, "");
  }

  Future<void> saveExcludeType(String type) async {
    await PreferenceManager().putString(Constant.EXCLUDE_TYPE, type);
  }

  Future<void> saveIncludeType(String type) async {
    await PreferenceManager().putString(Constant.INCLUDE_TYPE, type);
  }

  String getExcludeType() {
    return PreferenceManager().getString(Constant.EXCLUDE_TYPE, "");
  }

  String getIncludeType() {
    return PreferenceManager().getString(Constant.INCLUDE_TYPE, "");
  }

  /// Seconds to wait before showing the survey, from
  /// `embedSettings.trigger.after`. Negative values are stored as 0; no upper
  /// bound is applied, because the server does not cap the field either.
  Future<void> savePageDelay(int seconds) async {
    await PreferenceManager()
        .putLong(Constant.PAGE_DELAY_SECONDS, seconds < 0 ? 0 : seconds);
  }

  int getPageDelay() {
    return PreferenceManager().getLong(Constant.PAGE_DELAY_SECONDS);
  }

  Future<void> clearPageDelay() async {
    await PreferenceManager().putLong(Constant.PAGE_DELAY_SECONDS, 0);
  }

  /// Records that the survey for [token] qualified and is due at [showAt].
  /// Persisted so the deadline survives backgrounding and process death.
  Future<void> savePendingSurvey(String token, DateTime showAt) async {
    await PreferenceManager().putString(Constant.PENDING_SURVEY_TOKEN, token);
    await PreferenceManager().putLong(
        Constant.PENDING_SURVEY_SHOW_AT, showAt.millisecondsSinceEpoch);
  }

  /// The survey waiting out its on-page delay, or `null` when there is none.
  PendingSurvey? getPendingSurvey() {
    final String token =
        PreferenceManager().getString(Constant.PENDING_SURVEY_TOKEN, "");
    if (token.isEmpty) return null;
    return PendingSurvey(
      token,
      DateTime.fromMillisecondsSinceEpoch(
          PreferenceManager().getLong(Constant.PENDING_SURVEY_SHOW_AT)),
    );
  }

  Future<void> clearPendingSurvey() async {
    await PreferenceManager().putString(Constant.PENDING_SURVEY_TOKEN, "");
    await PreferenceManager().putLong(Constant.PENDING_SURVEY_SHOW_AT, 0);
  }

  void saveEvdList(List<String> lists) {
    PreferenceManager().putStringList(Constant.EVD_LIST, lists);
  }

  List<String>? getEvdList() {
    return PreferenceManager().getStringList(Constant.EVD_LIST, null);
  }

  void clearPreference() {
    if (getRegion().isNotEmpty) {
      zfRegion = getRegion();
    }
    PreferenceManager().clearAllPrefs();
    saveRegion(zfRegion);
  }
}

class PendingSurvey {
  final String token;
  final DateTime showAt;

  const PendingSurvey(this.token, this.showAt);
}
