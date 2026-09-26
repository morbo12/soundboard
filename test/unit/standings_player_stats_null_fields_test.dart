import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/player_statistics.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/standings.dart';

/// Regression tests for IBIS standings / playerstatistics payload hardening
/// (2026-09-26).
///
/// F2: standings rows OMIT StandingsRowID, CompetitionID, TeamShortName,
/// TeamStatusName, TimeStamp, CreatedTS and UpdatedTS entirely (other keys
/// like TeamName/points are still present).
///
/// F3: /playerstatistics returns a bare JSON array `[]` (not an object) when
/// empty; other list endpoints may do the same.
void main() {
  /// F2-style standings row: the omitted legacy keys are not present at all.
  Map<String, dynamic> f2StandingsRow() => <String, dynamic>{
        'TeamID': 55,
        'TeamName': 'Test IBK',
        'TeamLogotypeUrl': 'https://example.com/logo.png',
        'PlayedMatchesHome': 5,
        'PlayedMatchesAway': 4,
        'WinsHome': 3,
        'WinsAway': 2,
        'SdWinsHome': 1,
        'SdWinsAway': 0,
        'DrawsHome': 1,
        'DrawsAway': 1,
        'LossesHome': 1,
        'LossesAway': 1,
        'GoalsScoredHome': 20,
        'GoalsScoredAway': 15,
        'GoalsAgainstHome': 10,
        'GoalsAgainstAway': 12,
        'ScoringDiff': 13,
        'Points': 12,
        'Position': 2,
        'LastGames': <dynamic>[1, 0, -1],
        'TeamStatusID': 1,
        // F2: StandingsRowID, CompetitionID, TeamShortName, TeamStatusName,
        // TimeStamp, CreatedTS and UpdatedTS are omitted entirely.
      };

  group('StandingsRow.fromJson (F2: rows omit legacy keys)', () {
    test(
      'F2: omitted StandingsRowID/CompetitionID/TeamShortName/TeamStatusName/'
      'TimeStamp/CreatedTS/UpdatedTS fall back to defaults', () {
        final standings = Standings.fromJson(<String, dynamic>{
          'StandingsRows': <dynamic>[f2StandingsRow()],
        });

        expect(standings.standingsRows, hasLength(1));
        final row = standings.standingsRows.first;

        // Omitted keys -> 0/'' sentinels and null dates.
        expect(row.standingsRowId, 0);
        expect(row.competitionId, 0);
        expect(row.teamShortName, '');
        expect(row.teamStatusName, '');
        expect(row.timeStamp, isNull);
        expect(row.createdTs, isNull);
        expect(row.updatedTs, isNull);

        // Present keys survive.
        expect(row.teamId, 55);
        expect(row.teamName, 'Test IBK');
        expect(row.teamLogotypeUrl, 'https://example.com/logo.png');
        expect(row.playedMatchesHome, 5);
        expect(row.playedMatchesAway, 4);
        expect(row.winsHome, 3);
        expect(row.winsAway, 2);
        expect(row.sdWinsHome, 1);
        expect(row.sdWinsAway, 0);
        expect(row.drawsHome, 1);
        expect(row.drawsAway, 1);
        expect(row.lossesHome, 1);
        expect(row.lossesAway, 1);
        expect(row.goalsScoredHome, 20);
        expect(row.goalsScoredAway, 15);
        expect(row.goalsAgainstHome, 10);
        expect(row.goalsAgainstAway, 12);
        expect(row.scoringDiff, 13);
        expect(row.points, 12);
        expect(row.position, 2);
        expect(row.lastGames, [1, 0, -1]);
        expect(row.teamStatusId, 1);
      },
    );

    test('F2: parsing a legacy-key-free row does not throw', () {
      expect(
        () => Standings.fromJson(<String, dynamic>{
          'StandingsRows': <dynamic>[f2StandingsRow()],
        }),
        returnsNormally,
      );
    });
  });

  group('Standings.fromJson (response shape normalization)', () {
    test('bare empty JSON array normalizes to zero rows', () {
      final standings = Standings.fromJson(<dynamic>[]);
      expect(standings.standingsRows, isEmpty);
    });

    test('wrapper with null StandingsRows key normalizes to zero rows', () {
      final standings = Standings.fromJson(<String, dynamic>{
        'StandingsRows': null,
      });
      expect(standings.standingsRows, isEmpty);
    });

    test('wrapper with missing StandingsRows key normalizes to zero rows', () {
      final standings = Standings.fromJson(<String, dynamic>{'Other': 1});
      expect(standings.standingsRows, isEmpty);
    });

    test('null response normalizes to zero rows', () {
      final standings = Standings.fromJson(null);
      expect(standings.standingsRows, isEmpty);
    });

    test('non-map non-list response normalizes to zero rows', () {
      final standings = Standings.fromJson('nonsense');
      expect(standings.standingsRows, isEmpty);
    });

    test('F2+bare-array: bare array of legacy-key-free rows parses with '
        'defaults', () {
      final standings = Standings.fromJson(<dynamic>[
        <String, dynamic>{
          'TeamID': 9,
          'TeamName': 'Barren FC',
        },
      ]);

      expect(standings.standingsRows, hasLength(1));
      final row = standings.standingsRows.first;
      expect(row.teamId, 9);
      expect(row.teamName, 'Barren FC');
      // Every omitted key gets its neutral default.
      expect(row.standingsRowId, 0);
      expect(row.competitionId, 0);
      expect(row.teamShortName, '');
      expect(row.teamStatusName, '');
      expect(row.teamLogotypeUrl, '');
      expect(row.points, 0);
      expect(row.position, 0);
      expect(row.lastGames, isEmpty);
      expect(row.timeStamp, isNull);
      expect(row.createdTs, isNull);
      expect(row.updatedTs, isNull);
    });
  });

  group('PlayerStatistics (F3: bare array responses)', () {
    test('F3: bare empty JSON array yields zero rows without throwing', () {
      expect(
        () => PlayerStatistics.fromResponseData(<dynamic>[]),
        returnsNormally,
      );
      final stats = PlayerStatistics.fromResponseData(<dynamic>[]);
      expect(stats.playerStatisticsRows, isEmpty);
    });

    test('null response yields zero rows without throwing', () {
      final stats = PlayerStatistics.fromResponseData(null);
      expect(stats.playerStatisticsRows, isEmpty);
    });

    test('non-map non-list response yields zero rows without throwing', () {
      final stats = PlayerStatistics.fromResponseData('nonsense');
      expect(stats.playerStatisticsRows, isEmpty);
    });

    test('F3: bare array with rows parses each row', () {
      final stats = PlayerStatistics.fromResponseData(<dynamic>[
        <String, dynamic>{
          'PlayerID': 3,
          'PlayerName': 'Bare Row',
          'Points': 2,
        },
      ]);

      expect(stats.playerStatisticsRows, hasLength(1));
      final row = stats.playerStatisticsRows.first;
      expect(row.playerId, 3);
      expect(row.playerName, 'Bare Row');
      expect(row.points, 2);
    });

    test('map form with a row that omits optional keys gets 0/"" defaults', () {
      final stats = PlayerStatistics.fromResponseData(<String, dynamic>{
        'PlayerStatisticsRows': <dynamic>[
          <String, dynamic>{
            'PlayerID': 7,
            'PlayerName': 'Pia Player',
          },
        ],
      });

      expect(stats.playerStatisticsRows, hasLength(1));
      final row = stats.playerStatisticsRows.first;
      expect(row.playerId, 7);
      expect(row.playerName, 'Pia Player');

      // Every other key was omitted -> neutral defaults.
      expect(row.seasonId, 0);
      expect(row.seasonName, '');
      expect(row.associationId, 0);
      expect(row.associationName, '');
      expect(row.teamId, 0);
      expect(row.teamName, '');
      expect(row.teamShortName, '');
      expect(row.matchesPlayed, 0);
      expect(row.goalsScored, 0);
      expect(row.assists, 0);
      expect(row.points, 0);
      expect(row.penaltyMinutes, 0);
      expect(row.goalsScoredPp, 0);
      expect(row.goalsScoredBp, 0);
      expect(row.assistsPp, 0);
      expect(row.assistsBp, 0);
      expect(row.pointsPp, 0);
      expect(row.pointsBp, 0);
      expect(row.imageUrl, '');
    });
  });
}