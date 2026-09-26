class IbyMatchIntermediateResult {
  final int matchId;
  final int period;
  final int goalsHomeTeam;
  final int goalsAwayTeam;

  IbyMatchIntermediateResult({
    required this.matchId,
    required this.period,
    required this.goalsHomeTeam,
    required this.goalsAwayTeam,
  });

  factory IbyMatchIntermediateResult.fromJson(Map<String, dynamic> json) {
    return IbyMatchIntermediateResult(
      matchId: json['MatchID'] ?? 0,
      period: json['Period'] ?? 0,
      goalsHomeTeam: json['GoalsHomeTeam'] ?? 0,
      goalsAwayTeam: json['GoalsAwayTeam'] ?? 0,
    );
  }

  // Add this method
  @override
  String toString() {
    return '{matchId: $matchId, period: $period, goalsHomeTeam: $goalsHomeTeam, goalsAwayTeam: $goalsAwayTeam}';
  }

  // Optionally, you can also add toJson method
  Map<String, dynamic> toJson() {
    return {
      'matchId': matchId,
      'period': period,
      'goalsHomeTeam': goalsHomeTeam,
      'goalsAwayTeam': goalsAwayTeam,
    };
  }
}
