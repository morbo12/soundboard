class IbyMatchEvent {
  final int matchEventId;
  final int matchId;
  final int competitionId;
  final int matchEventTypeId;
  final String matchEventType;
  final int period;
  final String periodName;
  final int minute;
  final int second;
  final int playerId;
  final String playerName;
  final int? playerShirtNo;
  final int playerAssistId;
  final String playerAssistName;
  final int? playerAssistShirtNo;
  final int personId;
  final String personName;
  final String penaltyCode;
  final String penaltyName;
  final int matchTeamId;
  final String matchTeamName;
  final String? matchTeamShortName;
  final int goalsHomeTeam;
  final int goalsAwayTeam;
  final DateTime timeStamp;
  final DateTime createdTS;
  final DateTime? updatedTS;

  IbyMatchEvent({
    required this.matchEventId,
    required this.matchId,
    required this.competitionId,
    required this.matchEventTypeId,
    required this.matchEventType,
    required this.period,
    required this.periodName,
    required this.minute,
    required this.second,
    required this.playerId,
    required this.playerName,
    this.playerShirtNo,
    required this.playerAssistId,
    required this.playerAssistName,
    this.playerAssistShirtNo,
    required this.personId,
    required this.personName,
    required this.penaltyCode,
    required this.penaltyName,
    required this.matchTeamId,
    required this.matchTeamName,
    this.matchTeamShortName,
    required this.goalsHomeTeam,
    required this.goalsAwayTeam,
    required this.timeStamp,
    required this.createdTS,
    this.updatedTS,
  });

  factory IbyMatchEvent.fromJson(Map<String, dynamic> json) {
    return IbyMatchEvent(
      matchEventId: json['MatchEventID'],
      matchId: json['MatchID'],
      competitionId: json['CompetitionID'],
      matchEventTypeId: json['MatchEventTypeID'],
      matchEventType: json['MatchEventType'],
      period: json['Period'],
      periodName: json['PeriodName'],
      minute: json['Minute'],
      second: json['Second'],
      playerId: json['PlayerID'],
      playerName: json['PlayerName'],
      playerShirtNo: json['PlayerShirtNo'],
      playerAssistId: json['PlayerAssistID'],
      playerAssistName: json['PlayerAssistName'],
      playerAssistShirtNo: json['PlayerAssistShirtNo'],
      personId: json['PersonID'],
      personName: json['PersonName'],
      penaltyCode: json['PenaltyCode'],
      penaltyName: json['PenaltyName'],
      matchTeamId: json['MatchTeamID'],
      matchTeamName: json['MatchTeamName'],
      matchTeamShortName: json['MatchTeamShortName'],
      goalsHomeTeam: json['GoalsHomeTeam'],
      goalsAwayTeam: json['GoalsAwayTeam'],
      timeStamp: DateTime.parse(json['TimeStamp']),
      createdTS: DateTime.parse(json['CreatedTS']),
      updatedTS:
          json['UpdatedTS'] != null ? DateTime.parse(json['UpdatedTS']) : null,
    );
  }
}
