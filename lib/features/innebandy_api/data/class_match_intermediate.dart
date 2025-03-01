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
      matchId: json['MatchID'],
      period: json['Period'],
      goalsHomeTeam: json['GoalsHomeTeam'],
      goalsAwayTeam: json['GoalsAwayTeam'],
    );
  }
}
