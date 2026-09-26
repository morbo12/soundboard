import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';

/// Regression tests for IBIS lineups payload hardening (2026-09-26).
///
/// F1: the lineups endpoint returns an all-null shell object
/// ({"MatchID": null, ...}) - every key present but null - when no lineup is
/// published for the match. IbyMatchLineup.fromJson must fall back to
/// 0/''/[] instead of crashing on null.
void main() {
  group('IbyMatchLineup.fromJson (null-safe shell parsing)', () {
    test('F1: all-null shell object parses with 0/"" defaults and empty lists',
        () {
      // F1: every key the entity reads is present but null.
      final lineup = IbyMatchLineup.fromJson(<String, dynamic>{
        'MatchID': null,
        'HomeTeamID': null,
        'HomeTeam': null,
        'HomeTeamShortName': null,
        'HomeTeamLogotypeUrl': null,
        'AwayTeamID': null,
        'AwayTeam': null,
        'AwayTeamShortName': null,
        'AwayTeamLogotypeUrl': null,
        'HomeTeamPlayers': null,
        'AwayTeamPlayers': null,
        'HomeTeamTeamPersons': null,
        'AwayTeamTeamPersons': null,
      });

      // Numeric defaults.
      expect(lineup.matchId, 0);
      expect(lineup.homeTeamId, 0);
      expect(lineup.awayTeamId, 0);

      // String defaults.
      expect(lineup.homeTeam, '');
      expect(lineup.homeTeamShortName, '');
      expect(lineup.homeTeamLogotypeUrl, '');
      expect(lineup.awayTeam, '');
      expect(lineup.awayTeamShortName, '');
      expect(lineup.awayTeamLogotypeUrl, '');

      // Player / team-person lists default to empty.
      expect(lineup.homeTeamPlayers, isEmpty);
      expect(lineup.awayTeamPlayers, isEmpty);
      expect(lineup.homeTeamTeamPersons, isEmpty);
      expect(lineup.awayTeamTeamPersons, isEmpty);
    });

    test('F1: parsing the all-null shell object does not throw', () {
      expect(
        () => IbyMatchLineup.fromJson(<String, dynamic>{
          'MatchID': null,
          'HomeTeamID': null,
          'HomeTeam': null,
          'HomeTeamShortName': null,
          'HomeTeamLogotypeUrl': null,
          'AwayTeamID': null,
          'AwayTeam': null,
          'AwayTeamShortName': null,
          'AwayTeamLogotypeUrl': null,
          'HomeTeamPlayers': null,
          'AwayTeamPlayers': null,
          'HomeTeamTeamPersons': null,
          'AwayTeamTeamPersons': null,
        }),
        returnsNormally,
      );
    });

    test('fully-populated lineup values survive parsing', () {
      final lineup = IbyMatchLineup.fromJson(<String, dynamic>{
        'MatchID': 1706606,
        'HomeTeamID': 10,
        'HomeTeam': 'Home IF',
        'HomeTeamShortName': 'HIF',
        'HomeTeamLogotypeUrl': 'https://example.com/home.png',
        'AwayTeamID': 20,
        'AwayTeam': 'Away IBK',
        'AwayTeamShortName': 'AIB',
        'AwayTeamLogotypeUrl': 'https://example.com/away.png',
        'HomeTeamPlayers': <dynamic>[
          <String, dynamic>{
            'PlayerID': 1,
            'PersonID': 11,
            'TeamID': 10,
            'Name': 'Anna Andersson',
            'Age': 24,
            'ShirtNo': 7,
            'PositionID': 3,
            'Position': 'Mittfält',
            'Captain': true,
          },
          <String, dynamic>{
            'PlayerID': 2,
            'PersonID': 12,
            'TeamID': 10,
            'Name': 'Berit Berg',
            'Age': 21,
            'ShirtNo': 9,
            'PositionID': 4,
            'Position': 'Forward',
            'Captain': false,
          },
        ],
        'AwayTeamPlayers': <dynamic>[
          <String, dynamic>{
            'PlayerID': 3,
            'PersonID': 21,
            'TeamID': 20,
            'Name': 'Cissi Crona',
            'Age': 27,
            'ShirtNo': 1,
            'PositionID': 1,
            'Position': 'Målvakt',
            'Captain': true,
          },
        ],
        'HomeTeamTeamPersons': <dynamic>[
          <String, dynamic>{
            'TeamID': 10,
            'PersonID': 31,
            'Name': 'Coach Home',
            'RoleID': 1,
            'RoleName': 'Tränare',
          },
        ],
        'AwayTeamTeamPersons': <dynamic>[
          <String, dynamic>{
            'TeamID': 20,
            'PersonID': 41,
            'Name': 'Coach Away',
            'RoleID': 1,
            'RoleName': 'Tränare',
          },
        ],
      });

      expect(lineup.matchId, 1706606);
      expect(lineup.homeTeamId, 10);
      expect(lineup.homeTeam, 'Home IF');
      expect(lineup.homeTeamShortName, 'HIF');
      expect(lineup.homeTeamLogotypeUrl, 'https://example.com/home.png');
      expect(lineup.awayTeamId, 20);
      expect(lineup.awayTeam, 'Away IBK');
      expect(lineup.awayTeamShortName, 'AIB');
      expect(lineup.awayTeamLogotypeUrl, 'https://example.com/away.png');

      expect(lineup.homeTeamPlayers, hasLength(2));
      final captain = lineup.homeTeamPlayers[0];
      expect(captain.playerId, 1);
      expect(captain.personId, 11);
      expect(captain.teamId, 10);
      expect(captain.name, 'Anna Andersson');
      expect(captain.age, 24);
      expect(captain.shirtNo, 7);
      expect(captain.positionId, 3);
      expect(captain.position, 'Mittfält');
      expect(captain.captain, isTrue);
      final striker = lineup.homeTeamPlayers[1];
      expect(striker.playerId, 2);
      expect(striker.name, 'Berit Berg');
      expect(striker.shirtNo, 9);
      expect(striker.captain, isFalse);

      expect(lineup.awayTeamPlayers, hasLength(1));
      final keeper = lineup.awayTeamPlayers[0];
      expect(keeper.playerId, 3);
      expect(keeper.personId, 21);
      expect(keeper.teamId, 20);
      expect(keeper.name, 'Cissi Crona');
      expect(keeper.age, 27);
      expect(keeper.shirtNo, 1);
      expect(keeper.positionId, 1);
      expect(keeper.position, 'Målvakt');
      expect(keeper.captain, isTrue);

      expect(lineup.homeTeamTeamPersons, hasLength(1));
      final homeCoach = lineup.homeTeamTeamPersons[0];
      expect(homeCoach.teamId, 10);
      expect(homeCoach.personId, 31);
      expect(homeCoach.name, 'Coach Home');
      expect(homeCoach.roleId, 1);
      expect(homeCoach.roleName, 'Tränare');

      expect(lineup.awayTeamTeamPersons, hasLength(1));
      final awayCoach = lineup.awayTeamTeamPersons[0];
      expect(awayCoach.teamId, 20);
      expect(awayCoach.personId, 41);
      expect(awayCoach.name, 'Coach Away');
      expect(awayCoach.roleId, 1);
      expect(awayCoach.roleName, 'Tränare');
    });

    test('missing player list keys yield empty lists without crashing', () {
      // No list keys at all - only scalar metadata.
      final lineup = IbyMatchLineup.fromJson(<String, dynamic>{
        'MatchID': 5,
        'HomeTeamID': 10,
        'HomeTeam': 'Home IF',
        'AwayTeamID': 20,
        'AwayTeam': 'Away IBK',
      });

      expect(lineup.matchId, 5);
      expect(lineup.homeTeam, 'Home IF');
      expect(lineup.awayTeam, 'Away IBK');
      expect(lineup.homeTeamPlayers, isEmpty);
      expect(lineup.awayTeamPlayers, isEmpty);
      expect(lineup.homeTeamTeamPersons, isEmpty);
      expect(lineup.awayTeamTeamPersons, isEmpty);
    });

    test('null player list keys yield empty lists without crashing', () {
      final lineup = IbyMatchLineup.fromJson(<String, dynamic>{
        'MatchID': 6,
        'HomeTeamPlayers': null,
        'AwayTeamPlayers': null,
        'HomeTeamTeamPersons': null,
        'AwayTeamTeamPersons': null,
      });

      expect(lineup.homeTeamPlayers, isEmpty);
      expect(lineup.awayTeamPlayers, isEmpty);
      expect(lineup.homeTeamTeamPersons, isEmpty);
      expect(lineup.awayTeamTeamPersons, isEmpty);
    });

    test('mixed missing/null/empty list keys all yield empty lists', () {
      final lineup = IbyMatchLineup.fromJson(<String, dynamic>{
        'MatchID': 7,
        'HomeTeamPlayers': null,
        'AwayTeamPlayers': <dynamic>[],
        // HomeTeamTeamPersons / AwayTeamTeamPersons keys missing entirely.
      });

      expect(lineup.matchId, 7);
      expect(lineup.homeTeamPlayers, isEmpty);
      expect(lineup.awayTeamPlayers, isEmpty);
      expect(lineup.homeTeamTeamPersons, isEmpty);
      expect(lineup.awayTeamTeamPersons, isEmpty);
    });
  });
}