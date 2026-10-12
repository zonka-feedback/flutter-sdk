import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:zonkafeedback_sdk/src/data_manager.dart';

/// Owns the on-page delay of a survey that has qualified.
///
/// The deadline is persisted rather than held in memory, so backgrounding the
/// app or the process being killed does not cancel it. The [Timer] only runs
/// while the app is in the foreground; on resume or the next `startSurvey()`
/// it is re-armed for the time left, or the survey is shown if it fell due in
/// the meantime.
class PendingSurveyScheduler {
  PendingSurveyScheduler({
    required this.onDue,
    required this.isEligible,
    required this.displayContext,
    required this.show,
  });

  /// Called when the deadline passes while the app is in the foreground.
  /// Expected to route back into [resume].
  final VoidCallback onDue;

  /// Whether the survey may still be shown, evaluated after the widget
  /// settings have been re-fetched.
  final bool Function() isEligible;

  /// A mounted context to show the survey on, or `null` when there is none.
  final BuildContext? Function() displayContext;

  /// Shows the survey for the token on the given context.
  final Future<void> Function(BuildContext context, String token) show;

  Timer? _timer;

  bool get hasPending => DataManager().getPendingSurvey() != null;

  /// Records that the survey for [token] is due after [delay] and arms the
  /// timer.
  Future<void> start(String token, Duration delay) async {
    await DataManager().savePendingSurvey(token, DateTime.now().add(delay));
    _schedule();
  }

  /// Picks up the pending survey: re-arms the timer while the deadline is
  /// ahead, and shows it once the deadline has passed. [activeTokens] are the
  /// tokens the SDK is currently initialised with.
  ///
  /// The caller must guard against overlapping runs.
  Future<void> resume(List<String> activeTokens) async {
    final PendingSurvey? pending = DataManager().getPendingSurvey();
    if (pending == null) return;

    // The host no longer initialises the SDK with that token.
    if (!activeTokens.contains(pending.token)) {
      await clear();
      return;
    }

    if (DateTime.now().isBefore(pending.showAt)) {
      _schedule();
      return;
    }
    cancelTimer();

    // A dialog cannot be shown while the app is in the background; the
    // survey stays pending and is shown on the next resume.
    final AppLifecycleState? lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle != null && lifecycle != AppLifecycleState.resumed) return;

    // The widget can be switched off, or the contact can leave the segment,
    // while the delay runs, so the decision is re-checked at display time.
    // If the check cannot reach the server the survey stays pending.
    if (!await DataManager().hitSurveyActiveApi(pending.token)) return;
    final bool stillValid = isEligible();
    if (kDebugMode) {
      debugPrint('[ZF-SEG] pending token=${pending.token}'
          ' -> valid=$stillValid');
    }
    if (!stillValid) {
      await clear();
      return;
    }

    // The screen that started the survey may be long gone; without a mounted
    // context the survey stays pending for the next resume or startSurvey().
    final BuildContext? context = displayContext();
    if (context == null) return;

    // Cleared before display so a survey the user has seen is never shown a
    // second time, e.g. if the app is killed while it is on screen.
    await clear();
    if (!context.mounted) return;
    await show(context, pending.token);
  }

  /// Stops the timer only; the persisted deadline keeps running.
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Drops the pending survey entirely.
  Future<void> clear() async {
    cancelTimer();
    await DataManager().clearPendingSurvey();
  }

  /// Arms the timer for the time left on the pending survey.
  void _schedule() {
    cancelTimer();
    final PendingSurvey? pending = DataManager().getPendingSurvey();
    if (pending == null) return;
    Duration remaining = pending.showAt.difference(DateTime.now());
    if (remaining.isNegative) remaining = Duration.zero;
    _timer = Timer(remaining, () {
      _timer = null;
      onDue();
    });
  }
}
