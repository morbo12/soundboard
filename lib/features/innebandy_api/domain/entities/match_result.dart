class IbyMatchResult {
  int? matchResultId;
  int? matchId;
  int? competitionId;
  int? matchResultTypeId;
  String? matchResultType;
  int? goalsHomeTeam;
  int? goalsAwayTeam;
  bool? isFinalResult;
  String? timeStamp;
  String? createdTS;
  String? updatedTS;

  IbyMatchResult({
    this.matchResultId,
    this.matchId,
    this.competitionId,
    this.matchResultTypeId,
    this.matchResultType,
    this.goalsHomeTeam,
    this.goalsAwayTeam,
    this.isFinalResult,
    this.timeStamp,
    this.createdTS,
    this.updatedTS,
  });

  factory IbyMatchResult.fromJson(Map<String, dynamic> json) {
    return IbyMatchResult(
      matchResultId: json['MatchResultID'],
      matchId: json['MatchID'],
      competitionId: json['CompetitionID'],
      matchResultTypeId: json['MatchResultTypeID'],
      matchResultType: json['MatchResultType'],
      goalsHomeTeam: json['GoalsHomeTeam'],
      goalsAwayTeam: json['GoalsAwayTeam'],
      isFinalResult: json['IsFinalResult'],
      timeStamp: json['TimeStamp'],
      createdTS: json['CreatedTS'],
      updatedTS: json['UpdatedTS'] != null ? json['UpdatedTS'] : null,
    );
  }
}
