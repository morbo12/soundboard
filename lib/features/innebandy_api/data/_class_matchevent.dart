// MatchEvent event = MatchEvent(
//   matchEventID: 7603296,
//   matchID: 1364829,
//   competitionID: 35397,
//   matchEventTypeID: 8,
//   matchEventType: "Periodstart",
//   period: 1,
//   periodName: "Period 1",
//   minute: 0,
//   second: 0,
//   playerID: 0,
//   playerName: " ",
//   playerShirtNo: null,
//   playerAssistID: 0,
//   playerAssistName: " ",
//   playerAssistShirtNo: null,
//   personID: 0,
//   personName: " ",
//   penaltyCode: "",
//   penaltyName: "",
//   matchTeamID: 0,
//   matchTeamName: "",
//   matchTeamShortName: "",
//   goalsHomeTeam: 0,
//   goalsAwayTeam: 0,
//   timeStamp: "2023-12-01T23:07:23.2402573+01:00",
//   createdTS: "2023-12-01T19:33:54.77",
//   updatedTS: null,
// );

// class MatchEvent {
//   final int matchEventID;
//   final int matchID;
//   final int competitionID;
//   final int matchEventTypeID;
//   final String matchEventType;
//   final int period;
//   final String periodName;
//   final int minute;
//   final int second;
//   final int playerID;
//   final String playerName;
//   final int? playerShirtNo;
//   final int playerAssistID;
//   final String playerAssistName;
//   final int? playerAssistShirtNo;
//   final int personID;
//   final String personName;
//   final String penaltyCode;
//   final String penaltyName;
//   final int matchTeamID;
//   final String matchTeamName;
//   final String matchTeamShortName;
//   final int goalsHomeTeam;
//   final int goalsAwayTeam;
//   final String timeStamp;
//   final String createdTS;
//   final String? updatedTS;

//   MatchEvent({
//     required this.matchEventID,
//     required this.matchID,
//     required this.competitionID,
//     required this.matchEventTypeID,
//     required this.matchEventType,
//     required this.period,
//     required this.periodName,
//     required this.minute,
//     required this.second,
//     required this.playerID,
//     required this.playerName,
//     this.playerShirtNo,
//     required this.playerAssistID,
//     required this.playerAssistName,
//     this.playerAssistShirtNo,
//     required this.personID,
//     required this.personName,
//     required this.penaltyCode,
//     required this.penaltyName,
//     required this.matchTeamID,
//     required this.matchTeamName,
//     required this.matchTeamShortName,
//     required this.goalsHomeTeam,
//     required this.goalsAwayTeam,
//     required this.timeStamp,
//     required this.createdTS,
//     required this.updatedTS,
//   });

//   factory MatchEvent.fromJson(Map<String, dynamic> json) => MatchEvent(
//         matchEventID: json["MatchEventID"],
//         matchID: json["MatchID"],
//         competitionID: json["CompetitionID"],
//         matchEventTypeID: json["MatchEventTypeID"],
//         matchEventType: json["MatchEventType"],
//         period: json["Period"],
//         periodName: json["PeriodName"],
//         minute: json["Minute"],
//         second: json["Second"],
//         playerID: json["PlayerID"],
//         playerName: json["PlayerName"],
//         playerShirtNo: json["PlayerShirtNo"],
//         playerAssistID: json["PlayerAssistID"],
//         playerAssistName: json["PlayerAssistName"],
//         playerAssistShirtNo: json["PlayerAssistShirtNo"],
//         personID: json["PersonID"],
//         personName: json["PersonName"],
//         penaltyCode: json["PenaltyCode"],
//         penaltyName: json["PenaltyName"],
//         matchTeamID: json["MatchTeamID"],
//         matchTeamName: json["MatchTeamName"],
//         matchTeamShortName: json["MatchTeamShortName"] ?? 'N/A',
//         goalsHomeTeam: json["GoalsHomeTeam"],
//         goalsAwayTeam: json["GoalsAwayTeam"],
//         timeStamp: json["TimeStamp"],
//         createdTS: json["CreatedTS"],
//         updatedTS: json["UpdatedTS"],
//       );
// }
