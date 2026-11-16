import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zonkafeedback_sdk/src/data_manager.dart';
import 'package:zonkafeedback_sdk/src/model/contact_response/contact_info.dart';
import 'package:zonkafeedback_sdk/src/model/token_validation.dart';
import 'package:zonkafeedback_sdk/zonkafeedback_sdk.dart';

/// A `distribution/validateCodes` result as the backend returns it.
Map<String, dynamic> _validResult({
  Map<String, dynamic> includeSegment = const {'list': []},
  Map<String, dynamic> excludeSegment = const {'list': []},
  Map<String, dynamic>? trigger,
  bool? isWidgetActive,
}) =>
    {
      'token': '4zQ6Zd',
      'valid': true,
      'distributionInfo': {
        '_id': '6650a1f2c3d4e5f6a7b8c9d0',
        'companyId': '638f0d483e54c5730f1576ed',
        'surveyId': '6650a1e0c3d4e5f6a7b8c9aa',
        'uniqueRefCode': '4zQ6Zd',
        'type': 'embed',
        'name': 'In-app widget',
        'isActive': true,
        if (isWidgetActive != null) 'isWidgetActive': isWidgetActive,
        'embedSettings': {
          'embedType': 'popover',
          'type': 'popup',
          'appearance': 0,
          'visibleTill': 'submit',
          'includeSegment': includeSegment,
          'excludeSegment': excludeSegment,
          if (trigger != null) 'trigger': trigger,
          'includeSegmentConditions': [],
          'excludeSegmentConditions': [],
        },
        'createdDate': '2026-05-24T10:12:34.000Z',
      },
      'companyInfo': {
        '_id': '638f0d483e54c5730f1576ed',
        'countryId': {'_id': '5e1c', 'name': 'India'},
      },
    };

Future<bool> _apply(Map<String, dynamic> json) async {
  final TokenValidation result = TokenValidation.fromJson(json);
  await DataManager().applyValidDistribution(result.distributionInfo);
  return DataManager().isWidgetActive() && ZFSurvey().checkSegmenting();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await DataManager().init();
  });

  group('TokenValidation.fromJson', () {
    test('parses a valid result with its distribution', () {
      final result = TokenValidation.fromJson(_validResult());
      expect(result.token, '4zQ6Zd');
      expect(result.valid, isTrue);
      expect(result.distributionInfo?.companyId, '638f0d483e54c5730f1576ed');
    });

    test('parses an invalid result without a distribution', () {
      final result =
          TokenValidation.fromJson({'token': 'TOKEN_2', 'valid': false});
      expect(result.valid, isFalse);
      expect(result.distributionInfo, isNull);
    });
  });

  group('applyValidDistribution', () {
    test('a valid token with no segments shows to everyone', () async {
      expect(await _apply(_validResult()), isTrue);
      expect(DataManager().getCompanyID(), '638f0d483e54c5730f1576ed');
      expect(DataManager().getPageDelay(), 0);
    });

    test('an include list restricts to its segments', () async {
      final json = _validResult(includeSegment: {
        'list': ['vip']
      });
      await DataManager().saveContactList(['basic']);
      expect(await _apply(json), isFalse);
      await DataManager().saveContactList(['vip']);
      expect(await _apply(json), isTrue);
    });

    test('an exclude list hides the survey from its segments', () async {
      await DataManager().saveContactList(['churned']);
      expect(
          await _apply(_validResult(excludeSegment: {
            'list': ['churned']
          })),
          isFalse);
    });

    test('include and exclude lists both apply', () async {
      final json = _validResult(includeSegment: {
        'list': ['vip']
      }, excludeSegment: {
        'list': ['churned']
      });
      await DataManager().saveContactList(['vip']);
      expect(await _apply(json), isTrue);
      await DataManager().saveContactList(['vip', 'churned']);
      expect(await _apply(json), isFalse);
    });

    test('an explicit isWidgetActive false is honoured', () async {
      expect(await _apply(_validResult(isWidgetActive: false)), isFalse);
    });

    test('reads the on-page delay when present', () async {
      await _apply(_validResult(trigger: {'after': 30}));
      expect(DataManager().getPageDelay(), 30);
    });
  });

  group('segment delay', () {
    final Map<String, dynamic> vipWithDelay = _validResult(
      includeSegment: {
        'list': ['vip']
      },
      trigger: {'after': 600},
    );

    Future<void> joinedVip(Duration ago) async {
      await DataManager().saveContactList(['vip']);
      final String date =
          DateTime.now().toUtc().subtract(ago).toIso8601String();
      await DataManager().saveContactListMemberships({
        'vip': ListMembership(createdDate: date, modifiedDate: date),
      });
    }

    test('hidden until createdDate + delay has passed', () async {
      await joinedVip(const Duration(minutes: 5));
      expect(await _apply(vipWithDelay), isFalse);
    });

    test('shown once createdDate + delay has passed', () async {
      await joinedVip(const Duration(minutes: 11));
      expect(await _apply(vipWithDelay), isTrue);
    });

    test('createdDate wins over modifiedDate', () async {
      await DataManager().saveContactList(['vip']);
      final DateTime now = DateTime.now().toUtc();
      await DataManager().saveContactListMemberships({
        'vip': ListMembership(
          createdDate: now.subtract(const Duration(hours: 1)).toIso8601String(),
          // contacts/tracking bumps modifiedDate to "now" on every call.
          modifiedDate:
              now.subtract(const Duration(minutes: 1)).toIso8601String(),
        ),
      });
      expect(await _apply(vipWithDelay), isTrue);
    });

    test('a list without a membership date is not delayed', () async {
      await DataManager().saveContactList(['vip']);
      await DataManager().saveContactListMemberships({});
      expect(await _apply(vipWithDelay), isTrue);
    });

    test('a zero delay shows straight away', () async {
      await joinedVip(Duration.zero);
      expect(
          await _apply(_validResult(includeSegment: {
            'list': ['vip']
          })),
          isTrue);
    });

    test('parses listMemberships from contacts/tracking', () {
      final ContactInfo info = ContactInfo.fromJson({
        'lists': ['6afaa179b78b00e6a253da0f'],
        'listMemberships': {
          '6afaa179b78b00e6a253da0f': {
            'createdDate': '2026-11-16T06:32:05.226Z',
            'modifiedDate': '2026-11-16T06:58:11.904Z',
          },
        },
      });
      expect(info.listMemberships?['6afaa179b78b00e6a253da0f']?.modifiedDate,
          '2026-11-16T06:58:11.904Z');
    });
  });

  group('nextSegmentVisibleAt', () {
    Future<void> setUpVip(Duration joinedAgo, {int delay = 1800}) async {
      await DataManager().applyValidDistribution(
          TokenValidation.fromJson(_validResult(includeSegment: {
        'list': ['vip']
      }, trigger: {
        'after': delay
      })).distributionInfo);
      await DataManager().saveContactList(['vip']);
      final String date =
          DateTime.now().toUtc().subtract(joinedAgo).toIso8601String();
      await DataManager().saveContactListMemberships({
        'vip': ListMembership(modifiedDate: date),
      });
    }

    test('returns modifiedDate + delay while it is ahead', () async {
      await setUpVip(const Duration(minutes: 10));
      final DateTime? due = ZFSurvey().nextSegmentVisibleAt();
      expect(due, isNotNull);
      final Duration left = due!.difference(DateTime.now());
      expect(left.inMinutes, inInclusiveRange(19, 20));
    });

    test('null once the delay has passed', () async {
      await setUpVip(const Duration(minutes: 31));
      expect(ZFSurvey().nextSegmentVisibleAt(), isNull);
    });

    test('null without a delay', () async {
      await setUpVip(Duration.zero, delay: 0);
      expect(ZFSurvey().nextSegmentVisibleAt(), isNull);
    });

    test('null when the contact is in an excluded segment', () async {
      await setUpVip(const Duration(minutes: 10));
      DataManager().saveExcludedList(['churned']);
      await DataManager().saveContactList(['vip', 'churned']);
      expect(ZFSurvey().nextSegmentVisibleAt(), isNull);
    });
  });
}
