library zonka_feedback;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:zonkafeedback_sdk/src/constant.dart';
import 'package:zonkafeedback_sdk/src/data_manager.dart';
import 'package:zonkafeedback_sdk/src/model/token_validation.dart';
import 'package:zonkafeedback_sdk/src/network/api_response_callback.dart';
import 'package:zonkafeedback_sdk/src/pending_survey_scheduler.dart';
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
  GlobalKey<NavigatorState>? _navigatorKey;
  String? uiType = 'popup';
  double? _expandedHeightValue = 580;
  double? _fixedHeightValue = 410;
  String? _crossIconPosition = "left";
  bool? _autoClose = true;
  String _regionValue = "";
  bool _deviceDetailsValue = false;
  String _closeIconType = 'icon1';

  List<String> _multipleTokens = [];

  /// Guards against overlapping [startSurvey] runs. Stays set while a run is
  /// validating or the survey is on screen, so repeated calls cannot stack
  /// dialogs. It is not held during the on-page delay: that is tracked by the
  /// persisted pending survey instead.
  bool _surveyPending = false;

  /// Set once [init] has loaded preferences. Lifecycle events and
  /// [startSurvey] calls that arrive earlier are ignored.
  bool _initialized = false;

  late final PendingSurveyScheduler _pendingSurvey = PendingSurveyScheduler(
    onDue: startSurvey,
    isEligible: () => DataManager().isWidgetActive() && checkSegmenting(),
    displayContext: _activeContext,
    show: (context, token) {
      _survey = Survey(token, _regionValue);
      return _showSurvey(context);
    },
  );

  /// Initialize SDK with necessary details
  ///
  /// [navigatorKey] is the key given to the app's `MaterialApp` /
  /// `CupertinoApp`. When set, a survey whose on-page delay runs out after
  /// [context]'s screen was closed is shown on the current route instead of
  /// waiting for a screen that is gone.
  Future<void> init(
      {required List<String> token,
      required String zfRegion,
      required BuildContext context,
      GlobalKey<NavigatorState>? navigatorKey,
      bool? autoClose,
      String? displayType,
      String? closeIconType,
      double? expandedHeight,
      double? minimumHeight,
      String? closeIconPosition}) async {
    _context = context;
    _navigatorKey = navigatorKey;
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
    _closeIconType = closeIconType ?? 'icon1';
    _autoClose = autoClose;
    _multipleTokens = token;
    _regionValue = zfRegion;
    _initialized = true;

    // A survey that qualified before the app was killed is picked up here,
    // so it does not wait for the host to call startSurvey() again.
    if (_pendingSurvey.hasPending) startSurvey();
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

  Future<void> _getZfSurveyUrl(BuildContext context) async {
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
          await AppUtils.instance.getHiddenVariables(context);
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
    else if (includedList.isNotEmpty) {
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
    // validateCodes sends no include type; with an empty list that means the
    // distribution is not restricted to any segment.
    else if (inclueType.isEmpty) {
      processEmbedSurvey = true;
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
    await DataManager().refreshToken(token);
    bool widgetActive = DataManager().isWidgetActive();
    bool segmentAllowed = checkSegmenting();
    if (kDebugMode) {
      debugPrint('[ZF-SEG] token=$token -> widgetActive=$widgetActive'
          ' segmentAllowed=$segmentAllowed'
          ' valid=${widgetActive && segmentAllowed}');
    }
    return (widgetActive && segmentAllowed);
  }

  void startSurvey() async {
    if (!_initialized || _surveyPending) return;
    _surveyPending = true;
    try {
      // A survey already waiting out its on-page delay is resumed rather than
      // re-evaluated, so repeated calls cannot push its deadline back.
      if (_pendingSurvey.hasPending) {
        await _pendingSurvey.resume(_multipleTokens);
      } else {
        await _startSurvey();
      }
    } finally {
      _surveyPending = false;
    }
  }

  Future<void> _startSurvey() async {
    if (_multipleTokens.isEmpty) return;
    await userInfo(customAttributehashMap ?? {}, _multipleTokens.first);

    // All tokens are validated in one validateCodes request. If it fails
    // (null), no token is valid.
    final List<TokenValidation> results =
        await DataManager().validateTokens(_multipleTokens) ?? const [];
    final Map<String, TokenValidation> resultByToken = {
      for (final TokenValidation result in results) result.token: result
    };

    // contacts/tracking is called at most once per run. The contact's lists
    // belong to the contact, not the token, so one response serves every
    // token's segment check. It is deferred until the first token whose
    // widget is active, so inactive tokens cost no tracking call and the
    // request carries the companyId that token's validation just saved.
    bool contactCreated = false;
    bool checkValidationValue = false;
    for (final String token in _multipleTokens) {
      final TokenValidation? result = resultByToken[token];
      if (result == null || !result.valid) {
        if (kDebugMode) debugPrint('[ZF-SEG] token=$token -> valid=false');
        continue;
      }
      await DataManager().applyValidDistribution(result.distributionInfo);
      final bool widgetActive = DataManager().isWidgetActive();
      if (widgetActive && !contactCreated) {
        await _createContact(token);
        contactCreated = true;
      }
      checkValidationValue = widgetActive && checkSegmenting();
      if (kDebugMode) {
        debugPrint('[ZF-SEG] token=$token -> widgetActive=$widgetActive'
            ' valid=$checkValidationValue');
      }
      if (checkValidationValue) {
        _survey = Survey(token, _regionValue);
        await SessionService().syncSessionServer(token);
        SessionService().sessionStarted();
        break;
      }
    }

    // No widget was active: still record the visit once, as every run did
    // before tracking was deduplicated.
    if (!contactCreated) {
      await _createContact(_multipleTokens.first);
    }

    if (checkValidationValue) {
      final int pageDelay = DataManager().getPageDelay();
      if (pageDelay > 0) {
        await _pendingSurvey.start(
            _survey.getSurveyToken(), Duration(seconds: pageDelay));
        return;
      }

      final BuildContext? context = _activeContext();
      if (context == null || !context.mounted) return;
      await _showSurvey(context);
    }
  }

  /// A context that can show the survey: the [init] context while its screen
  /// is open, otherwise the app navigator's, or `null` when neither is.
  BuildContext? _activeContext() {
    if (_context.mounted) return _context;
    final BuildContext? navigatorContext = _navigatorKey?.currentContext;
    if (navigatorContext != null && navigatorContext.mounted) {
      return navigatorContext;
    }
    return null;
  }

  Future<void> _showSurvey(BuildContext context) async {
    await _getZfSurveyUrl(context);
    if (!context.mounted) return;

    String openUrl = _url + Constant.EMBED_URL;
    if (uiType == 'popup') {
      await ZFSurveyDialog.show(
        context: context,
        surveyUrl: openUrl,
        closeIconType: _closeIconType,
        autoClose: _autoClose ?? true,
        fixedHeight: _fixedHeightValue ?? 100,
        expandedHeight: _expandedHeightValue ?? 100,
        crossIconPosition: _crossIconPosition ?? "left",
      );
    } else if (uiType == 'slide-up') {
      await ZfBottomSheetDialog.show(
        context: context,
        surveyUrl: openUrl,
        closeIconType: _closeIconType,
        autoClose: _autoClose ?? true,
        fixedHeight: _fixedHeightValue ?? 100,
        expandedHeight: _expandedHeightValue ?? 100,
        crossIconPosition: _crossIconPosition ?? "left",
      );
    }
  }

  Future<void> _createContact(String token) {
    return DataManager().createContactForDynamicAttribute(
      customAttributehashMap ?? {},
      token,
      true,
    );
  }

// session update value
  void sendAppLifecycleState(AppLifecycleState state) {
    // Handle specific states
    switch (state) {
      case AppLifecycleState.resumed:
        // Re-arm, or show if it fell due while the app was in the background.
        if (_initialized && _pendingSurvey.hasPending) startSurvey();
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
        // Only the timer stops; the persisted deadline keeps running and is
        // honoured on resume.
        _pendingSurvey.cancelTimer();
        SessionService().sessionEnded();
        SessionService().sessionListPrint();
        break;

      case AppLifecycleState.detached:
        _pendingSurvey.cancelTimer();
        SessionService().sessionEnded();
        SessionService().sessionListPrint();
        // Perform cleanup actions like closing database connections or saving state
        break;
      case AppLifecycleState.hidden:
        _pendingSurvey.cancelTimer();
    }
  }

  @override
  void onContactCreationSuccess(bool isContactCreated) {
    if (!isContactCreated) {
      startSurvey();
    }
  }

  void clear() {
    _pendingSurvey.cancelTimer();
    // Clear preferences (this includes any pending survey)
    DataManager().clearPreference();
    SessionService().clearSession();
    // Save updated data
    DataManager().saveFirstSeen();
    DataManager().saveCookieId();
  }
}
