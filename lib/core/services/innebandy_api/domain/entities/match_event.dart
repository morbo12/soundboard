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

  static DateTime _parseDateTime(Object? rawValue) =>
      DateTime.tryParse(rawValue?.toString() ?? '') ??
      DateTime.fromMillisecondsSinceEpoch(0);

  factory IbyMatchEvent.fromJson(Map<String, dynamic> json) {
    return IbyMatchEvent(
      matchEventId: json['MatchEventID'] ?? 0,
      matchId: json['MatchID'] ?? 0,
      competitionId: json['CompetitionID'] ?? 0,
      matchEventTypeId: json['MatchEventTypeID'] ?? 0,
      matchEventType: json['MatchEventType'] ?? '',
      period: json['Period'] ?? 0,
      periodName: json['PeriodName'] ?? '',
      minute: json['Minute'] ?? 0,
      second: json['Second'] ?? 0,
      playerId: json['PlayerID'] ?? 0,
      playerName: json['PlayerName'] ?? '',
      playerShirtNo: json['PlayerShirtNo'],
      playerAssistId: json['PlayerAssistID'] ?? 0,
      playerAssistName: json['PlayerAssistName'] ?? '',
      playerAssistShirtNo: json['PlayerAssistShirtNo'],
      personId: json['PersonID'] ?? 0,
      personName: json['PersonName'] ?? '',
      penaltyCode: json['PenaltyCode'] ?? '',
      penaltyName: json['PenaltyName'] ?? '',
      matchTeamId: json['MatchTeamID'] ?? 0,
      matchTeamName: json['MatchTeamName'] ?? '',
      matchTeamShortName: json['MatchTeamShortName'],
      goalsHomeTeam: json['GoalsHomeTeam'] ?? 0,
      goalsAwayTeam: json['GoalsAwayTeam'] ?? 0,
      timeStamp: _parseDateTime(json['TimeStamp']),
      createdTS: _parseDateTime(json['CreatedTS']),
      updatedTS: json['UpdatedTS'] != null
          ? DateTime.tryParse(json['UpdatedTS'].toString())
          : null,
    );
  }

  IbyMatchEvent copyWith({String? matchTeamName}) {
    return IbyMatchEvent(
      matchEventId: matchEventId,
      matchId: matchId,
      competitionId: competitionId,
      matchEventTypeId: matchEventTypeId,
      matchEventType: matchEventType,
      period: period,
      periodName: periodName,
      minute: minute,
      second: second,
      playerId: playerId,
      playerName: playerName,
      playerShirtNo: playerShirtNo,
      playerAssistId: playerAssistId,
      playerAssistName: playerAssistName,
      playerAssistShirtNo: playerAssistShirtNo,
      personId: personId,
      personName: personName,
      penaltyCode: penaltyCode,
      penaltyName: penaltyName,
      matchTeamId: matchTeamId,
      matchTeamName: matchTeamName ?? this.matchTeamName,
      matchTeamShortName: matchTeamShortName,
      goalsHomeTeam: goalsHomeTeam,
      goalsAwayTeam: goalsAwayTeam,
      timeStamp: timeStamp,
      createdTS: createdTS,
      updatedTS: updatedTS,
    );
  }
}
