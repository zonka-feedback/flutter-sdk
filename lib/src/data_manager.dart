import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
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

    try {
      final widget = await _apiManager.hitSurveyActiveApi(token);

      if (widget?.data?.distributionInfo?.embedSettings != null) {
        ExcludeSegment? excludeSegment =
            widget?.data?.distributionInfo?.embedSettings?.excludeSegment;
        IncludeSegment? includeSegment =
            widget?.data?.distributionInfo?.embedSettings?.includeSegment;

        await saveExcludeType(excludeSegment?.type ?? "");
        await saveIncludeType(includeSegment?.type ?? "");

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
      print("DioException: $error");
    } catch (e) {
      // Handle other types of errors
      print("Unexpected error: $e");
    }
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
