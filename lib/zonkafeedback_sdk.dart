library zonka_feedback;

import 'package:flutter/cupertino.dart';
import 'package:zonkafeedback_sdk/src/constant.dart';
import 'package:zonkafeedback_sdk/src/data_manager.dart';
import 'package:zonkafeedback_sdk/src/network/api_response_callback.dart';
import 'package:zonkafeedback_sdk/src/session_database/session_service.dart';
import 'package:zonkafeedback_sdk/src/survey.dart';
import 'package:zonkafeedback_sdk/src/utils/app_util.dart';
import 'package:zonkafeedback_sdk/src/zf_bottom_sheet.dart';
import 'package:zonkafeedback_sdk/src/zf_survey_dialog.dart';

class ZFSurvey implements ApiResponseCallbacks {
  static final ZFSurvey _instance = ZFSurvey._internal();
  factory ZFSurvey() => _instance;
  ZFSurvey._internal();
  Map<String, dynamic>? customAttributehashMap;
  static late Survey _survey;
  String _url = "";
  static String _customVariableString = "";
  late ZFSurveyDialog zfSurveyDialog;
  late BuildContext _context;
  String? uiType = 'popup';
  double? _expandedHeightValue = 580;
  double? _fixedHeightValue = 410;
  String? _crossIconPosition = "left";
  bool? _autoClose = true;
  String _regionValue = "";
  bool _deviceDetailsValue = false;

  List<String> _multipleTokens = [];

  /// Initialize SDK with necessary details

  Future<void> init(
      {required List<String> token,
      required String zfRegion,
      required BuildContext context,
      bool? autoClose,
      String? displayType,
      double? expandedHeight,
      double? minimumHeight,
      String? closeIconPosition}) async {
    _context = context;
    await DataManager().init();
    DataManager().saveRegion(zfRegion);
    DataManager().saveFirstSeen();
    DataManager().saveCookieId();
    DataManager().initApiManager();
    DataManager().setApiCallbacks(this);
    uiType = displayType ?? 'popup';
    _expandedHeightValue = expandedHeight ?? 580;
    _fixedHeightValue = minimumHeight ?? 410;
    _crossIconPosition = closeIconPosition;
    _autoClose = autoClose;
    _multipleTokens = token;
    _regionValue = zfRegion;
  }

  Future<bool> checkTokenIsValid(String token) async {
    // await _initializeZFData(token);
    bool widgetActive = DataManager().isWidgetActive();
    bool segmentAllowed = checkSegmenting();
    return widgetActive && segmentAllowed;
  }

  // Future<void> _initializeZFData(String token) async {
  //   DataManager().setApiCallbacks(this);
  //   bool checkInternetConnection = await AppUtils.instance.isNetworkConnected();
  //   if (checkInternetConnection) {
  //     DataManager().hitSurveyActiveApi(token, false);
  //   }
  //   _getZfSurveyUrl();
  // }

  Future<ZFSurvey> userInfo(Map<String, dynamic> hashMap, String token) async {
    if (hashMap.isNotEmpty) {
      hashMap.forEach((key, value) async {
        if (key.isNotEmpty && key == Constant.EMAIL_ID) {
          if (value.toString().isNotEmpty) {
            await DataManager().saveEmailId(value.toString());
          }
        }
        if (key.isNotEmpty && key == Constant.MOBILE_NO) {
          if (value.toString().isNotEmpty) {
            await DataManager().saveMobileNo(value.toString());
          }
        }
        if (key.isNotEmpty && key == Constant.UNIQUE_ID) {
          if (value.toString().isNotEmpty) {
            await DataManager().saveUniqueId(value.toString());
          }
        }
        if (key.isNotEmpty && key == Constant.CONTACT_NAME) {
          if (value.toString().isNotEmpty) {
            await DataManager().saveContactName(value.toString());
          }
        }
      });
    }

    return this;
  }

  void addCustomParam(Map<String, dynamic>? hashMap) {
    if (hashMap == null) return;
    hashMap.forEach((key, value) {
      _customVariableString += '$key=$value&';
    });
  }

  Future<void> _getZfSurveyUrl() async {
    _url = _survey.getZfSurveyUrl();

    _customVariableString = "";

    if (customAttributehashMap != null && customAttributehashMap!.isNotEmpty) {
      addCustomParam(customAttributehashMap);
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

    if (_deviceDetailsValue) {
      _customVariableString = "";
      Map<String, dynamic> value =
          await AppUtils.instance.getHiddenVariables(_context);
      addCustomParam(value);
      _url = _url + _customVariableString;
    }
  }

  ZFSurvey sendCustomAttributes(Map<String, dynamic> hashMap) {
    if (hashMap.isNotEmpty) {
      customAttributehashMap = hashMap;
    }
    return this;
  }

  ZFSurvey sendDeviceDetails(bool deviceDetails) {
    _deviceDetailsValue = deviceDetails;
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
    String inclueType = DataManager().getIncludeType();

    if (inclueType == 'all') {
      processEmbedSurvey = true;
    }

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

    return processEmbedSurvey;
  }

  Future<bool> checkValidation(String token) async {
    await DataManager().hitSurveyActiveApi(token);
    bool widgetActive = DataManager().isWidgetActive();
    bool segmentAllowed = checkSegmenting();
    return (widgetActive && segmentAllowed);
  }

  void startSurvey() async {
    bool checkValidationValue = false;
    for (int i = 0; i < _multipleTokens.length; i++) {
      userInfo(customAttributehashMap ?? {}, _multipleTokens[i]);
      await DataManager().createContactForDynamicAttribute(
        customAttributehashMap ?? {},
        _multipleTokens[i],
        true,
      );
      checkValidationValue = await checkValidation(_multipleTokens[i]);
      if (checkValidationValue) {
        _survey = Survey(_multipleTokens[i], _regionValue);
        await SessionService().syncSessionServer(_multipleTokens[i]);
        SessionService().sessionStarted();
        break;
      }
    }
    await _getZfSurveyUrl();
    String openUrl = _url + Constant.EMBED_URL;
    if (checkValidationValue) {
      if (uiType == 'popup') {
        await ZFSurveyDialog.show(
          context: _context,
          surveyUrl: openUrl,
          autoClose: _autoClose ?? true,
          fixedHeight: _fixedHeightValue ?? 100,
          expandedHeight: _expandedHeightValue ?? 100,
          crossIconPosition: _crossIconPosition ?? "left",
        );
      } else if (uiType == 'slide-up') {
        await ZfBottomSheetDialog.show(
          context: _context,
          surveyUrl: openUrl,
          autoClose: _autoClose ?? true,
          fixedHeight: _fixedHeightValue ?? 100,
          expandedHeight: _expandedHeightValue ?? 100,
          crossIconPosition: _crossIconPosition ?? "left",
        );
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
        SessionService().sessionListPrint();
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
