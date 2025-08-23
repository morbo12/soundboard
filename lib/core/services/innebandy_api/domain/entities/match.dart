import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/api_client_provider.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/match_service.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_event.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_intermediate.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_result.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/providers/manual_lineup_providers.dart';
import 'package:soundboard/core/properties.dart';

import 'package:soundboard/core/utils/logger.dart';

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
        matchId: 0,
        period: 1,
        goalsHomeTeam: 0,
        goalsAwayTeam: 0,
      ),
      IbyMatchIntermediateResult(
        matchId: 0,
        period: 2,
        goalsHomeTeam: 0,
        goalsAwayTeam: 0,
      ),
      IbyMatchIntermediateResult(
        matchId: 0,
        period: 3,
        goalsHomeTeam: 0,
        goalsAwayTeam: 0,
      ),
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
  final Logger logger = const Logger('IbyMatch');

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
              json['Results'].map((event) => IbyMatchResult.fromJson(event)),
            )
          : null,
      spectators: json['Spectators'],
      events: json['Events'] != null
          ? List<IbyMatchEvent>.from(
              json['Events'].map((event) => IbyMatchEvent.fromJson(event)),
            )
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
          ? List<IbyMatchIntermediateResult>.from(
              json['IntermediateResults'].map(
                (event) => IbyMatchIntermediateResult.fromJson(event),
              ),
            )
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

  // In your IbyMatch class
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is IbyMatch && other.matchId == matchId;
  }

  @override
  int get hashCode => matchId.hashCode;

  /// Fetches the lineup for this match and updates both the instance and provider.
  ///
  /// This method handles errors gracefully and ensures the lineup is available
  /// both on the match instance and in the global provider state.
  Future<void> fetchLineup(WidgetRef ref) async {
    try {
      logger.d("Fetching lineup for match $matchId");
      lineup = await getLineupByMatchId(matchId, ref);

      // Update the global lineup provider
      ref.read(lineupProvider.notifier).state = lineup!;

      logger.d("Successfully fetched lineup for match $matchId");
    } catch (e) {
      logger.e("Failed to fetch lineup for match $matchId: $e");
      rethrow; // Re-throw to allow caller to handle the error
    }
  }

  /// Gets the lineup for a specific match ID.
  ///
  /// [matchId] The ID of the match to fetch lineup for
  /// [ref] The WidgetRef for accessing providers
  ///
  /// Returns the lineup data for the match
  /// Throws an exception if the API call fails
  Future<IbyMatchLineup> getLineupByMatchId(int matchId, WidgetRef ref) async {
    logger.d("Getting lineup for match $matchId");

    final apiClient = ref.watch(apiClientProvider);
    final matchService = MatchService(apiClient);

    try {
      final lineup = await matchService.getLineupOfMatch(matchId: matchId);
      return lineup;
    } catch (e) {
      logger.e("API call failed for match lineup $matchId: $e");
      rethrow;
    }
  }

  String stripTeamSuffix(String teamName) {
    return teamName.replaceAll(RegExp(r' \([A-Z]\)'), '');
  }

  // Getter for the full SSML content - deprecated, use generateSsml(ref) instead
  String get ssml {
    throw UnsupportedError(
      'Use generateSsml(ref) instead to access lineup data from provider',
    );
  }

  // Getters for the three SSML parts - these now require a ref to access the provider
  String introSsml(WidgetRef ref) {
    return _generateWelcomeMessage(ref);
  }

  String homeTeamSsml(WidgetRef ref) {
    return _generateHomeTeamLineup(ref);
  }

  String awayTeamSsml(WidgetRef ref) {
    return _generateAwayTeamLineup(ref);
  }

  /// Generates complete SSML for the match including intro, away team, home team, and referee info
  String generateSsml(WidgetRef ref) {
    final lineup = ref.read(effectiveLineupProvider);
    String ssml;

    // Check if we have valid lineup data (not the default empty state)
    if (lineup.matchId == 0 || lineup.homeTeamPlayers.isEmpty) {
      logger.d("No valid lineup data found, using test SSML");
      ssml = _generateTestSsml();
    } else {
      logger.d("Valid lineup data found, generating real SSML");
      ssml = _generateWelcomeMessage(ref);
      ssml += _generateAwayTeamLineup(ref);
      ssml += _generateHomeTeamLineup(ref);
      ssml += _generateRefereeMessage();
    }
    return ssml;
  }

  String _generateTestSsml() {
    final settings = SettingsBox();
    final voiceName = settings.azVoiceName;
    String testssml =
        """<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
Välkomna till Testhallen!
<break time="500ms"/>
Testlaget hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan testlag blå och testlag vit
Nummer 11, <say-as interpret-as="name">Noah Zetterholm</say-as>,
Nummer <lang xml:lang="sv-SE">27</lang>, <say-as interpret-as="name">Eddie Rylin</say-as>,
Nummer 42, <say-as interpret-as="name">Henry Dahlström</say-as>,
Nummer 82, <say-as interpret-as="name">Liam Sandberg</say-as>,
Välkomna! Testtext är nu slut
</voice>
</speak>""";
    return testssml;
  }

  String _generateWelcomeMessage(WidgetRef ref) {
    final lineup = ref.read(lineupProvider);
    final settings = SettingsBox();
    final voiceName = settings.azVoiceName;
    final String ssml;

    // Check if we have valid lineup data
    if (lineup.matchId == 0 || lineup.homeTeamPlayers.isEmpty) {
      ssml =
          """<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
Välkomna till Testhallen!
<break time="1000ms"/>
Testlaget hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan Hemmalaget och Bortalaget
<break time="1000ms"/>
</voice>
</speak>""";
    } else {
      ssml =
          """<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
Välkomna till $venue!
<break time="1000ms"/>
${stripTeamSuffix(homeTeam)} hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan ${stripTeamSuffix(homeTeam)} och ${stripTeamSuffix(awayTeam)}
<break time="1000ms"/>
</voice>
</speak>""";
    }
    return ssml;
  }

  String _generateHomeTeamLineup(WidgetRef ref) {
    final lineup = ref.read(effectiveLineupProvider);
    final settings = SettingsBox();
    final voiceName = settings.azVoiceName;
    String ssml;

    // Check if we have valid lineup data
    if (lineup.matchId == 0 || lineup.homeTeamPlayers.isEmpty) {
      ssml =
          """<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
Hemmalaget ställer upp med följande spelare<break time="750ms"/>
Nummer 11, <say-as interpret-as="name">Noah Zetterholm</say-as>,
Nummer 27, <say-as interpret-as="name">Eddie Rylin</say-as>,
Nummer 42, <say-as interpret-as="name">Henry Dahlström</say-as>,
Nummer 82, <say-as interpret-as="name">Liam Sandberg</say-as>,
Välkomna! Testtext är nu slut
</voice>
</speak>""";
    } else {
      ssml =
          "<speak version=\"1.0\" xmlns=\"http://www.w3.org/2001/10/synthesis\" xmlns:mstts=\"https://www.w3.org/2001/mstts\" xml:lang=\"sv-SE\">\n<voice name=\"$voiceName\">\n${stripTeamSuffix(homeTeam)} ställer upp med följande spelare<break time=\"750ms\"/>\n";
      String homeGoalie =
          "Dagens målvakt är inte inlagd i truppen<break time=\"750ms\"/>\n";
      for (TeamPlayer player in lineup.homeTeamPlayers) {
        if (player.position == "Målvakt") {
          homeGoalie =
              "Dagens målvakt är <say-as interpret-as=\"name\">${player.name}</say-as><break time=\"500ms\"/>\n";
        } else {
          ssml += player.shirtNo == null
              ? "<say-as interpret-as=\"name\">${player.name}</say-as><break time=\"750ms\"/>\n"
              : "Nummer ${player.shirtNo}, <say-as interpret-as=\"name\">${player.name}</say-as><break time=\"750ms\"/>\n";
        }
      }
      ssml += homeGoalie;
      ssml += "<break time=\"500ms\"/>\n";
      ssml +=
          "Ledare för ${stripTeamSuffix(homeTeam)} är<break time=\"750ms\"/>\n";
      for (TeamTeamPerson teamPerson in lineup.homeTeamTeamPersons) {
        ssml +=
            "<say-as interpret-as=\"name\">${teamPerson.name}</say-as><break time=\"1000ms\"/>\n";
      }
      ssml += "<break time=\"1000ms\"/>\n</voice>\n</speak>";
    }
    return ssml;
  }

  String _generateAwayTeamLineup(WidgetRef ref) {
    final lineup = ref.read(effectiveLineupProvider);
    final settings = SettingsBox();
    final voiceName = settings.azVoiceName;
    String ssml;

    // Check if we have valid lineup data
    if (lineup.matchId == 0 || lineup.awayTeamPlayers.isEmpty) {
      ssml =
          """<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
Bortalaget ställer upp med följande spelare<break time="750ms"/>
Nummer 11, <say-as interpret-as="name">Noah Zetterholm</say-as>,
Nummer 27, <say-as interpret-as="name">Eddie Rylin</say-as>,
Nummer 42, <say-as interpret-as="name">Henry Dahlström</say-as>,
Nummer 82, <say-as interpret-as="name">Liam Sandberg</say-as>,
</voice>
</speak>""";
    } else {
      ssml =
          "<speak version=\"1.0\" xmlns=\"http://www.w3.org/2001/10/synthesis\" xmlns:mstts=\"https://www.w3.org/2001/mstts\" xml:lang=\"sv-SE\">\n<voice name=\"$voiceName\">\n${stripTeamSuffix(awayTeam)} ställer upp med följande spelare<break time=\"750ms\"/>\n";
      String awayGoalie =
          "Dagens målvakt är inte inlagd i truppen<break time=\"750ms\"/>\n";
      for (TeamPlayer player in lineup.awayTeamPlayers) {
        if (player.position == "Målvakt") {
          awayGoalie =
              "Dagens målvakt är <say-as interpret-as=\"name\">${player.name}</say-as>,\n";
        } else {
          ssml += player.shirtNo == null
              ? "<say-as interpret-as=\"name\">${player.name}</say-as><break time=\"750ms\"/>\n"
              : "Nummer ${player.shirtNo}, <say-as interpret-as=\"name\">${player.name}</say-as><break time=\"750ms\"/>\n";
        }
      }
      ssml += awayGoalie;
      ssml += "<break time=\"500ms\"/>\n";
      ssml +=
          "Ledare för ${stripTeamSuffix(awayTeam)} är<break time=\"750ms\"/>\n";
      for (TeamTeamPerson teamPerson in lineup.awayTeamTeamPersons) {
        ssml +=
            "<say-as interpret-as=\"name\">${teamPerson.name}</say-as><break time=\"750ms\"/>\n";
      }
      ssml += "<break time=\"1000ms\"/>\n</voice>\n</speak>";
    }
    return ssml;
  }

  String _generateRefereeMessage() {
    final settings = SettingsBox();
    final voiceName = settings.azVoiceName;
    return """<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="sv-SE">
<voice name="$voiceName">
Domare i denna match är,,
$referee1 och $referee2
</voice>
</speak>""";
  }
}
