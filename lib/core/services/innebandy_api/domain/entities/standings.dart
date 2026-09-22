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
  final DateTime? timeStamp;
  final DateTime? createdTs;
  final DateTime? updatedTs;

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
    // 2026-09-22: The IBIS public API standings rows no longer include
    // StandingsRowID, CompetitionID, TeamShortName, TeamStatusName,
    // TimeStamp, CreatedTS or UpdatedTS. Missing fields get neutral
    // defaults instead of crashing on null.
    DateTime? parseDate(dynamic value) =>
        value == null ? null : DateTime.parse(value as String);

    return StandingsRow(
      standingsRowId: json['StandingsRowID'] ?? 0,
      competitionId: json['CompetitionID'] ?? 0,
      teamId: json['TeamID'] ?? 0,
      teamName: json['TeamName'] ?? '',
      teamShortName: json['TeamShortName'] ?? '',
      teamLogotypeUrl: json['TeamLogotypeUrl'] ?? '',
      playedMatchesHome: json['PlayedMatchesHome'] ?? 0,
      playedMatchesAway: json['PlayedMatchesAway'] ?? 0,
      winsHome: json['WinsHome'] ?? 0,
      winsAway: json['WinsAway'] ?? 0,
      sdWinsHome: json['SdWinsHome'] ?? 0,
      sdWinsAway: json['SdWinsAway'] ?? 0,
      drawsHome: json['DrawsHome'] ?? 0,
      drawsAway: json['DrawsAway'] ?? 0,
      lossesHome: json['LossesHome'] ?? 0,
      lossesAway: json['LossesAway'] ?? 0,
      goalsScoredHome: json['GoalsScoredHome'] ?? 0,
      goalsScoredAway: json['GoalsScoredAway'] ?? 0,
      goalsAgainstHome: json['GoalsAgainstHome'] ?? 0,
      goalsAgainstAway: json['GoalsAgainstAway'] ?? 0,
      scoringDiff: json['ScoringDiff'] ?? 0,
      points: json['Points'] ?? 0,
      position: json['Position'] ?? 0,
      lastGames: (json['LastGames'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [],
      teamStatusId: json['TeamStatusID'] ?? 0,
      teamStatusName: json['TeamStatusName'] ?? '',
      timeStamp: parseDate(json['TimeStamp']),
      createdTs: parseDate(json['CreatedTS']),
      updatedTs: parseDate(json['UpdatedTS']),
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
      'TimeStamp': timeStamp?.toIso8601String(),
      'CreatedTS': createdTs?.toIso8601String(),
      'UpdatedTS': updatedTs?.toIso8601String(),
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
