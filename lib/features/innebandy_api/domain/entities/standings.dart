class Standings {
  final List<StandingsRow> standingsRows;

  Standings({required this.standingsRows});

  factory Standings.fromJson(Map<String, dynamic> json) {
    return Standings(
      standingsRows:
          (json['StandingsRows'] as List)
              .map((row) => StandingsRow.fromJson(row))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'StandingsRows': standingsRows.map((row) => row.toJson()).toList()};
  }
}

class StandingsRow {
  final int standingsRowId;
  final int competitionId;
  final int teamId;
  final String teamName;
  final String teamShortName;
  final String teamLogotypeUrl;
  final int playedMatchesHome;
  final int playedMatchesAway;
  final int winsHome;
  final int winsAway;
  final int sdWinsHome;
  final int sdWinsAway;
  final int drawsHome;
  final int drawsAway;
  final int lossesHome;
  final int lossesAway;
  final int goalsScoredHome;
  final int goalsScoredAway;
  final int goalsAgainstHome;
  final int goalsAgainstAway;
  final int scoringDiff;
  final int points;
  final int position;
  final List<int> lastGames;
  final int teamStatusId;
  final String teamStatusName;
  final DateTime timeStamp;
  final DateTime createdTs;
  final DateTime updatedTs;

  StandingsRow({
    required this.standingsRowId,
    required this.competitionId,
    required this.teamId,
    required this.teamName,
    required this.teamShortName,
    required this.teamLogotypeUrl,
    required this.playedMatchesHome,
    required this.playedMatchesAway,
    required this.winsHome,
    required this.winsAway,
    required this.sdWinsHome,
    required this.sdWinsAway,
    required this.drawsHome,
    required this.drawsAway,
    required this.lossesHome,
    required this.lossesAway,
    required this.goalsScoredHome,
    required this.goalsScoredAway,
    required this.goalsAgainstHome,
    required this.goalsAgainstAway,
    required this.scoringDiff,
    required this.points,
    required this.position,
    required this.lastGames,
    required this.teamStatusId,
    required this.teamStatusName,
    required this.timeStamp,
    required this.createdTs,
    required this.updatedTs,
  });

  factory StandingsRow.fromJson(Map<String, dynamic> json) {
    return StandingsRow(
      standingsRowId: json['StandingsRowID'],
      competitionId: json['CompetitionID'],
      teamId: json['TeamID'],
      teamName: json['TeamName'],
      teamShortName: json['TeamShortName'],
      teamLogotypeUrl: json['TeamLogotypeUrl'],
      playedMatchesHome: json['PlayedMatchesHome'],
      playedMatchesAway: json['PlayedMatchesAway'],
      winsHome: json['WinsHome'],
      winsAway: json['WinsAway'],
      sdWinsHome: json['SdWinsHome'],
      sdWinsAway: json['SdWinsAway'],
      drawsHome: json['DrawsHome'],
      drawsAway: json['DrawsAway'],
      lossesHome: json['LossesHome'],
      lossesAway: json['LossesAway'],
      goalsScoredHome: json['GoalsScoredHome'],
      goalsScoredAway: json['GoalsScoredAway'],
      goalsAgainstHome: json['GoalsAgainstHome'],
      goalsAgainstAway: json['GoalsAgainstAway'],
      scoringDiff: json['ScoringDiff'],
      points: json['Points'],
      position: json['Position'],
      lastGames: List<int>.from(json['LastGames']),
      teamStatusId: json['TeamStatusID'],
      teamStatusName: json['TeamStatusName'],
      timeStamp: DateTime.parse(json['TimeStamp']),
      createdTs: DateTime.parse(json['CreatedTS']),
      updatedTs: DateTime.parse(json['UpdatedTS']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'StandingsRowID': standingsRowId,
      'CompetitionID': competitionId,
      'TeamID': teamId,
      'TeamName': teamName,
      'TeamShortName': teamShortName,
      'TeamLogotypeUrl': teamLogotypeUrl,
      'PlayedMatchesHome': playedMatchesHome,
      'PlayedMatchesAway': playedMatchesAway,
      'WinsHome': winsHome,
      'WinsAway': winsAway,
      'SdWinsHome': sdWinsHome,
      'SdWinsAway': sdWinsAway,
      'DrawsHome': drawsHome,
      'DrawsAway': drawsAway,
      'LossesHome': lossesHome,
      'LossesAway': lossesAway,
      'GoalsScoredHome': goalsScoredHome,
      'GoalsScoredAway': goalsScoredAway,
      'GoalsAgainstHome': goalsAgainstHome,
      'GoalsAgainstAway': goalsAgainstAway,
      'ScoringDiff': scoringDiff,
      'Points': points,
      'Position': position,
      'LastGames': lastGames,
      'TeamStatusID': teamStatusId,
      'TeamStatusName': teamStatusName,
      'TimeStamp': timeStamp.toIso8601String(),
      'CreatedTS': createdTs.toIso8601String(),
      'UpdatedTS': updatedTs.toIso8601String(),
    };
  }

  // Computed properties for convenience
  int get totalMatches => playedMatchesHome + playedMatchesAway;
  int get totalWins => winsHome + winsAway;
  int get totalDraws => drawsHome + drawsAway;
  int get totalLosses => lossesHome + lossesAway;
  int get totalGoalsScored => goalsScoredHome + goalsScoredAway;
  int get totalGoalsAgainst => goalsAgainstHome + goalsAgainstAway;
}
