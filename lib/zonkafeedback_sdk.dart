library zonka_feedback;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:zonkafeedback_sdk/src/constant.dart';
import 'package:zonkafeedback_sdk/src/data_manager.dart';
import 'package:zonkafeedback_sdk/src/model/token_validation.dart';
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
  /// dialogs.
  bool _surveyPending = false;

  /// Set once [init] has loaded preferences. Lifecycle events and
  /// [startSurvey] calls that arrive earlier are ignored.
  bool _initialized = false;

  /// When the contact's earliest delayed segment becomes visible, so the
  /// survey can be shown then without another [startSurvey] call. Kept in
  /// memory only: it is recomputed from `contacts/tracking` on every run.
  DateTime? _segmentDueAt;

  /// Fires at [_segmentDueAt]. Runs only while the app is in the foreground.
  Timer? _segmentTimer;

  /// Initialize SDK with necessary details
  ///
  /// [navigatorKey] is the key given to the app's `MaterialApp` /
  /// `CupertinoApp`. When set, a survey started after [context]'s screen was
  /// closed is shown on the current route instead of being skipped.
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
        final int delaySeconds = DataManager().getPageDelay();
        for (String segmentInContact in contactResponseList) {
          if (includedList.contains(segmentInContact) &&
              _segmentDelayPassed(segmentInContact, delaySeconds)) {
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

  /// The earliest time a delayed included segment the contact is in becomes
  /// visible, or `null` when none is waiting: there is no delay, the
  /// distribution targets everyone, the contact is in an excluded segment, or
  /// no matching segment has a membership date in the future.
  @visibleForTesting
  DateTime? nextSegmentVisibleAt() {
    final int delaySeconds = DataManager().getPageDelay();
    if (delaySeconds <= 0 || DataManager().getIncludeType() == 'all') {
      return null;
    }
    final List<String> included = DataManager().getIncludedList() ?? const [];
    final List<String> excluded = DataManager().getExcludedList() ?? const [];
    final List<String> contactLists =
        DataManager().getContactList() ?? const [];
    if (contactLists.any(excluded.contains)) return null;

    final DateTime now = DateTime.now();
    DateTime? next;
    for (final String listId in contactLists) {
      if (!included.contains(listId)) continue;
      final DateTime? joinedDate =
          DataManager().getListMembershipJoinedDate(listId);
      if (joinedDate == null) continue;
      final DateTime visibleFrom =
          joinedDate.add(Duration(seconds: delaySeconds));
      if (visibleFrom.isAfter(now) &&
          (next == null || visibleFrom.isBefore(next))) {
        next = visibleFrom;
      }
    }
    return next;
  }

  /// Whether the contact has been in [listId] for at least [delaySeconds]
  /// (`embedSettings.trigger.after`), counted from that list's
  /// `listMemberships.createdDate` in the `contacts/tracking` response.
  ///
  /// A list with no membership date counts as joined long ago, so a server
  /// that does not send `listMemberships` keeps the old behaviour.
  bool _segmentDelayPassed(String listId, int delaySeconds) {
    if (delaySeconds <= 0) return true;
    final DateTime? joinedDate =
        DataManager().getListMembershipJoinedDate(listId);
    if (joinedDate == null) return true;
    final DateTime visibleFrom =
        joinedDate.add(Duration(seconds: delaySeconds));
    return !DateTime.now().isBefore(visibleFrom);
  }

  Future<bool> checkValidation(String token) async {
    await DataManager().refreshToken(token);
    bool widgetActive = DataManager().isWidgetActive();
    bool segmentAllowed = checkSegmenting();
    return (widgetActive && segmentAllowed);
  }

  void startSurvey() async {
    if (!_initialized || _surveyPending) return;
    _surveyPending = true;
    try {
      await _startSurvey();
    } finally {
      _surveyPending = false;
    }
  }

  Future<void> _startSurvey() async {
    if (_multipleTokens.isEmpty) return;
    // Every run decides afresh whether a delayed segment is still waiting.
    _cancelSegmentTimer();
    _segmentDueAt = null;
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
    DateTime? segmentDueAt;
    for (final String token in _multipleTokens) {
      final TokenValidation? result = resultByToken[token];
      if (result == null || !result.valid) {
        continue;
      }
      await DataManager().applyValidDistribution(result.distributionInfo);
      final bool widgetActive = DataManager().isWidgetActive();
      if (widgetActive && !contactCreated) {
        await _createContact(token);
        contactCreated = true;
      }
      checkValidationValue = widgetActive && checkSegmenting();
      if (checkValidationValue) {
        _survey = Survey(token, _regionValue);
        await SessionService().syncSessionServer(token);
        SessionService().sessionStarted();
        break;
      }
      if (widgetActive) {
        final DateTime? dueAt = nextSegmentVisibleAt();
        if (dueAt != null &&
            (segmentDueAt == null || dueAt.isBefore(segmentDueAt))) {
          segmentDueAt = dueAt;
        }
      }
    }

    // Not eligible yet, but a segment becomes visible later: show the survey
    // then if the user is still in the app.
    if (!checkValidationValue && segmentDueAt != null) {
      _segmentDueAt = segmentDueAt;
      _armSegmentTimer();
    }

    // No widget was active: still record the visit once, as every run did
    // before tracking was deduplicated.
    if (!contactCreated) {
      await _createContact(_multipleTokens.first);
    }

    if (checkValidationValue) {
      final BuildContext? context = _activeContext();
      if (context == null || !context.mounted) return;
      await _showSurvey(context);
    }
  }

  /// Arms [_segmentTimer] for the time left until [_segmentDueAt]. A deadline
  /// that passed while the app was in the background fires straight away.
  void _armSegmentTimer() {
    _cancelSegmentTimer();
    final DateTime? dueAt = _segmentDueAt;
    if (dueAt == null) return;
    Duration remaining = dueAt.difference(DateTime.now());
    if (remaining.isNegative) remaining = Duration.zero;
    // A second of slack so the run that fires sees the deadline as passed.
    _segmentTimer = Timer(remaining + const Duration(seconds: 1), () {
      _segmentTimer = null;
      startSurvey();
    });
  }

  /// Stops the timer only; [_segmentDueAt] is kept so it can be re-armed.
  void _cancelSegmentTimer() {
    _segmentTimer?.cancel();
    _segmentTimer = null;
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
        // The survey only fires while the app is in use.
        if (_initialized && _segmentDueAt != null) _armSegmentTimer();
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
        _cancelSegmentTimer();
        SessionService().sessionEnded();
        SessionService().sessionListPrint();
        break;

      case AppLifecycleState.detached:
        _cancelSegmentTimer();
        SessionService().sessionEnded();
        SessionService().sessionListPrint();
        // Perform cleanup actions like closing database connections or saving state
        break;
      case AppLifecycleState.hidden:
        _cancelSegmentTimer();
        break;
    }
  }

  @override
  void onContactCreationSuccess(bool isContactCreated) {
    if (!isContactCreated) {
      startSurvey();
    }
  }

  void clear() {
    _cancelSegmentTimer();
    _segmentDueAt = null;
    // Clear preferences
    DataManager().clearPreference();
    SessionService().clearSession();
    // Save updated data
    DataManager().saveFirstSeen();
    DataManager().saveCookieId();
  }
}
