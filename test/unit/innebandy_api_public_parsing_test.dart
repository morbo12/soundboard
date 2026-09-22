import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/pregame_stats.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/player_statistics.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/standings.dart';

/// Regression tests for the IBIS public API (v2/api/public) introduced
/// 2026-09-22. The fixtures in test/fixtures/ibis/ were captured from the live
/// unauthenticated endpoints and reflect the reduced payloads that previously
/// crashed with "type 'Null' is not a subtype of type 'String'".
void main() {
  Map<String, dynamic> loadJson(String name) {
    final file = File('test/fixtures/ibis/$name');
    if (!file.existsSync()) {
      fail(
        'Missing fixture test/fixtures/ibis/$name - cannot validate public API shapes',
      );
    }
    return json.decode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('IbyMatch.fromJson (public API match list payload)', () {
    test('parses all 162 venue matches without throwing', () {
      final list = json.decode(
            File('test/fixtures/ibis/matches.json').readAsStringSync(),
          )
          as List<dynamic>;
      expect(list, isNotEmpty);

      final matches = list
          .map((json) => IbyMatch.fromJson(json as Map<String, dynamic>))
          .toList();
      expect(matches.length, list.length);

      for (final match in matches) {
        expect(match.matchId, greaterThan(0));
        expect(match.homeTeam, isNotEmpty);
        expect(match.awayTeam, isNotEmpty);
        expect(match.matchDateTime, isNotEmpty);
        // CompetitionName and venue coordinates were removed from the payload.
        expect(match.competitionName, isEmpty);
        expect(match.venueLatitude, isNull);
        expect(match.venueLongitude, isNull);
      }
    });

    test('parses single match payload with null referees', () {
      final match = IbyMatch.fromJson(loadJson('match.json'));
      expect(match.matchId, 1706606);
      expect(match.matchNo, '150300004');
      expect(match.matchStatus, 0);
      expect(match.venue, isNotEmpty);
      expect(match.referee1, isNotNull);
    });

    test('parses entry with null referees (defensive)', () {
      final json = loadJson('match.json');
      json['Referee1'] = null;
      json['Referee2'] = null;
      final match = IbyMatch.fromJson(json);
      expect(match.referee1, isNull);
      expect(match.referee2, isNull);
    });
  });

  group('IbyMatchLineup.fromJson (public API lineup payload)', () {
    test('parses lineup without team metadata and null player lists', () {
      final lineup = IbyMatchLineup.fromJson(loadJson('lineups.json'));
      expect(lineup.matchId, 0);
      expect(lineup.homeTeamPlayers, isEmpty);
      expect(lineup.awayTeamPlayers, isEmpty);
      expect(lineup.homeTeamTeamPersons, isEmpty);
      expect(lineup.awayTeamTeamPersons, isEmpty);
    });
  });

  group('PregameStats.fromJson (public API payload)', () {
    test('parses null home/away team names', () {
      final stats = PregameStats.fromJson(loadJson('pregamestats.json'));
      expect(stats.homeTeam, isEmpty);
      expect(stats.awayTeam, isEmpty);
      expect(stats.homeTeamLastGames, isEmpty);
      expect(stats.results, isEmpty);
    });
  });

  group('Standings.fromJson (public API payload)', () {
    test('parses rows without legacy fields', () {
      final standings = Standings.fromJson(loadJson('standings.json'));
      expect(standings.standingsRows, isNotEmpty);
      final row = standings.standingsRows.first;
      expect(row.teamId, greaterThan(0));
      expect(row.teamName, isNotEmpty);
      expect(row.standingsRowId, 0);
      expect(row.teamShortName, isEmpty);
      expect(row.teamStatusName, isEmpty);
      expect(row.timeStamp, isNull);
      expect(row.createdTs, isNull);
      expect(row.updatedTs, isNull);
      expect(row.lastGames, isEmpty);
    });
  });

  group('PlayerStatistics (public API payload)', () {
    test('accepts bare JSON array response', () {
      final data = json.decode(
        File('test/fixtures/ibis/playerstatistics.json').readAsStringSync(),
      );
      final stats = PlayerStatistics.fromResponseData(data);
      expect(stats.playerStatisticsRows, isEmpty);
    });

    test('accepts legacy wrapped response', () {
      final stats = PlayerStatistics.fromResponseData({
        'PlayerStatisticsRows': [
          {
            'PlayerID': 1,
            'PlayerName': 'Test Player',
            'TeamName': 'Test Team',
            'Points': 7,
          },
        ],
      });
      expect(stats.playerStatisticsRows, hasLength(1));
      expect(stats.playerStatisticsRows.first.playerName, 'Test Player');
      expect(stats.playerStatisticsRows.first.imageUrl, isEmpty);
    });
  });
}
