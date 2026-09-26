import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_event.dart';

/// Regression tests for IBIS live match-event payload hardening (2026-09-26).
///
/// F4: live match events omit MatchID, CompetitionID, PersonID,
/// MatchTeamName, TimeStamp and UpdatedTS per event. MatchTeamID and
/// CreatedTS are still present.
///
/// FIX-B: IbyMatch.fromJson backfills empty event matchTeamName values from
/// HomeTeam/AwayTeam via HomeMatchTeamID/AwayMatchTeamID (copyWith).
void main() {
  final DateTime epoch = DateTime.fromMillisecondsSinceEpoch(0);
  final DateTime createdTsValue = DateTime.parse('2026-09-26T12:00:00.000');

  /// F4-style live event: only the keys the live feed actually sends.
  /// Deliberately omits MatchID, CompetitionID, PersonID, MatchTeamName,
  /// TimeStamp and UpdatedTS (PlayerAssistID/PlayerAssistName arrive as null).
  Map<String, dynamic> f4LiveEvent() => <String, dynamic>{
        'MatchEventID': 123,
        'MatchEventTypeID': 1,
        'MatchEventType': 'Mål',
        'Period': 1,
        'PeriodName': 'Period 1',
        'Minute': 10,
        'Second': 30,
        'PlayerID': 5,
        'PlayerName': 'Test Player',
        'PlayerShirtNo': 9,
        'PlayerAssistID': null,
        'PlayerAssistName': null,
        'GoalsHomeTeam': 1,
        'GoalsAwayTeam': 0,
        'MatchTeamID': 42,
        'CreatedTS': '2026-09-26T12:00:00.000',
      };

  /// Every key IbyMatchEvent.fromJson reads, all set to null.
  Map<String, dynamic> allKeysNullEvent() => <String, dynamic>{
        'MatchEventID': null,
        'MatchID': null,
        'CompetitionID': null,
        'MatchEventTypeID': null,
        'MatchEventType': null,
        'Period': null,
        'PeriodName': null,
        'Minute': null,
        'Second': null,
        'PlayerID': null,
        'PlayerName': null,
        'PlayerShirtNo': null,
        'PlayerAssistID': null,
        'PlayerAssistName': null,
        'PlayerAssistShirtNo': null,
        'PersonID': null,
        'PersonName': null,
        'PenaltyCode': null,
        'PenaltyName': null,
        'MatchTeamID': null,
        'MatchTeamName': null,
        'MatchTeamShortName': null,
        'GoalsHomeTeam': null,
        'GoalsAwayTeam': null,
        'TimeStamp': null,
        'CreatedTS': null,
        'UpdatedTS': null,
      };

  /// Fully-populated event with every key the entity reads.
  Map<String, dynamic> fullEvent() => <String, dynamic>{
        'MatchEventID': 1,
        'MatchID': 2,
        'CompetitionID': 3,
        'MatchEventTypeID': 4,
        'MatchEventType': 'Utvisning',
        'Period': 2,
        'PeriodName': 'Period 2',
        'Minute': 34,
        'Second': 56,
        'PlayerID': 7,
        'PlayerName': 'Full Player',
        'PlayerShirtNo': 11,
        'PlayerAssistID': 8,
        'PlayerAssistName': 'Assist Player',
        'PlayerAssistShirtNo': 12,
        'PersonID': 9,
        'PersonName': 'Ref Person',
        'PenaltyCode': 'PB2',
        'PenaltyName': 'Utvisning',
        'MatchTeamID': 100,
        'MatchTeamName': 'Home IF',
        'MatchTeamShortName': 'HIF',
        'GoalsHomeTeam': 2,
        'GoalsAwayTeam': 1,
        'TimeStamp': '2026-09-26T12:34:56.000',
        'CreatedTS': '2026-09-26T12:00:00.000',
        'UpdatedTS': '2026-09-26T13:00:00.000',
      };

  /// Asserts that every field except (optionally) matchTeamName matches.
  void expectSameEvent(
    IbyMatchEvent actual,
    IbyMatchEvent expected, {
    String? matchTeamNameOverride,
  }) {
    expect(actual.matchEventId, expected.matchEventId);
    expect(actual.matchId, expected.matchId);
    expect(actual.competitionId, expected.competitionId);
    expect(actual.matchEventTypeId, expected.matchEventTypeId);
    expect(actual.matchEventType, expected.matchEventType);
    expect(actual.period, expected.period);
    expect(actual.periodName, expected.periodName);
    expect(actual.minute, expected.minute);
    expect(actual.second, expected.second);
    expect(actual.playerId, expected.playerId);
    expect(actual.playerName, expected.playerName);
    expect(actual.playerShirtNo, expected.playerShirtNo);
    expect(actual.playerAssistId, expected.playerAssistId);
    expect(actual.playerAssistName, expected.playerAssistName);
    expect(actual.playerAssistShirtNo, expected.playerAssistShirtNo);
    expect(actual.personId, expected.personId);
    expect(actual.personName, expected.personName);
    expect(actual.penaltyCode, expected.penaltyCode);
    expect(actual.penaltyName, expected.penaltyName);
    expect(actual.matchTeamId, expected.matchTeamId);
    expect(actual.matchTeamShortName, expected.matchTeamShortName);
    expect(actual.goalsHomeTeam, expected.goalsHomeTeam);
    expect(actual.goalsAwayTeam, expected.goalsAwayTeam);
    expect(actual.timeStamp, expected.timeStamp);
    expect(actual.createdTS, expected.createdTS);
    expect(actual.updatedTS, expected.updatedTS);
    expect(
      actual.matchTeamName,
      matchTeamNameOverride ?? expected.matchTeamName,
    );
  }

  group('IbyMatchEvent.fromJson (null-tolerant parsing)', () {
    test('F4: live events omit MatchID/PersonID/MatchTeamName/TimeStamp', () {
      final event = IbyMatchEvent.fromJson(f4LiveEvent());

      // Present keys survive.
      expect(event.matchEventId, 123);
      expect(event.matchEventTypeId, 1);
      expect(event.matchEventType, 'Mål');
      expect(event.period, 1);
      expect(event.periodName, 'Period 1');
      expect(event.minute, 10);
      expect(event.second, 30);
      expect(event.playerId, 5);
      expect(event.playerName, 'Test Player');
      expect(event.playerShirtNo, 9);
      expect(event.playerAssistId, 0);
      expect(event.playerAssistName, '');
      expect(event.goalsHomeTeam, 1);
      expect(event.goalsAwayTeam, 0);
      expect(event.matchTeamId, 42);
      expect(event.createdTS, createdTsValue);

      // F4: omitted keys fall back to 0/'' sentinels / epoch / null.
      expect(event.matchId, 0);
      expect(event.competitionId, 0);
      expect(event.personId, 0);
      expect(event.personName, '');
      expect(event.matchTeamName, '');
      expect(event.timeStamp, epoch);
      expect(event.updatedTS, isNull);
    });

    test('F4: parsing the live payload does not throw', () {
      expect(() => IbyMatchEvent.fromJson(f4LiveEvent()), returnsNormally);
    });

    test('all-keys-present-but-null payload parses with 0/"" sentinels', () {
      final event = IbyMatchEvent.fromJson(allKeysNullEvent());

      expect(event.matchEventId, 0);
      expect(event.matchId, 0);
      expect(event.competitionId, 0);
      expect(event.matchEventTypeId, 0);
      expect(event.matchEventType, '');
      expect(event.period, 0);
      expect(event.periodName, '');
      expect(event.minute, 0);
      expect(event.second, 0);
      expect(event.playerId, 0);
      expect(event.playerName, '');
      expect(event.playerAssistId, 0);
      expect(event.playerAssistName, '');
      expect(event.personId, 0);
      expect(event.personName, '');
      expect(event.penaltyCode, '');
      expect(event.penaltyName, '');
      expect(event.matchTeamId, 0);
      expect(event.matchTeamName, '');
      expect(event.goalsHomeTeam, 0);
      expect(event.goalsAwayTeam, 0);

      // Null dates fall back to the epoch sentinel.
      expect(event.timeStamp, epoch);
      expect(event.createdTS, epoch);

      // Nullable fields stay null (no sentinel).
      expect(event.playerShirtNo, isNull);
      expect(event.playerAssistShirtNo, isNull);
      expect(event.matchTeamShortName, isNull);
      expect(event.updatedTS, isNull);
    });

    test('all-keys-present-but-null payload parsing does not throw', () {
      expect(() => IbyMatchEvent.fromJson(allKeysNullEvent()), returnsNormally);
    });

    test('fully-populated event values survive parsing', () {
      final event = IbyMatchEvent.fromJson(fullEvent());

      expect(event.matchEventId, 1);
      expect(event.matchId, 2);
      expect(event.competitionId, 3);
      expect(event.matchEventTypeId, 4);
      expect(event.matchEventType, 'Utvisning');
      expect(event.period, 2);
      expect(event.periodName, 'Period 2');
      expect(event.minute, 34);
      expect(event.second, 56);
      expect(event.playerId, 7);
      expect(event.playerName, 'Full Player');
      expect(event.playerShirtNo, 11);
      expect(event.playerAssistId, 8);
      expect(event.playerAssistName, 'Assist Player');
      expect(event.playerAssistShirtNo, 12);
      expect(event.personId, 9);
      expect(event.personName, 'Ref Person');
      expect(event.penaltyCode, 'PB2');
      expect(event.penaltyName, 'Utvisning');
      expect(event.matchTeamId, 100);
      expect(event.matchTeamName, 'Home IF');
      expect(event.matchTeamShortName, 'HIF');
      expect(event.goalsHomeTeam, 2);
      expect(event.goalsAwayTeam, 1);
      expect(event.timeStamp, DateTime.parse('2026-09-26T12:34:56.000'));
      expect(event.createdTS, createdTsValue);
      expect(event.updatedTS, DateTime.parse('2026-09-26T13:00:00.000'));
    });

    test('copyWith(matchTeamName:) changes only matchTeamName', () {
      final original = IbyMatchEvent.fromJson(fullEvent());
      final renamed = original.copyWith(matchTeamName: 'X');

      expect(renamed.matchTeamName, 'X');
      expectSameEvent(
        renamed,
        original,
        matchTeamNameOverride: 'X',
      );
      // The receiver is untouched.
      expect(original.matchTeamName, 'Home IF');
    });

    test('copyWith() keeps every field unchanged', () {
      final original = IbyMatchEvent.fromJson(fullEvent());
      final same = original.copyWith();

      expectSameEvent(same, original);
      expect(same.matchTeamName, original.matchTeamName);
    });
  });

  group('FIX-B: IbyMatch.fromJson backfills empty event team names', () {
    /// F4-style event for the match-level backfill tests. Only includes a
    /// MatchTeamName key when [matchTeamName] is provided (the live feed
    /// omits it entirely).
    Map<String, dynamic> matchLevelEvent(
      int eventId,
      int matchTeamId, {
      String? matchTeamName,
    }) {
      final event = <String, dynamic>{
        'MatchEventID': eventId,
        'MatchEventTypeID': 1,
        'MatchEventType': 'Mål',
        'Period': 1,
        'PeriodName': 'Period 1',
        'Minute': 10,
        'Second': 30,
        'PlayerID': 5,
        'PlayerName': 'Test Player',
        'PlayerShirtNo': 9,
        'GoalsHomeTeam': 1,
        'GoalsAwayTeam': 0,
        'MatchTeamID': matchTeamId,
        'CreatedTS': '2026-09-26T12:00:00.000',
      };
      if (matchTeamName != null) {
        event['MatchTeamName'] = matchTeamName;
      }
      return event;
    }

    Map<String, dynamic> matchJson() => <String, dynamic>{
          'MatchID': 1706606,
          'MatchNo': '150300004',
          'MatchDateTime': '2026-09-26T12:00:00',
          'MatchStatus': 0,
          'HomeTeam': 'Home IF',
          'AwayTeam': 'Away IBK',
          'HomeMatchTeamID': 100,
          'AwayMatchTeamID': 200,
          'Events': <dynamic>[
            matchLevelEvent(1, 100),
            matchLevelEvent(2, 200),
            matchLevelEvent(3, 999),
            matchLevelEvent(4, 100, matchTeamName: 'Manual'),
          ],
        };

    test(
      'F4+FIX-B: empty team names are backfilled per MatchTeamID, '
      'unmatched and non-empty names stay unchanged', () {
        final match = IbyMatch.fromJson(matchJson());
        final events = match.events;

        expect(events, isNotNull);
        expect(events, hasLength(4));

        // HomeMatchTeamID hit -> HomeTeam.
        expect(events![0].matchTeamId, 100);
        expect(events[0].matchTeamName, 'Home IF');

        // AwayMatchTeamID hit -> AwayTeam.
        expect(events[1].matchTeamId, 200);
        expect(events[1].matchTeamName, 'Away IBK');

        // Unmatched team id -> unchanged (still empty sentinel).
        expect(events[2].matchTeamId, 999);
        expect(events[2].matchTeamName, '');

        // Non-empty name is never overwritten.
        expect(events[3].matchTeamId, 100);
        expect(events[3].matchTeamName, 'Manual');
      },
    );

    test('FIX-B: backfill only touches matchTeamName, all other fields survive',
        () {
      final match = IbyMatch.fromJson(matchJson());
      final events = match.events!;

      expectSameEvent(
        events[0],
        IbyMatchEvent.fromJson(matchLevelEvent(1, 100)),
        matchTeamNameOverride: 'Home IF',
      );
      expectSameEvent(
        events[1],
        IbyMatchEvent.fromJson(matchLevelEvent(2, 200)),
        matchTeamNameOverride: 'Away IBK',
      );
      // Unmatched event is byte-for-byte the un-backfilled parse result.
      expectSameEvent(
        events[2],
        IbyMatchEvent.fromJson(matchLevelEvent(3, 999)),
      );
      // Named event keeps its own name and every other field.
      expectSameEvent(
        events[3],
        IbyMatchEvent.fromJson(
          matchLevelEvent(4, 100, matchTeamName: 'Manual'),
        ),
      );
    });
  });
}