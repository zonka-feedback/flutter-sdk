import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zonkafeedback_sdk/src/data_manager.dart';
import 'package:zonkafeedback_sdk/zonkafeedback_sdk.dart';

const String _token = 'tok_pending';

/// [offset] from now, truncated to the millisecond precision it is stored at.
DateTime _fromNow(Duration offset) => DateTime.fromMillisecondsSinceEpoch(
    DateTime.now().add(offset).millisecondsSinceEpoch);

Future<void> _initSdk(WidgetTester tester,
    {List<String> tokens = const [_token]}) async {
  late BuildContext context;
  await tester.pumpWidget(Builder(builder: (c) {
    context = c;
    return const SizedBox();
  }));
  await tester.runAsync(() => ZFSurvey().init(
        token: tokens,
        zfRegion: 'US',
        context: context,
      ));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DataManager pending survey', () {
    test('round-trips token and deadline, and clears', () async {
      await DataManager().init();
      expect(DataManager().getPendingSurvey(), isNull);

      final showAt = DateTime.fromMillisecondsSinceEpoch(1760000000000);
      await DataManager().savePendingSurvey(_token, showAt);
      final pending = DataManager().getPendingSurvey();
      expect(pending?.token, _token);
      expect(pending?.showAt, showAt);

      await DataManager().clearPendingSurvey();
      expect(DataManager().getPendingSurvey(), isNull);
    });
  });

  group('ZFSurvey pending survey', () {
    testWidgets('backgrounding keeps the deadline', (tester) async {
      await _initSdk(tester);
      final showAt = _fromNow(const Duration(minutes: 30));
      await DataManager().savePendingSurvey(_token, showAt);

      await tester.runAsync(() async {
        ZFSurvey().sendAppLifecycleState(AppLifecycleState.hidden);
        ZFSurvey().sendAppLifecycleState(AppLifecycleState.paused);
        await Future<void>.delayed(Duration.zero);
      });

      expect(DataManager().getPendingSurvey()?.showAt, showAt);
    });

    testWidgets('startSurvey before the deadline does not reset it',
        (tester) async {
      await _initSdk(tester);
      final showAt = _fromNow(const Duration(minutes: 30));
      await DataManager().savePendingSurvey(_token, showAt);

      await tester.runAsync(() async {
        ZFSurvey().startSurvey();
        ZFSurvey().sendAppLifecycleState(AppLifecycleState.resumed);
        await Future<void>.delayed(Duration.zero);
      });

      expect(DataManager().getPendingSurvey()?.showAt, showAt);
      // Stop the 30 minute timer the resume armed.
      ZFSurvey().clear();
    });

    testWidgets('a pending survey for a token no longer in use is dropped',
        (tester) async {
      await _initSdk(tester, tokens: ['tok_other']);
      await DataManager().savePendingSurvey(
          _token, DateTime.now().subtract(const Duration(minutes: 1)));

      await tester.runAsync(() async {
        ZFSurvey().startSurvey();
        await Future<void>.delayed(Duration.zero);
      });

      expect(DataManager().getPendingSurvey(), isNull);
    });

    testWidgets('clear() drops the pending survey', (tester) async {
      await _initSdk(tester);
      await DataManager()
          .savePendingSurvey(_token, _fromNow(const Duration(minutes: 30)));

      ZFSurvey().clear();

      expect(DataManager().getPendingSurvey(), isNull);
    });
  });
}
