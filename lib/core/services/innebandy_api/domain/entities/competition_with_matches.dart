import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';

/// Represents a competition with its matches and standings.
/// Used for the tournament API endpoint that returns everything in one call.
class CompetitionWithMatches {
  final int competitionId;
  final int competitionTypeId;
  final int tableSystemId;
  final int categoryId;
  final int categoryTypeId;
  final int competitionStatusId;
  final String competitionStatus;
  final String categoryName;
  final int playOffCategoryId;
  final String playOffCategoryName;
  final String playOffTypeName;
  final String name;
  final String shortName;
  final bool standingsPublic;
  final bool resultsPublic;
  final bool playerStatisticsPublic;
  final bool goalieStatisticsPublic;
  final bool schedulePublic;
  final bool teamStatisticsPublic;
  final int numPromotedTeams;
  final int numDemotedTeams;
  final int numPlayOffTeamsUp;
  final int numPlayOffTeamsDown;
  final String? logotypeUrl;
  final List<IbyMatch> matches;

  CompetitionWithMatches({
    required this.competitionId,
    required this.competitionTypeId,
    required this.tableSystemId,
    required this.categoryId,
    required this.categoryTypeId,
    required this.competitionStatusId,
    required this.competitionStatus,
    required this.categoryName,
    required this.playOffCategoryId,
    required this.playOffCategoryName,
    required this.playOffTypeName,
    required this.name,
    required this.shortName,
    required this.standingsPublic,
    required this.resultsPublic,
    required this.playerStatisticsPublic,
    required this.goalieStatisticsPublic,
    required this.schedulePublic,
    required this.teamStatisticsPublic,
    required this.numPromotedTeams,
    required this.numDemotedTeams,
    required this.numPlayOffTeamsUp,
    required this.numPlayOffTeamsDown,
    this.logotypeUrl,
    required this.matches,
  });

  factory CompetitionWithMatches.fromJson(Map<String, dynamic> json) {
    return CompetitionWithMatches(
      competitionId: json['CompetitionID'] ?? 0,
      competitionTypeId: json['CompetitionTypeID'] ?? 0,
      tableSystemId: json['TableSystemID'] ?? 0,
      categoryId: json['CategoryID'] ?? 0,
      categoryTypeId: json['CategoryTypeID'] ?? 0,
      competitionStatusId: json['CompetitionStatusID'] ?? 0,
      competitionStatus: json['CompetitionStatus'] ?? '',
      categoryName: json['CategoryName'] ?? '',
      playOffCategoryId: json['PlayOffCategoryID'] ?? 0,
      playOffCategoryName: json['PlayOffCategoryName'] ?? '',
      playOffTypeName: json['PlayOffTypeName'] ?? '',
      name: json['Name'] ?? '',
      shortName: json['ShortName'] ?? '',
      standingsPublic: json['StandingsPublic'] ?? false,
      resultsPublic: json['ResultsPublic'] ?? false,
      playerStatisticsPublic: json['PlayerStatisticsPublic'] ?? false,
      goalieStatisticsPublic: json['GoalieStatisticsPublic'] ?? false,
      schedulePublic: json['SchedulePublic'] ?? false,
      teamStatisticsPublic: json['TeamStatisticsPublic'] ?? false,
      numPromotedTeams: json['NumPromotedTeams'] ?? 0,
      numDemotedTeams: json['NumDemotedTeams'] ?? 0,
      numPlayOffTeamsUp: json['NumPlayOffTeamsUp'] ?? 0,
      numPlayOffTeamsDown: json['NumPlayOffTeamsDown'] ?? 0,
      logotypeUrl: json['LogotypeUrl'],
      matches:
          (json['Matches'] as List<dynamic>?)
              ?.map((matchJson) => IbyMatch.fromJson(matchJson))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CompetitionID': competitionId,
      'CompetitionTypeID': competitionTypeId,
      'TableSystemID': tableSystemId,
      'CategoryID': categoryId,
      'CategoryTypeID': categoryTypeId,
      'CompetitionStatusID': competitionStatusId,
      'CompetitionStatus': competitionStatus,
      'CategoryName': categoryName,
      'PlayOffCategoryID': playOffCategoryId,
      'PlayOffCategoryName': playOffCategoryName,
      'PlayOffTypeName': playOffTypeName,
      'Name': name,
      'ShortName': shortName,
      'StandingsPublic': standingsPublic,
      'ResultsPublic': resultsPublic,
      'PlayerStatisticsPublic': playerStatisticsPublic,
      'GoalieStatisticsPublic': goalieStatisticsPublic,
      'SchedulePublic': schedulePublic,
      'TeamStatisticsPublic': teamStatisticsPublic,
      'NumPromotedTeams': numPromotedTeams,
      'NumDemotedTeams': numDemotedTeams,
      'NumPlayOffTeamsUp': numPlayOffTeamsUp,
      'NumPlayOffTeamsDown': numPlayOffTeamsDown,
      'LogotypeUrl': logotypeUrl,
      // Note: Matches serialization not implemented as IbyMatch doesn't have toJson
    };
  }
}
