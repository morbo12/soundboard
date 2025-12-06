/// Entity class representing pregame statistics for a match
class PregameStats {
  final int federationId;
  final String federationName;
  final int competitionId;
  final String competitionName;
  final String? competitionLogotypeUrl;
  final int matchId;
  final String matchNo;
  final int homeTeamId;
  final int homeMatchTeamId;
  final String homeTeam;
  final String homeTeamShortName;
  final String? homeTeamLogotypeUrl;
  final int awayTeamId;
  final int awayMatchTeamId;
  final String awayTeam;
  final String awayTeamShortName;
  final String? awayTeamLogotypeUrl;
  final String matchDateTime;
  final int venueId;
  final String venueName;
  final int? homeTeamRanking;
  final int? awayTeamRanking;
  final int? homeTeamGoalsLastMeeting;
  final int? awayTeamGoalsLastMeeting;
  final int homeTeamMeetingWins;
  final int awayTeamMeetingWins;
  final int meetingDraws;
  final int? homeTeamTrend;
  final int? awayTeamTrend;
  final List<int> homeTeamLastGames;
  final List<int> awayTeamLastGames;
  final List<HotPlayer>? homeHotPlayersBeforeGame;
  final List<HotPlayer>? awayHotPlayersBeforeGame;
  final List<HotPlayer>? homeHotPlayersAfterGame;
  final List<HotPlayer>? awayHotPlayersAfterGame;
  final int matchStatus;
  final List<PregameResult> results;
  final String broadcastUrl;
  final String ticketUrl;
  final int homeTeamCompetitionId;
  final String homeTeamCompetitionName;
  final int awayTeamCompetitionId;
  final String awayTeamCompetitionName;
  final String timeStamp;
  final String? createdTS;
  final String? updatedTS;

  PregameStats({
    required this.federationId,
    required this.federationName,
    required this.competitionId,
    required this.competitionName,
    this.competitionLogotypeUrl,
    required this.matchId,
    required this.matchNo,
    required this.homeTeamId,
    required this.homeMatchTeamId,
    required this.homeTeam,
    required this.homeTeamShortName,
    this.homeTeamLogotypeUrl,
    required this.awayTeamId,
    required this.awayMatchTeamId,
    required this.awayTeam,
    required this.awayTeamShortName,
    this.awayTeamLogotypeUrl,
    required this.matchDateTime,
    required this.venueId,
    required this.venueName,
    this.homeTeamRanking,
    this.awayTeamRanking,
    this.homeTeamGoalsLastMeeting,
    this.awayTeamGoalsLastMeeting,
    required this.homeTeamMeetingWins,
    required this.awayTeamMeetingWins,
    required this.meetingDraws,
    this.homeTeamTrend,
    this.awayTeamTrend,
    required this.homeTeamLastGames,
    required this.awayTeamLastGames,
    this.homeHotPlayersBeforeGame,
    this.awayHotPlayersBeforeGame,
    this.homeHotPlayersAfterGame,
    this.awayHotPlayersAfterGame,
    required this.matchStatus,
    required this.results,
    required this.broadcastUrl,
    required this.ticketUrl,
    required this.homeTeamCompetitionId,
    required this.homeTeamCompetitionName,
    required this.awayTeamCompetitionId,
    required this.awayTeamCompetitionName,
    required this.timeStamp,
    this.createdTS,
    this.updatedTS,
  });

  factory PregameStats.fromJson(Map<String, dynamic> json) {
    return PregameStats(
      federationId: json['FederationID'] ?? 0,
      federationName: json['FederationName'] ?? '',
      competitionId: json['CompetitionID'] ?? 0,
      competitionName: json['CompetitionName'] ?? '',
      competitionLogotypeUrl: json['CompetitionLogotypeUrl'],
      matchId: json['MatchID'] ?? 0,
      matchNo: json['MatchNo'] ?? '',
      homeTeamId: json['HomeTeamID'] ?? 0,
      homeMatchTeamId: json['HomeMatchTeamID'] ?? 0,
      homeTeam: json['HomeTeam'] ?? '',
      homeTeamShortName: json['HomeTeamShortName'] ?? '',
      homeTeamLogotypeUrl: json['HomeTeamLogotypeUrl'],
      awayTeamId: json['AwayTeamID'] ?? 0,
      awayMatchTeamId: json['AwayMatchTeamID'] ?? 0,
      awayTeam: json['AwayTeam'] ?? '',
      awayTeamShortName: json['AwayTeamShortName'] ?? '',
      awayTeamLogotypeUrl: json['AwayTeamLogotypeUrl'],
      matchDateTime: json['MatchDateTime'] ?? '',
      venueId: json['VenueID'] ?? 0,
      venueName: json['VenueName'] ?? '',
      homeTeamRanking: json['HomeTeamRanking'],
      awayTeamRanking: json['AwayTeamRanking'],
      homeTeamGoalsLastMeeting: json['HomeTeamGoalsLastMeeting'],
      awayTeamGoalsLastMeeting: json['AwayTeamGoalsLastMeeting'],
      homeTeamMeetingWins: json['HomeTeamMeetingWins'] ?? 0,
      awayTeamMeetingWins: json['AwayTeamMeetingWins'] ?? 0,
      meetingDraws: json['MeetingDraws'] ?? 0,
      homeTeamTrend: json['HomeTeamTrend'],
      awayTeamTrend: json['AwayTeamTrend'],
      homeTeamLastGames:
          (json['HomeTeamLastGames'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      awayTeamLastGames:
          (json['AwayTeamLastGames'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      homeHotPlayersBeforeGame: json['HomeHotPlayersBeforeGame'] != null
          ? (json['HomeHotPlayersBeforeGame'] as List<dynamic>)
                .map((e) => HotPlayer.fromJson(e))
                .toList()
          : null,
      awayHotPlayersBeforeGame: json['AwayHotPlayersBeforeGame'] != null
          ? (json['AwayHotPlayersBeforeGame'] as List<dynamic>)
                .map((e) => HotPlayer.fromJson(e))
                .toList()
          : null,
      homeHotPlayersAfterGame: json['HomeHotPlayersAfterGame'] != null
          ? (json['HomeHotPlayersAfterGame'] as List<dynamic>)
                .map((e) => HotPlayer.fromJson(e))
                .toList()
          : null,
      awayHotPlayersAfterGame: json['AwayHotPlayersAfterGame'] != null
          ? (json['AwayHotPlayersAfterGame'] as List<dynamic>)
                .map((e) => HotPlayer.fromJson(e))
                .toList()
          : null,
      matchStatus: json['MatchStatus'] ?? 0,
      results:
          (json['Results'] as List<dynamic>?)
              ?.map((e) => PregameResult.fromJson(e))
              .toList() ??
          [],
      broadcastUrl: json['BroadcastUrl'] ?? '',
      ticketUrl: json['TicketUrl'] ?? '',
      homeTeamCompetitionId: json['HomeTeamCompetitionID'] ?? 0,
      homeTeamCompetitionName: json['HomeTeamCompetitionName'] ?? '',
      awayTeamCompetitionId: json['AwayTeamCompetitionID'] ?? 0,
      awayTeamCompetitionName: json['AwayTeamCompetitionName'] ?? '',
      timeStamp: json['TimeStamp'] ?? '',
      createdTS: json['CreatedTS'],
      updatedTS: json['UpdatedTS'],
    );
  }
}

/// Represents a hot player in pregame stats
class HotPlayer {
  final int playerId;
  final String playerName;
  final int goals;
  final int assists;
  final int points;

  HotPlayer({
    required this.playerId,
    required this.playerName,
    required this.goals,
    required this.assists,
    required this.points,
  });

  factory HotPlayer.fromJson(Map<String, dynamic> json) {
    return HotPlayer(
      playerId: json['PlayerID'] ?? 0,
      playerName: json['PlayerName'] ?? '',
      goals: json['Goals'] ?? 0,
      assists: json['Assists'] ?? 0,
      points: json['Points'] ?? 0,
    );
  }
}

/// Represents a result in pregame stats
class PregameResult {
  final int matchResultId;
  final int matchId;
  final int competitionId;
  final int matchResultTypeId;
  final String matchResultType;
  final int goalsHomeTeam;
  final int goalsAwayTeam;
  final bool isFinalResult;
  final String timeStamp;
  final String createdTS;
  final String? updatedTS;

  PregameResult({
    required this.matchResultId,
    required this.matchId,
    required this.competitionId,
    required this.matchResultTypeId,
    required this.matchResultType,
    required this.goalsHomeTeam,
    required this.goalsAwayTeam,
    required this.isFinalResult,
    required this.timeStamp,
    required this.createdTS,
    this.updatedTS,
  });

  factory PregameResult.fromJson(Map<String, dynamic> json) {
    return PregameResult(
      matchResultId: json['MatchResultID'] ?? 0,
      matchId: json['MatchID'] ?? 0,
      competitionId: json['CompetitionID'] ?? 0,
      matchResultTypeId: json['MatchResultTypeID'] ?? 0,
      matchResultType: json['MatchResultType'] ?? '',
      goalsHomeTeam: json['GoalsHomeTeam'] ?? 0,
      goalsAwayTeam: json['GoalsAwayTeam'] ?? 0,
      isFinalResult: json['IsFinalResult'] ?? false,
      timeStamp: json['TimeStamp'] ?? '',
      createdTS: json['CreatedTS'] ?? '',
      updatedTS: json['UpdatedTS'],
    );
  }
}
