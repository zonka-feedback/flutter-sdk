import 'dart:core';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:zonkafeedback_sdk/src/session_database/sessions.dart';
import 'package:zonkafeedback_sdk/src/sharedpreference/preference_manager.dart';
import 'package:zonkafeedback_sdk/src/utils/app_util.dart';
import 'package:zonkafeedback_sdk/src/utils/encryption_service.dart';

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

  Future<void> init(String token) async {
    await PreferenceManager().init(token);
  }

  void initApiManager() {
    _apiManager = ApiManager.instance;
  }

  void setApiCallbacks(ApiResponseCallbacks callbacks) {
    _callbacks = callbacks;
  }

  void hitSurveyActiveApi(String token, bool isSurveyInitialize) async {
    _apiManager.hitSurveyActiveApi(token).then((widget) async {
      if (widget?.data?.distributionInfo?.embedSettings != null) {
        ExcludeSegment? excludeSegment =
            widget?.data?.distributionInfo?.embedSettings?.excludeSegment;
        IncludeSegment? includeSegment =
            widget?.data?.distributionInfo?.embedSettings?.includeSegment;
        await clearExcludedList();
        await clearIncludeList();

        saveExcludeType(excludeSegment?.type ?? "");
        saveIncludeType(includeSegment?.type ?? "");
        if (excludeSegment!.list!.isNotEmpty) {
          saveExcludedList(excludeSegment.list!);
        } else if (includeSegment!.list!.isNotEmpty) {
          saveIncludedList(includeSegment.list!);
        } else {
          saveExcludedList(excludeSegment.list!);
          saveIncludedList(includeSegment.list!);
        }
      }
      DataManager()
          .setWidgetActivity(widget!.data!.distributionInfo!.isWidgetActive!);
      DataManager().setCompanyId(widget.data!.distributionInfo!.companyId!);
    }, onError: (error) {
      if (error is DioException) {}
    });
  }

  void createContactForDynamicAttribute(
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
          saveContactId(contactResponse.data!.contactInfo!.id!);
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

  void saveContactId(String contactId) {
    PreferenceManager().putString(Constant.CONTACT_ID, contactId);
  }

  void saveExternalVisitorId(String evd) {
    PreferenceManager().putString(Constant.EXTERNAL_VISITOR_ID, evd);
  }

  void saveEmailId(String emailId) {
    PreferenceManager().putString(Constant.EMAIL_ID, emailId);
  }

  void saveMobileNo(String mobileNo) {
    PreferenceManager().putString(Constant.MOBILE_NO, mobileNo);
  }

  void saveUniqueId(String uniqueId) {
    PreferenceManager().putString(Constant.UNIQUE_ID, uniqueId);
  }

  void saveRegion(String zfRegion) {
    PreferenceManager().putString(Constant.ZF_REGION, zfRegion);
  }

  void saveContactName(String contactName) {
    PreferenceManager().putString(Constant.CONTACT_NAME, contactName);
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

    String encryptValue = EncryptionService().encryptData(PreferenceManager().getString(Constant.EMAIL_ID, ""));
    return encryptValue;
  }

  String getMobileNo() {
    String encryptValue = EncryptionService().encryptData(PreferenceManager().getString(Constant.MOBILE_NO, ""));
    return encryptValue;
  }

  String getUniqueId() {
    String encryptValue =  EncryptionService().encryptData(PreferenceManager().getString(Constant.UNIQUE_ID, ""));
    return encryptValue ;
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

  Future<void> saveExcludeType(String type) async {
    await PreferenceManager().putString(Constant.EXCLUDE_TYPE, type);
  }

  void saveIncludeType(String type) {
    PreferenceManager().putString(Constant.INCLUDE_TYPE, type);
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
