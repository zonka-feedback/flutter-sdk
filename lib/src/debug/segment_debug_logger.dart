import 'package:flutter/foundation.dart';
import 'package:zonkafeedback_sdk/src/data_manager.dart';
import 'package:zonkafeedback_sdk/src/model/contact_response/contact_info.dart';

/// Debug-only logging used while testing the segment delay.
///
/// Nothing here affects whether a survey is shown; it only prints what the
/// SDK saw. Every method is a no-op outside debug builds.
class SegmentDebugLogger {
  SegmentDebugLogger._();

  /// Prints, for every included segment the contact is in, the membership
  /// dates, the delay (`embedSettings.trigger.after`) and when the segment
  /// becomes visible.
  static void logSegmentTiming(String token) {
    if (!kDebugMode) return;
    final int delaySeconds = DataManager().getPageDelay();
    final String includeType = DataManager().getIncludeType();
    final List<String> included = DataManager().getIncludedList() ?? const [];
    final List<String> contactLists =
        DataManager().getContactList() ?? const [];
    final List<String> matched = contactLists.where(included.contains).toList();

    debugPrint('[ZF-SEG] ===== segment timing token=$token'
        ' includeType=${includeType.isEmpty ? "(none)" : includeType}'
        ' delay=${delaySeconds}s included=$included =====');
    if (includeType == 'all') {
      debugPrint(
          '[ZF-SEG]   includeType=all -> shown to everyone, delay ignored');
    }
    if (matched.isEmpty) {
      debugPrint('[ZF-SEG]   contact is in none of the included segments');
      return;
    }

    final DateTime now = DateTime.now();
    for (final String listId in matched) {
      final ListMembership? membership =
          DataManager().getListMembership(listId);
      final DateTime? joined =
          DataManager().getListMembershipJoinedDate(listId);
      final String usedField = membership?.createdDate != null
          ? 'createdDate'
          : membership?.modifiedDate != null
              ? 'modifiedDate'
              : 'none';
      final DateTime? visibleFrom =
          joined?.add(Duration(seconds: delaySeconds));
      final String timer;
      if (delaySeconds <= 0) {
        timer = 'no delay -> show now';
      } else if (visibleFrom == null) {
        timer = 'no membership date -> show now';
      } else if (now.isBefore(visibleFrom)) {
        timer = 'WAIT ${visibleFrom.difference(now).inSeconds}s';
      } else {
        timer =
            'passed ${now.difference(visibleFrom).inSeconds}s ago -> show now';
      }
      debugPrint('[ZF-SEG]   segment=$listId\n'
          '[ZF-SEG]     createdDate  = ${membership?.createdDate}\n'
          '[ZF-SEG]     modifiedDate = ${membership?.modifiedDate}\n'
          '[ZF-SEG]     counted from = $usedField ($joined)\n'
          '[ZF-SEG]     delay        = ${delaySeconds}s\n'
          '[ZF-SEG]     visibleFrom  = $visibleFrom\n'
          '[ZF-SEG]     now          = ${now.toUtc()}\n'
          '[ZF-SEG]     timer        = $timer');
    }
  }
}
