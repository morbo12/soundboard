class Competition {
  final int competitionCategoryId;
  final int competitionTypeId;
  final int tableSystemId;
  final int federationId;
  final int playOffCategoryId;
  final String playOffCategoryName;
  final String playOffTypeName;
  final String name;
  final bool standingsPublic;
  final bool teamStatisticsPublic;
  final bool resultsPublic;
  final bool playerStatisticsPublic;
  final bool goalieStatisticsPublic;
  final String logotypeUrl;
  final String timeStamp;
  final String createdTs;
  final String updatedTs;

  Competition({
    required this.competitionCategoryId,
    required this.competitionTypeId,
    required this.tableSystemId,
    required this.federationId,
    required this.playOffCategoryId,
    required this.playOffCategoryName,
    required this.playOffTypeName,
    required this.name,
    required this.standingsPublic,
    required this.teamStatisticsPublic,
    required this.resultsPublic,
    required this.playerStatisticsPublic,
    required this.goalieStatisticsPublic,
    required this.logotypeUrl,
    required this.timeStamp,
    required this.createdTs,
    required this.updatedTs,
  });

  factory Competition.fromJson(Map<String, dynamic> json) {
    return Competition(
      competitionCategoryId: json['CompetitionCategoryID'] ?? 0,
      competitionTypeId: json['CompetitionTypeID'] ?? 0,
      tableSystemId: json['TableSystemID'] ?? 0,
      federationId: json['FederationID'] ?? 0,
      playOffCategoryId: json['PlayOffCategoryID'] ?? 0,
      playOffCategoryName: json['PlayOffCategoryName'] ?? '',
      playOffTypeName: json['PlayOffTypeName'] ?? '',
      name: json['Name'] ?? '',
      standingsPublic: json['StandingsPublic'] ?? false,
      teamStatisticsPublic: json['TeamStatisticsPublic'] ?? false,
      resultsPublic: json['ResultsPublic'] ?? false,
      playerStatisticsPublic: json['PlayerStatisticsPublic'] ?? false,
      goalieStatisticsPublic: json['GoalieStatisticsPublic'] ?? false,
      logotypeUrl: json['LogotypeUrl'] ?? '',
      timeStamp: json['TimeStamp'] ?? '',
      createdTs: json['CreatedTS'] ?? '',
      updatedTs: json['UpdatedTS'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CompetitionCategoryID': competitionCategoryId,
      'CompetitionTypeID': competitionTypeId,
      'TableSystemID': tableSystemId,
      'FederationID': federationId,
      'PlayOffCategoryID': playOffCategoryId,
      'PlayOffCategoryName': playOffCategoryName,
      'PlayOffTypeName': playOffTypeName,
      'Name': name,
      'StandingsPublic': standingsPublic,
      'TeamStatisticsPublic': teamStatisticsPublic,
      'ResultsPublic': resultsPublic,
      'PlayerStatisticsPublic': playerStatisticsPublic,
      'GoalieStatisticsPublic': goalieStatisticsPublic,
      'LogotypeUrl': logotypeUrl,
      'TimeStamp': timeStamp,
      'CreatedTS': createdTs,
      'UpdatedTS': updatedTs,
    };
  }
}
