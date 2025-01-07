library zonka_feedback;

import 'package:flutter/cupertino.dart';
import 'package:zonkafeedback_sdk/src/constant.dart';
import 'package:zonkafeedback_sdk/src/data_manager.dart';
import 'package:zonkafeedback_sdk/src/network/api_response_callback.dart';
import 'package:zonkafeedback_sdk/src/session_database/hive_service.dart';
import 'package:zonkafeedback_sdk/src/session_database/session_service.dart';
import 'package:zonkafeedback_sdk/src/survey.dart';
import 'package:zonkafeedback_sdk/src/utils/app_util.dart';
import 'package:zonkafeedback_sdk/src/zf_survey_dialog.dart';

class ZFSurvey implements ApiResponseCallbacks {
  static final ZFSurvey _instance = ZFSurvey._internal();
  factory ZFSurvey() => _instance;
  ZFSurvey._internal();

  static late Survey _survey;
  String _url = "";
  static String _customVariableString = "";
  late ZFSurveyDialog zfSurveyDialog;
  late BuildContext _context;

  /// Initialize SDK with necessary details
  Future<void> init(
      {required String token,
      required String zfRegion,
      required BuildContext context}) async {
    _context = context;
    await DataManager().init(token);
    _initializeSDK(token, zfRegion);
  }

  void _initializeSDK(String token, String zfRegion) async {
    _survey = Survey(token, zfRegion);
    DataManager().saveRegion(zfRegion);
    DataManager().saveFirstSeen();
    DataManager().saveCookieId();
    DataManager().initApiManager();
    await HiveService().init();
    await SessionService().syncSessionServer(_survey.getSurveyToken());
    SessionService().sessionStarted();
    _initializeZFData();
  }

  void _initializeZFData() async {
    DataManager().setApiCallbacks(this);
    bool checkInternetConnection = await AppUtils.instance.isNetworkConnected();
    if (checkInternetConnection) {
      DataManager().hitSurveyActiveApi(_survey.getSurveyToken(), false);
    }
    _getZfSurveyUrl();
  }

  ZFSurvey userInfo(Map<String, dynamic> hashMap) {
    if (hashMap.isNotEmpty) {
      hashMap.forEach((key, value) {
        if (key.isNotEmpty && key == Constant.EMAIL_ID) {
          if (value.toString().isNotEmpty) {
            DataManager().saveEmailId(value.toString());
          }
        }
        if (key.isNotEmpty && key == Constant.MOBILE_NO) {
          if (value.toString().isNotEmpty) {
            DataManager().saveMobileNo(value.toString());
          }
        }
        if (key.isNotEmpty && key == Constant.UNIQUE_ID) {
          if (value.toString().isNotEmpty) {
            DataManager().saveUniqueId(value.toString());
          }
        }
        if (key.isNotEmpty && key == Constant.CONTACT_NAME) {
          if (value.toString().isNotEmpty) {
            DataManager().saveContactName(value.toString());
          }
        }
      });
    }
    DataManager().createContactForDynamicAttribute(
      hashMap,
      _survey.surveyToken,
      true,
    );
    return this;
  }

  void addCustomParam(Map<String, dynamic>? hashMap) {
    if (hashMap == null) return;
    hashMap.forEach((key, value) {
      _customVariableString += '$key=$value&';
    });
    userInfo(hashMap);
  }

  Future<void> _getZfSurveyUrl() async {
    _url = _survey.getZfSurveyUrl();
    _customVariableString = "";
    if (_survey.getCustomAttributes() != null &&
        _survey.getCustomAttributes()!.isNotEmpty) {
      addCustomParam(_survey.getCustomAttributes());
      _url = _url + _customVariableString;
    }

    if (DataManager().getCookieId().isNotEmpty) {
      _customVariableString = "";
      _url = "${_url}cookieId=${DataManager().getCookieId()}&";
    }

    if (DataManager().getExternalVisitorId().isNotEmpty) {
      _customVariableString = "";
      _url =
          "${_url}externalVisitorId=${DataManager().getExternalVisitorId()}&";
    }

    if (DataManager().getContactId().isNotEmpty) {
      _customVariableString = "";
      _url = "${_url}contactId=${DataManager().getContactId()}&";
    }

    if (_survey.getDeviceDetails()) {
      _customVariableString = "";
      Map<String, dynamic> value =
          await AppUtils.instance.getHiddenVariables(_context);
      addCustomParam(value);
      _url = _url + _customVariableString;
    }
  }

  ZFSurvey sendCustomAttributes(Map<String, dynamic> hashMap) {
    if (hashMap.isNotEmpty) {
      _survey.sendCustomAttributes(hashMap);
    }
    return this;
  }

  ZFSurvey sendDeviceDetails(bool deviceDetails) {
    _survey.sendDeviceDetails(deviceDetails);
    return this;
  }

  bool checkSegmenting() {
    // Fetch included list
    List<String>? includedListSet = DataManager().getIncludedList();
    List<String> includedList = [];
    if (includedListSet != null) {
      includedList.addAll(includedListSet);
      // Clear the data to avoid adding duplicate values on subsequent API calls
      DataManager().getIncludedList()?.clear();
    }

    // Fetch excluded list
    List<String>? excludedListSet = DataManager().getExcludedList();
    List<String> excludedList = [];
    if (excludedListSet != null) {
      excludedList.addAll(excludedListSet);
      // Clear the data to avoid adding duplicate values on subsequent API calls
      DataManager().getExcludedList()?.clear();
    }

    // Fetch contact response list
    List<String>? contactListSet = DataManager().getContactList();
    List<String> contactResponseList = [];
    if (contactListSet != null) {
      contactResponseList.addAll(contactListSet);
    }

    bool processEmbedSurvey = false;

    // Check included segments
    if (includedList.isNotEmpty) {
      processEmbedSurvey = false;
      if (contactResponseList.isNotEmpty) {
        for (String segmentInContact in contactResponseList) {
          if (includedList.contains(segmentInContact)) {
            processEmbedSurvey = true;
            break;
          }
        }
      }
    }

    // Check excluded segments
    if (excludedList.isNotEmpty) {
      if (contactResponseList.isNotEmpty) {
        for (String segmentInContact in contactResponseList) {
          if (excludedList.contains(segmentInContact)) {
            processEmbedSurvey = false;
            break;
          }
        }
      }
    }

    String inclueType = DataManager().getIncludeType();

    if (inclueType == 'all') {
      processEmbedSurvey = true;
    }

    return processEmbedSurvey;
  }

  void startSurvey() async {
    bool checkNetworkConnection = await AppUtils.instance.isNetworkConnected();
    if (checkNetworkConnection) {
      await _getZfSurveyUrl();
      if (DataManager().getContactId().isEmpty) {
        if (DataManager().getExternalVisitorId().isEmpty) {
        } else {
          DataManager().hitSurveyActiveApi(_survey.getSurveyToken(), true);
        }
      } else {
        DataManager().hitSurveyActiveApi(_survey.getSurveyToken(), true);
      }
    } else {
      return;
    }
    bool widgetActive = DataManager().isWidgetActive();
    String openUrl = _url + Constant.EMBED_URL;
    if (widgetActive) {
      bool segmentAllowed = checkSegmenting();
      if (segmentAllowed) {
        await ZFSurveyDialog.show(context: _context, surveyUrl: openUrl);
      }
    }
  }

// session update value
  void sendAppLifecycleState(AppLifecycleState state) {
    // Handle specific states
    switch (state) {
      case AppLifecycleState.resumed:
        SessionService().sessionStarted();
        SessionService().sessionListPrint();
        // App is visible and in the foreground
        // Perform actions like resuming tasks, fetching data, or sending analytics
        break;

      case AppLifecycleState.inactive:
        // App is inactive (e.g., a phone call or app switcher is open)
        // Perform actions like pausing animations or saving unsaved work
        break;

      case AppLifecycleState.paused:
        SessionService().sessionEnded();
        SessionService().sessionListPrint();
        break;

      case AppLifecycleState.detached:
        SessionService().sessionEnded();
        SessionService().syncSessionServer(_survey.getSurveyToken());

        // Perform cleanup actions like closing database connections or saving state
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  @override
  void onContactCreationSuccess(bool isContactCreated) {
    if (!isContactCreated) {
      startSurvey();
    }
  }

  void clear() {
    // Clear preferences
    DataManager().clearPreference();
    SessionService().clearSession();
    // Save updated data
    DataManager().saveFirstSeen();
    DataManager().saveCookieId();
  }
}
