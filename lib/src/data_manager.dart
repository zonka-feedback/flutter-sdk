import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:zonkafeedback_sdk/src/session_database/sessions.dart';
import 'package:zonkafeedback_sdk/src/sharedpreference/preference_manager.dart';
import 'package:zonkafeedback_sdk/src/utils/app_util.dart';
import '../zonka_sdk.dart';
import 'constant.dart';
import 'model/contact_response/contact_response.dart';
import 'model/session_request_model/session_log.dart';
import 'model/session_request_model/update_session_request.dart';
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

  Future<void> hitSurveyActiveApi(String token) async {
    await clearExcludedList();
    await clearIncludeList();
    await clearIncludeType();
    await clearExcludeType();
    await clearPageDelay();

    try {
      final widget = await _apiManager.hitSurveyActiveApi(token);

      if (widget?.data?.distributionInfo?.embedSettings != null) {
        ExcludeSegment? excludeSegment =
            widget?.data?.distributionInfo?.embedSettings?.excludeSegment;
        IncludeSegment? includeSegment =
            widget?.data?.distributionInfo?.embedSettings?.includeSegment;

        await saveExcludeType(excludeSegment?.type ?? "");
        await saveIncludeType(includeSegment?.type ?? "");

        await savePageDelay(
            widget?.data?.distributionInfo?.embedSettings?.trigger?.after ?? 0);

        if (excludeSegment?.list?.isNotEmpty ?? false) {
          saveExcludedList(excludeSegment!.list!);
        } else if (includeSegment?.list?.isNotEmpty ?? false) {
          saveIncludedList(includeSegment!.list!);
        } else {
          // If both are empty, still saving empty lists
          saveExcludedList(excludeSegment?.list ?? []);
          saveIncludedList(includeSegment?.list ?? []);
        }
      }

      DataManager().setWidgetActivity(
          widget?.data?.distributionInfo?.isWidgetActive ?? false);
      DataManager()
          .setCompanyId(widget?.data?.distributionInfo?.companyId ?? "");
    } on DioException catch (error) {
      // Handle Dio errors
      debugPrint("DioException: $error");
    } catch (e) {
      // Handle other types of errors
      debugPrint("Unexpected error: $e");
    }
  }

  Future<void> createContactForDynamicAttribute(
    Map<String, dynamic> hashMapData,
    String token,
    bool isContactCreated,
  ) async {
    Map<String, String> hashMap = {
      Constant.cookieId: getCookieId(),
      Constant.firstSeen: getFirstSeen(),
      Constant.requestType: 'ANDROID',
      Constant.lastSeen: AppUtils.instance.getCurrentTime(
        DateTime.now().millisecondsSinceEpoch,
        'yyyy-MM-dd HH:mm:ss',
      ),
      Constant.ipAddress: await AppUtils.instance.getLocalIpAddress(),
    };

    if (getContactId().isNotEmpty) {
      hashMap[Constant.contactId] = getContactId();
    } else {
      if (getExternalVisitorId().isNotEmpty) {
        hashMap[Constant.externalVisitorId] = getExternalVisitorId();
      }
    }

    if (getEmailId().isNotEmpty) {
      hashMap[Constant.emailId] = getEmailId();
    }

    if (getContactName().isNotEmpty) {
      hashMap[Constant.contactName] = getContactName();
    }

    if (getMobileNo().isNotEmpty) {
      hashMap[Constant.mobileNo] = getMobileNo();
    }

    if (getUniqueId().isNotEmpty) {
      hashMap[Constant.uniqueId] = getUniqueId();
    }

    hashMap.addAll({
      Constant.uniqueRefCode: token,
      Constant.jobType: 'sdktd',
      Constant.companyId: DataManager().getCompanyID(),
      Constant.contactDeviceOs: Constant.android,
      Constant.contactDeviceName: await _zonkaSdkPlugin.getModelName() ?? "",
      Constant.contactDeviceModel: await _zonkaSdkPlugin.getModelName() ?? "",
      Constant.contactDeviceBrand: await _zonkaSdkPlugin.getBrandName() ?? "",
      Constant.contactDeviceOsVersion:
          await _zonkaSdkPlugin.getPlatformVersion() ?? "",
      Constant.contactDevice: (await _zonkaSdkPlugin.getIsTablet()).toString(),
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
      deviceType: Platform.isIOS ? Constant.ios : Constant.android,
    );

    String contactIdValue = getContactId();
    List<SessionLog> sessionLogList = [];
    for (int i = 0; i < sessionList.length; i++) {
      if (sessionList[i].endTime != 0 && sessionList[i].startTime != 0) {
        SessionLog sessionLog = SessionLog(
          sessionStartedAt: AppUtils.instance
              .getCurrentTime(sessionList[i].startTime, Constant.dateFormat),
          sessionClosedAt: AppUtils.instance
              .getCurrentTime(sessionList[i].endTime, Constant.dateFormat),
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
    PreferenceManager().putLong(Constant.sessionEndTime, sessionEndTime);
  }

  void setWidgetActivity(bool isWidgetActive) {
    PreferenceManager().putBoolean(Constant.isWidgetActive, isWidgetActive);
  }

  void setCompanyId(String companyId) {
    PreferenceManager().putString(Constant.companyId, companyId);
  }

  void saveFirstSeen() {
    if (getFirstSeen().isEmpty) {
      int firstSeenTimeStamp = DateTime.now().millisecond;
      String firstSeen = AppUtils.instance
          .getCurrentTime(firstSeenTimeStamp, "yyyy-MM-dd HH:mm:ss");
      PreferenceManager().putString(Constant.userFirstSeen, firstSeen);
    }
  }

  void saveCookieId() {
    if (getCookieId().isNotEmpty) {
      String cookieId = AppUtils.instance.getCookieId(24);
      PreferenceManager().putString(Constant.cookieId, "ad-$cookieId");
    }
  }

  Future<void> saveContactId(String contactId) async {
    await PreferenceManager().putString(Constant.contactId, contactId);
  }

  Future<void> saveExternalVisitorId(String evd) async {
    await PreferenceManager().putString(Constant.externalVisitorId, evd);
  }

  Future<void> saveEmailId(String emailId) async {
    await PreferenceManager().putString(Constant.emailId, emailId);
  }

  Future<void> saveMobileNo(String mobileNo) async {
    await PreferenceManager().putString(Constant.mobileNo, mobileNo);
  }

  Future<void> saveUniqueId(String uniqueId) async {
    await PreferenceManager().putString(Constant.uniqueId, uniqueId);
  }

  Future<void> saveRegion(String zfRegion) async {
    await PreferenceManager().putString(Constant.zfRegion, zfRegion);
  }

  Future<void> saveContactName(String contactName) async {
    await PreferenceManager().putString(Constant.contactName, contactName);
  }

  bool isWidgetActive() {
    return PreferenceManager().getBoolean(Constant.isWidgetActive, false);
  }

  String getCompanyID() {
    return PreferenceManager().getString(Constant.companyId, "");
  }

  int getSessionEndTime() {
    return PreferenceManager().getLong(Constant.sessionEndTime);
  }

  String getFirstSeen() {
    return PreferenceManager().getString(Constant.userFirstSeen, "");
  }

  String getCookieId() {
    return PreferenceManager().getString(Constant.cookieId, "");
  }

  String getContactId() {
    return PreferenceManager().getString(Constant.contactId, "");
  }

  String getExternalVisitorId() {
    return PreferenceManager().getString(Constant.externalVisitorId, "");
  }

  String getEmailId() {
    return PreferenceManager().getString(Constant.emailId, "");
  }

  String getMobileNo() {
    // String encryptValue = EncryptionService().encryptData(PreferenceManager().getString(Constant.mobileNo, ""));
    // return encryptValue;

    return PreferenceManager().getString(Constant.mobileNo, "");
  }

  String getUniqueId() {
    return PreferenceManager().getString(Constant.uniqueId, "");
  }

  String getRegion() {
    return PreferenceManager().getString(Constant.zfRegion, "");
  }

  String getContactName() {
    return PreferenceManager().getString(Constant.contactName, "");
  }

  Future<void> saveContactList(List<String> lists) async {
    PreferenceManager().putStringList(Constant.contactList, lists);
  }

  List<String>? getContactList() {
    return PreferenceManager().getStringList(Constant.contactList, null);
  }

  void saveExcludedList(List<String> lists) {
    PreferenceManager().putStringList(Constant.excludedList, lists);
  }

  Future<void> clearExcludedList() async {
    await PreferenceManager().putStringList(Constant.excludedList, []);
  }

  List<String>? getExcludedList() {
    return PreferenceManager().getStringList(Constant.excludedList, null);
  }

  void saveIncludedList(List<String> lists) {
    PreferenceManager().putStringList(Constant.includedList, lists);
  }

  List<String>? getIncludedList() {
    return PreferenceManager().getStringList(Constant.includedList, null);
  }

  Future<void> clearIncludeList() async {
    await PreferenceManager().putStringList(Constant.includedList, []);
  }

  Future<void> clearIncludeType() async {
    await PreferenceManager().putString(Constant.includeType, "");
  }

  Future<void> clearExcludeType() async {
    await PreferenceManager().putString(Constant.excludeType, "");
  }

  Future<void> saveExcludeType(String type) async {
    await PreferenceManager().putString(Constant.excludeType, type);
  }

  Future<void> saveIncludeType(String type) async {
    await PreferenceManager().putString(Constant.includeType, type);
  }

  String getExcludeType() {
    return PreferenceManager().getString(Constant.excludeType, "");
  }

  String getIncludeType() {
    return PreferenceManager().getString(Constant.includeType, "");
  }

  /// Seconds to wait before showing the survey, from
  /// `embedSettings.trigger.after`. Negative values are stored as 0; no upper
  /// bound is applied, because the server does not cap the field either.
  Future<void> savePageDelay(int seconds) async {
    await PreferenceManager()
        .putLong(Constant.pageDelaySeconds, seconds < 0 ? 0 : seconds);
  }

  int getPageDelay() {
    return PreferenceManager().getLong(Constant.pageDelaySeconds);
  }

  Future<void> clearPageDelay() async {
    await PreferenceManager().putLong(Constant.pageDelaySeconds, 0);
  }

  void saveEvdList(List<String> lists) {
    PreferenceManager().putStringList(Constant.evdList, lists);
  }

  List<String>? getEvdList() {
    return PreferenceManager().getStringList(Constant.evdList, null);
  }

  void clearPreference() {
    if (getRegion().isNotEmpty) {
      zfRegion = getRegion();
    }
    PreferenceManager().clearAllPrefs();
    saveRegion(zfRegion);
  }
}
