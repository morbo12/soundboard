import 'package:soundboard/core/services/innebandy_api/domain/entities/match_event.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_type.dart';

class ManualEventService {
  /// Creates a goal event with the provided details
  static IbyMatchEvent createGoalEvent({
    required int eventId,
    required int matchId,
    required String playerName,
    required int shirtNo,
    required String teamName,
    required int teamId,
    required int minute,
    required int second,
    required int period,
    required String periodName,
    required int goalsHomeTeam,
    required int goalsAwayTeam,
    String? assistName,
    int? assistShirtNo,
    bool isPenaltyGoal = false,
  }) {
    final now = DateTime.now();

    return IbyMatchEvent(
      matchEventId: eventId,
      matchId: matchId,
      competitionId: 0, // Manual events don't need competition ID
      matchEventTypeId: isPenaltyGoal
          ? MatchEventType.straffmal
          : MatchEventType.mal,
      matchEventType: isPenaltyGoal ? 'Straffmål' : 'Mål',
      period: period,
      periodName: periodName,
      minute: minute,
      second: second,
      playerId: 0, // Manual events don't have API player IDs
      playerName: playerName,
      playerShirtNo: shirtNo,
      playerAssistId: assistShirtNo != null ? 0 : 0,
      playerAssistName: assistName ?? '',
      playerAssistShirtNo: assistShirtNo,
      personId: 0,
      personName: playerName,
      penaltyCode: '',
      penaltyName: '',
      matchTeamId: teamId,
      matchTeamName: teamName,
      matchTeamShortName: '',
      goalsHomeTeam: goalsHomeTeam,
      goalsAwayTeam: goalsAwayTeam,
      timeStamp: now,
      createdTS: now,
      updatedTS: now,
    );
  }

  /// Creates a penalty event with the provided details
  static IbyMatchEvent createPenaltyEvent({
    required int eventId,
    required int matchId,
    required String playerName,
    required int shirtNo,
    required String teamName,
    required int teamId,
    required int minute,
    required int second,
    required int period,
    required String periodName,
    required String penaltyCode,
    required String penaltyName,
    required int goalsHomeTeam,
    required int goalsAwayTeam,
  }) {
    final now = DateTime.now();

    return IbyMatchEvent(
      matchEventId: eventId,
      matchId: matchId,
      competitionId: 0,
      matchEventTypeId: MatchEventType.utvisning,
      matchEventType: 'Utvisning',
      period: period,
      periodName: periodName,
      minute: minute,
      second: second,
      playerId: 0,
      playerName: playerName,
      playerShirtNo: shirtNo,
      playerAssistId: 0,
      playerAssistName: '',
      playerAssistShirtNo: null,
      personId: 0,
      personName: playerName,
      penaltyCode: penaltyCode,
      penaltyName: penaltyName,
      matchTeamId: teamId,
      matchTeamName: teamName,
      matchTeamShortName: '',
      goalsHomeTeam: goalsHomeTeam,
      goalsAwayTeam: goalsAwayTeam,
      timeStamp: now,
      createdTS: now,
      updatedTS: now,
    );
  }

  /// Creates a timeout event
  static IbyMatchEvent createTimeoutEvent({
    required int eventId,
    required int matchId,
    required String teamName,
    required int teamId,
    required int minute,
    required int second,
    required int period,
    required String periodName,
    required int goalsHomeTeam,
    required int goalsAwayTeam,
    required bool isHomeTeam,
  }) {
    final now = DateTime.now();

    return IbyMatchEvent(
      matchEventId: eventId,
      matchId: matchId,
      competitionId: 0,
      matchEventTypeId: isHomeTeam
          ? MatchEventType.timeoutHemma
          : MatchEventType.timeoutBorta,
      matchEventType: 'Timeout',
      period: period,
      periodName: periodName,
      minute: minute,
      second: second,
      playerId: 0,
      playerName: '',
      playerShirtNo: null,
      playerAssistId: 0,
      playerAssistName: '',
      playerAssistShirtNo: null,
      personId: 0,
      personName: '',
      penaltyCode: '',
      penaltyName: '',
      matchTeamId: teamId,
      matchTeamName: teamName,
      matchTeamShortName: '',
      goalsHomeTeam: goalsHomeTeam,
      goalsAwayTeam: goalsAwayTeam,
      timeStamp: now,
      createdTS: now,
      updatedTS: now,
    );
  }

  /// Creates a period start/end event
  static IbyMatchEvent createPeriodEvent({
    required int eventId,
    required int matchId,
    required int minute,
    required int second,
    required int period,
    required String periodName,
    required int goalsHomeTeam,
    required int goalsAwayTeam,
    required bool isStart,
  }) {
    final now = DateTime.now();

    return IbyMatchEvent(
      matchEventId: eventId,
      matchId: matchId,
      competitionId: 0,
      matchEventTypeId: isStart
          ? MatchEventType.periodstart
          : MatchEventType.periodslut,
      matchEventType: isStart ? 'Periodstart' : 'Periodslut',
      period: period,
      periodName: periodName,
      minute: minute,
      second: second,
      playerId: 0,
      playerName: '',
      playerShirtNo: null,
      playerAssistId: 0,
      playerAssistName: '',
      playerAssistShirtNo: null,
      personId: 0,
      personName: '',
      penaltyCode: '',
      penaltyName: '',
      matchTeamId: 0,
      matchTeamName: '',
      matchTeamShortName: '',
      goalsHomeTeam: goalsHomeTeam,
      goalsAwayTeam: goalsAwayTeam,
      timeStamp: now,
      createdTS: now,
      updatedTS: now,
    );
  }
}
