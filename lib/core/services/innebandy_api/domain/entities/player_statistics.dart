class PlayerStatistics {
  final List<PlayerStatisticsRow> playerStatisticsRows;

  PlayerStatistics({required this.playerStatisticsRows});

  factory PlayerStatistics.fromJson(Map<String, dynamic> json) {
    return PlayerStatistics(
      playerStatisticsRows:
          (json['PlayerStatisticsRows'] as List?)
              ?.map((row) => PlayerStatisticsRow.fromJson(row))
              .toList() ??
          [],
    );
  }

  /// 2026-09-22: The IBIS public API returns a bare JSON array (e.g. `[]`
  /// before the season starts) instead of the previous
  /// `{"PlayerStatisticsRows": [...]}` wrapper. Accept both shapes.
  factory PlayerStatistics.fromResponseData(dynamic data) {
    if (data is List) {
      return PlayerStatistics(
        playerStatisticsRows: data
            .map((row) => PlayerStatisticsRow.fromJson(row))
            .toList(),
      );
    }
    if (data is Map<String, dynamic>) {
      return PlayerStatistics.fromJson(data);
    }
    return PlayerStatistics(playerStatisticsRows: []);
  }

  Map<String, dynamic> toJson() {
    return {
      'PlayerStatisticsRows':
          playerStatisticsRows.map((row) => row.toJson()).toList(),
    };
  }
}

class PlayerStatisticsRow {
  final int playerId;
  final String playerName;
  final int seasonId;
  final String seasonName;
  final int associationId;
  final String associationName;
  final int teamId;
  final String teamName;
  final String teamShortName;
  final int matchesPlayed;
  final int goalsScored;
  final int assists;
  final int points;
  final int penaltyMinutes;
  final int goalsScoredPp;
  final int goalsScoredBp;
  final int assistsPp;
  final int assistsBp;
  final int pointsPp;
  final int pointsBp;
  final String imageUrl;

  PlayerStatisticsRow({
    required this.playerId,
    required this.playerName,
    required this.seasonId,
    required this.seasonName,
    required this.associationId,
    required this.associationName,
    required this.teamId,
    required this.teamName,
    required this.teamShortName,
    required this.matchesPlayed,
    required this.goalsScored,
    required this.assists,
    required this.points,
    required this.penaltyMinutes,
    required this.goalsScoredPp,
    required this.goalsScoredBp,
    required this.assistsPp,
    required this.assistsBp,
    required this.pointsPp,
    required this.pointsBp,
    required this.imageUrl,
  });

  factory PlayerStatisticsRow.fromJson(Map<String, dynamic> json) {
    // 2026-09-22: IBIS public API rows may omit fields that were always
    // present before. Missing values get neutral defaults.
    return PlayerStatisticsRow(
      playerId: json['PlayerID'] ?? 0,
      playerName: json['PlayerName'] ?? '',
      seasonId: json['SeasonID'] ?? 0,
      seasonName: json['SeasonName'] ?? '',
      associationId: json['AssociationID'] ?? 0,
      associationName: json['AssociationName'] ?? '',
      teamId: json['TeamID'] ?? 0,
      teamName: json['TeamName'] ?? '',
      teamShortName: json['TeamShortName'] ?? '',
      matchesPlayed: json['MatchesPlayed'] ?? 0,
      goalsScored: json['GoalsScored'] ?? 0,
      assists: json['Assists'] ?? 0,
      points: json['Points'] ?? 0,
      penaltyMinutes: json['PenaltyMinutes'] ?? 0,
      goalsScoredPp: json['GoalsScoredPp'] ?? 0,
      goalsScoredBp: json['GoalsScoredBp'] ?? 0,
      assistsPp: json['AssistsPp'] ?? 0,
      assistsBp: json['AssistsBp'] ?? 0,
      pointsPp: json['PointsPp'] ?? 0,
      pointsBp: json['PointsBp'] ?? 0,
      imageUrl: json['ImageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PlayerID': playerId,
      'PlayerName': playerName,
      'SeasonID': seasonId,
      'SeasonName': seasonName,
      'AssociationID': associationId,
      'AssociationName': associationName,
      'TeamID': teamId,
      'TeamName': teamName,
      'TeamShortName': teamShortName,
      'MatchesPlayed': matchesPlayed,
      'GoalsScored': goalsScored,
      'Assists': assists,
      'Points': points,
      'PenaltyMinutes': penaltyMinutes,
      'GoalsScoredPp': goalsScoredPp,
      'GoalsScoredBp': goalsScoredBp,
      'AssistsPp': assistsPp,
      'AssistsBp': assistsBp,
      'PointsPp': pointsPp,
      'PointsBp': pointsBp,
      'ImageUrl': imageUrl,
    };
  }

  // Computed properties for convenience
  double get pointsPerGame => matchesPlayed > 0 ? points / matchesPlayed : 0;
  double get goalsPerGame =>
      matchesPlayed > 0 ? goalsScored / matchesPlayed : 0;
  double get assistsPerGame => matchesPlayed > 0 ? assists / matchesPlayed : 0;
  int get powerPlayPoints => pointsPp;
  int get shortHandedPoints => pointsBp;
}
