import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/application/api_client_provider.dart';
import 'package:soundboard/features/innebandy_api/application/match_service.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_event.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_intermediate.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_result.dart';

// Define a StateProvider for IbyVenueMatch.
final selectedMatchProvider = StateProvider<IbyMatch>((ref) {
  // Initialize with default values.
  return IbyMatch(
    matchId: 0,
    categoryName: 'Ingen match vald',
    competitionName: 'Ingen match vald',
    matchNo: '0',
    matchDateTime: '2023-11-25T10:00:00',
    homeTeam: 'N/A',
    awayTeam: 'N/A',
    awayTeamLogotypeUrl: '',
    homeTeamLogotypeUrl: '',
    seasonId: 0,
    venue: '0',
    referee1: '',
    referee2: '',
    matchStatus: 0,
    intermediateResults: [
      IbyMatchIntermediateResult(
          matchId: 0, period: 1, goalsHomeTeam: 0, goalsAwayTeam: 0),
      IbyMatchIntermediateResult(
          matchId: 0, period: 2, goalsHomeTeam: 0, goalsAwayTeam: 0),
      IbyMatchIntermediateResult(
          matchId: 0, period: 3, goalsHomeTeam: 0, goalsAwayTeam: 0)
    ],
    goalsHomeTeam: 0,
    goalsAwayTeam: 0,
  );
});

class IbyMatch {
  int matchId;
  String matchNo;
  int? seasonId;
  int? federationId;
  int? categoryId;
  String? categoryName;
  int? ageCategoryId;
  String? ageCategoryName;
  int? competitionId;
  String competitionName;
  int? competitionTypeId;
  int? homeTeamId;
  String homeTeam;
  String? homeTeamShortName;
  String? homeTeamLogotypeUrl;
  int? awayTeamId;
  String awayTeam;
  String? awayTeamShortName;
  String? awayTeamLogotypeUrl;
  String matchDateTime;
  int? venueId;
  String? venue;
  double? venueLatitude;
  double? venueLongitude;
  int? mainVenueId;
  String? mainVenue;
  int? referee1Id;
  String? referee1;
  int? referee2Id;
  String? referee2;
  List<dynamic>? shotsOnGoal;
  List<IbyMatchResult>? results;
  dynamic spectators;
  List<IbyMatchEvent>? events;
  int? round;
  String? roundName;
  dynamic matchDescription;
  int matchStatus;
  int? goalsHomeTeam;
  int? goalsAwayTeam;
  int? homeMatchTeamId;
  int? awayMatchTeamId;
  List<IbyMatchIntermediateResult>? intermediateResults;
  String? lastMatchChange;
  String? lastMatchChangeComment;
  dynamic competitionLogotypeUrl;
  String? ResultCreatedTS;
  String? broadcastUrl;
  String? ticketUrl;
  dynamic arrangingAssociationId;
  String? arrangingAssociation;
  String? note;
  bool? matchTimeMissing;
  bool? postponed;
  bool? abandoned;
  bool? cancelled;
  dynamic extendedMatchInformation;
  String? homeTeamShirtColor;
  String? homeTeamAltShirtColor;
  String? awayTeamShirtColor;
  String? awayTeamAltShirtColor;
  String? timeStamp;
  String? createdTS;
  String? updatedTS;
  IbyMatchLineup? lineup;

  IbyMatch({
    required this.matchId,
    required this.matchNo,
    this.seasonId,
    this.federationId,
    this.categoryId,
    this.categoryName,
    this.ageCategoryId,
    this.ageCategoryName,
    this.competitionId,
    required this.competitionName,
    this.competitionTypeId,
    this.homeTeamId,
    required this.homeTeam,
    this.homeTeamShortName,
    this.homeTeamLogotypeUrl,
    this.awayTeamId,
    required this.awayTeam,
    this.awayTeamShortName,
    this.awayTeamLogotypeUrl,
    required this.matchDateTime,
    this.venueId,
    this.venue,
    this.venueLatitude,
    this.venueLongitude,
    this.mainVenueId,
    this.mainVenue,
    this.referee1Id,
    this.referee1,
    this.referee2Id,
    this.referee2,
    this.shotsOnGoal,
    this.results,
    this.spectators,
    this.events,
    this.round,
    this.roundName,
    this.matchDescription,
    required this.matchStatus,
    this.goalsHomeTeam,
    this.goalsAwayTeam,
    this.homeMatchTeamId,
    this.awayMatchTeamId,
    this.intermediateResults,
    this.lastMatchChange,
    this.lastMatchChangeComment,
    this.competitionLogotypeUrl,
    this.ResultCreatedTS,
    this.broadcastUrl,
    this.ticketUrl,
    this.arrangingAssociationId,
    this.arrangingAssociation,
    this.note,
    this.matchTimeMissing,
    this.postponed,
    this.abandoned,
    this.cancelled,
    this.extendedMatchInformation,
    this.homeTeamShirtColor,
    this.homeTeamAltShirtColor,
    this.awayTeamShirtColor,
    this.awayTeamAltShirtColor,
    this.timeStamp,
    this.createdTS,
    this.updatedTS,
  });

  factory IbyMatch.fromJson(Map<String, dynamic> json) {
    return IbyMatch(
      matchId: json['MatchID'],
      matchNo: json['MatchNo'],
      seasonId: json['SeasonID'],
      federationId: json['FederationID'],
      categoryId: json['CategoryID'],
      categoryName: json['CategoryName'],
      ageCategoryId: json['AgeCategoryID'],
      ageCategoryName: json['AgeCategoryName'],
      competitionId: json['CompetitionID'],
      competitionName: json['CompetitionName'],
      competitionTypeId: json['CompetitionTypeID'],
      homeTeamId: json['HomeTeamID'],
      homeTeam: json['HomeTeam'],
      homeTeamShortName: json['HomeTeamShortName'],
      homeTeamLogotypeUrl: json['HomeTeamLogotypeUrl'],
      awayTeamId: json['AwayTeamID'],
      awayTeam: json['AwayTeam'],
      awayTeamShortName: json['AwayTeamShortName'],
      awayTeamLogotypeUrl: json['AwayTeamLogotypeUrl'],
      matchDateTime: json['MatchDateTime'],
      venueId: json['VenueID'],
      venue: json['Venue'],
      venueLatitude: json['VenueLatitude'].toDouble(),
      venueLongitude: json['VenueLongitude'].toDouble(),
      mainVenueId: json['MainVenueID'],
      mainVenue: json['MainVenue'],
      referee1Id: json['Referee1ID'],
      referee1: json['Referee1'],
      referee2Id: json['Referee2ID'],
      referee2: json['Referee2'],
      shotsOnGoal: json['ShotsOnGoal'],
      results: json['Results'] != null
          ? List<IbyMatchResult>.from(
              json['Results'].map((event) => IbyMatchResult.fromJson(event)))
          : null,
      spectators: json['Spectators'],
      events: json['Events'] != null
          ? List<IbyMatchEvent>.from(
              json['Events'].map((event) => IbyMatchEvent.fromJson(event)))
          : null,
      round: json['Round'],
      roundName: json['RoundName'],
      matchDescription: json['MatchDescription'],
      matchStatus: json['MatchStatus'],
      goalsHomeTeam: json['GoalsHomeTeam'],
      goalsAwayTeam: json['GoalsAwayTeam'],
      homeMatchTeamId: json['HomeMatchTeamID'],
      awayMatchTeamId: json['AwayMatchTeamID'],
      intermediateResults: json['IntermediateResults'] != null
          ? List<IbyMatchIntermediateResult>.from(json['IntermediateResults']
              .map((event) => IbyMatchIntermediateResult.fromJson(event)))
          : null,
      lastMatchChange: json['LastMatchChange'],
      lastMatchChangeComment: json['LastMatchChangeComment'],
      competitionLogotypeUrl: json['CompetitionLogotypeUrl'],
      ResultCreatedTS: json['ResultCreatedTS'],
      broadcastUrl: json['BroadcastUrl'],
      ticketUrl: json['TicketUrl'],
      arrangingAssociationId: json['ArrangingAssociationID'],
      arrangingAssociation: json['ArrangingAssociation'],
      note: json['Note'],
      matchTimeMissing: json['MatchTimeMissing'],
      postponed: json['Postponed'],
      abandoned: json['Abandoned'],
      cancelled: json['Cancelled'],
      extendedMatchInformation: json['ExtendedMatchInformation'],
      homeTeamShirtColor: json['HomeTeamShirtColor'],
      homeTeamAltShirtColor: json['HomeTeamAltShirtColor'],
      awayTeamShirtColor: json['AwayTeamShirtColor'],
      awayTeamAltShirtColor: json['AwayTeamAltShirtColor'],
      timeStamp: json['TimeStamp'],
      createdTS: json['CreatedTS'],
      updatedTS: json['UpdatedTS'],
    );
  }

  // IbyMatchIntermediateResult? getResultForPeriod(int period) {
  //   return intermediateResults!.firstWhere(
  //     (result) => result.period == period,
  //     orElse: () => IbyMatchIntermediateResult(
  //       matchID: matchId,
  //       period: period,
  //       goalsHomeTeam: 0,
  //       goalsAwayTeam: 0,
  //     ),
  //   );
  // }

  Future<void> fetchLineup(WidgetRef ref) async {
    // Assuming you have a function getLineupByMatchId that makes the API call.
    lineup = await getLineupByMatchId(matchId, ref);
  }

  Future<IbyMatchLineup> getLineupByMatchId(int matchId, ref) async {
    if (kDebugMode) {
      print("_getLineup");
    }

    // final apiClient = APIClient();
    final apiClient = ref.watch(apiClientProvider);

    final matchService = MatchService(apiClient);

    //  apiService = APIService();
    //  accessToken = await apiService.getAccessToken();
    // if (kDebugMode) {
    //   print("SettingsScreenStateSeason: $accessToken");
    // }
    IbyMatchLineup lineup =
        await matchService.getLineupOfMatch(matchId: matchId);
    return lineup;
  }

  String stripTeamSuffix(String teamName) {
    return teamName.replaceAll(RegExp(r' \([A-Z]\)'), '');
  }

  // Getter for the full SSML content
  String get ssml {
    return generateSsml();
  }

  // Getters for the three SSML parts
  String get introSsml {
    return _generateWelcomeMessage();
  }

  String get homeTeamSsml {
    return _generateHomeTeamLineup();
  }

  String get awayTeamSsml {
    return _generateAwayTeamLineup();
  }

  String generateSsml() {
    String ssml;
    if (lineup == null) {
      // ssml =
      // '<speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" version="1.0" xml:lang="en-US">\n<lang xml:lang="sv-SE">';
      // ssml += '<mstts:express-as style="sports_commentary">';
      ssml = _generateTestSsml();
      // ssml += "</mstts:express-as></lang></speak>";
    } else {
      // ssml =
      // '<speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="sv-SE">\n<lang xml:lang="sv-SE">';

// Split into intro ssml, home ssml and away ssml
// sync run of home and away tts to jingles.

      ssml = _generateWelcomeMessage();
      ssml += _generateAwayTeamLineup();
      ssml += _generateHomeTeamLineup();
      ssml += _generateRefereeMessage();
      // ssml += "</lang></speak>";
    }
    return ssml;
  }

  String _generateTestSsml() {
    String testssml = """
Välkomna till Testhallen!
<break time="500ms" />
Testlaget hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan testlag blå och testlag vit
Nummer 11, <say-as interpret-as='name'>Noah Zetterholm</say-as>,
Nummer <lang xml:lang="sv-SE">27</lang>, <say-as interpret-as='name'>Eddie Rylin</say-as>,
Nummer 42, <say-as interpret-as='name'>Henry Dahlström</say-as>,
Nummer 82, <say-as interpret-as='name'>Liam Sandberg</say-as>,
Välkomna! Testtext är nu slut
""";
    return testssml;
  }

  String _generateWelcomeMessage() {
    final String ssml;
    if (lineup == null) {
      ssml = """
    Välkomna till Testhallen!
    <break time="1000ms" />
    Testlaget hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan Hemmalaget och Bortalaget
    <break time="1000ms" />
    """;
    } else {
      ssml = """
    Välkomna till $venue!
    <break time="1000ms" />
    ${stripTeamSuffix(homeTeam)} hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan ${stripTeamSuffix(homeTeam)} och ${stripTeamSuffix(awayTeam)}
    <break time="1000ms" />
    """;
    }
    return ssml;
  }

  String _generateHomeTeamLineup() {
    String ssml;
    if (lineup == null) {
      ssml = """
    Hemmalaget ställer upp med följande spelare<break time='750ms' />
    Nummer 11, <say-as interpret-as='name'>Noah Zetterholm</say-as>,
    Nummer 27, <say-as interpret-as='name'>Eddie Rylin</say-as>,
    Nummer 42, <say-as interpret-as='name'>Henry Dahlström</say-as>,
    Nummer 82, <say-as interpret-as='name'>Liam Sandberg</say-as>,
    Välkomna! Testtext är nu slut
    """;
    } else {
      ssml =
          "${stripTeamSuffix(homeTeam)} ställer upp med följande spelare<break time='750ms' />";
      String homeGoalie =
          "Dagens målvakt är inte inlagd i truppen<break time='750ms' />\n";
      for (TeamPlayer player in lineup!.homeTeamPlayers) {
        if (player.position == "Målvakt") {
          homeGoalie =
              "Dagens målvakt är <say-as interpret-as='name'>${player.name}</say-as><break time='500ms' />\n";
        } else {
          ssml += player.shirtNo == null
              ? "<say-as interpret-as='name'>${player.name}</say-as><break time='750ms' />\n"
              : "Nummer ${player.shirtNo}, <say-as interpret-as='name'>${player.name}</say-as><break time='750ms' />\n";
        }
      }
      ssml += homeGoalie;
      ssml += "<break time=\"500ms\" />\n";
      ssml +=
          "Ledare för ${stripTeamSuffix(homeTeam)} är<break time='750ms' />";
      for (TeamTeamPerson teamPerson in lineup!.homeTeamTeamPersons) {
        ssml +=
            "<say-as interpret-as='name'>${teamPerson.name}</say-as><break time='1000ms' />\n";
      }
      ssml += "<break time=\"1000ms\" />\n";
    }
    return ssml;
  }

  String _generateAwayTeamLineup() {
    String ssml;
    if (lineup == null) {
      ssml = """
    Bortalaget ställer upp med följande spelare<break time='750ms' />
    Nummer 11, <say-as interpret-as='name'>Noah Zetterholm</say-as>,
    Nummer 27, <say-as interpret-as='name'>Eddie Rylin</say-as>,
    Nummer 42, <say-as interpret-as='name'>Henry Dahlström</say-as>,
    Nummer 82, <say-as interpret-as='name'>Liam Sandberg</say-as>,
    """;
    } else {
      ssml =
          "${stripTeamSuffix(awayTeam)} ställer upp med följande spelare<break time='750ms' />\n";
      String awayGoalie =
          "Dagens målvakt är inte inlagd i truppen<break time='750ms' />\n";
      for (TeamPlayer player in lineup!.awayTeamPlayers) {
        if (player.position == "Målvakt") {
          awayGoalie =
              "Dagens målvakt är <say-as interpret-as='name'>${player.name}</say-as>,\n";
        } else {
          ssml += player.shirtNo == null
              ? "<say-as interpret-as='name'>${player.name}</say-as><break time='750ms' />\n"
              : "Nummer ${player.shirtNo}, <say-as interpret-as='name'>${player.name}</say-as><break time='750ms' />\n";
        }
      }
      ssml += awayGoalie;
      ssml += "<break time=\"500ms\" />\n";
      ssml += "Ledare för ${stripTeamSuffix(awayTeam)} är,";
      for (TeamTeamPerson teamPerson in lineup!.awayTeamTeamPersons) {
        ssml +=
            "<say-as interpret-as='name'>${teamPerson.name}</say-as><break time='750ms' />\n";
      }
      ssml += "<break time=\"1000ms\" />\n";
    }
    return ssml;
  }

  String _generateRefereeMessage() {
    return "Domare i denna match är,,\n$referee1 och $referee2\n";
  }
}
