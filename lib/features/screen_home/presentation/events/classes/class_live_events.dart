import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/api_client_provider.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/match_service.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_event.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/utils/app_localizations.dart';
import 'package:soundboard/features/screen_home/presentation/events/widgets/live_match_card.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/providers/manual_lineup_providers.dart';
import 'package:soundboard/features/screen_match/data/mockup/match_mockup_data.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_intermediate.dart';
import '../../live/widget_event.dart';

part 'class_live_events.g.dart';

@riverpod
class MatchEventsStream extends _$MatchEventsStream {
  static const _logger = Logger('MatchEventsStream');

  Timer? _timer;
  final _streamController = StreamController<List<IbyMatchEvent>>.broadcast();
  bool _isInitialized = false;
  int? _currentMatchId;
  int? _lastKnownStatus;

  // Timer intervals
  static const Duration _activeDuration = Duration(seconds: 3);
  static const Duration _pausedDuration = Duration(seconds: 30);

  Stream<List<IbyMatchEvent>> build() {
    ref.onDispose(() {
      _timer?.cancel();
      _streamController.close();
    });

    // Initialize with empty list - manual events will be added in _buildEventsListView
    if (!_isInitialized) {
      _isInitialized = true;
      _streamController.add([]);
    }

    return _streamController.stream;
  }

  Future<void> startStreaming(int matchId) async {
    // Return early if already streaming the same match
    if ((_timer?.isActive ?? false) && _currentMatchId == matchId) return;

    // Stop any existing timer
    stopStreaming();

    _currentMatchId = matchId;

    // Simulate live match for the demo match
    if (matchId == 999999) {
      _startSimulation(matchId);
      return;
    }

    final apiClient = ref.watch(apiClientProvider);
    final matchService = MatchService(apiClient);

    // Clear existing events when starting a new stream
    _streamController.add([]);

    // Initial fetch to get current match status
    await _fetchAndUpdateMatch(matchId, matchService);

    // Get the current match to check status
    final currentMatch = ref.read(selectedMatchProvider);
    _lastKnownStatus = currentMatch.matchStatus;

    // Start timer for both active (2) and paused (3) matches
    // Match statuses: 0=N/A, 1=Ej påbörjad, 2=Spel pågår, 3=Paus, 4=Färdigspelad
    if (currentMatch.matchStatus == 2 || currentMatch.matchStatus == 3) {
      _startTimerWithInterval(matchId, matchService, currentMatch.matchStatus);
    } else {
      _logger.d(
        'Not starting periodic updates for match $matchId (status: ${currentMatch.matchStatus} - not active or paused)',
      );
    }
  }

  void _startTimerWithInterval(int matchId, MatchService service, int status) {
    // Stop existing timer before starting new one
    _timer?.cancel();

    final interval = status == 2 ? _activeDuration : _pausedDuration;

    _timer = Timer.periodic(
      interval,
      (_) => _fetchAndUpdateMatch(matchId, service),
    );

    final statusText = status == 2 ? 'active' : 'paused';
    _logger.d(
      'Started periodic updates for match $matchId (status: $status - $statusText, interval: ${interval.inSeconds}s)',
    );
  }

  void _startSimulation(int matchId) {
    _logger.d('Starting simulation for match $matchId');

    // Get the base mockup match
    final cleanMatch = MatchMockupData.getMockupMatch();
    // Get all events that we want to "play back"
    final allEvents = MatchMockupData.getMockupEvents();

    // Initialize state
    // We start with NO events, active status
    int currentIndex = -1;
    // We use a faster interval for simulation (e.g. 3 seconds per event)
    const simulationInterval = Duration(seconds: 3);

    // Initial update: Match active (2), 0 events, 0-0 score
    IbyMatch currentMatchState = cleanMatch;
    // Manually override fields for start of simulation
    currentMatchState.matchStatus = 2; // Active
    currentMatchState.events = [];
    currentMatchState.intermediateResults = [];
    currentMatchState.goalsHomeTeam = 0;
    currentMatchState.goalsAwayTeam = 0;

    // Update global state immediately
    ref.read(selectedMatchProvider.notifier).state = currentMatchState;
    _streamController.add([]);

    _timer = Timer.periodic(simulationInterval, (timer) {
      if (_currentMatchId != matchId) {
        timer.cancel();
        return;
      }

      currentIndex++;

      // Check if simulation finished
      if (currentIndex >= allEvents.length) {
        timer.cancel();
        _currentMatchId = null;
        _logger.d('Simulation finished for match $matchId - stopping');

        // Update to finished state (4)
        currentMatchState.matchStatus = 4;
        // Ensure all events are there
        currentMatchState.events = allEvents;

        ref.read(selectedMatchProvider.notifier).state = currentMatchState;
        _streamController.add(allEvents);
        return;
      }

      // Get events up to current index
      final currentEvents = allEvents.sublist(0, currentIndex + 1);
      final latestEvent = currentEvents.last;

      // Calculate Intermediate Results based on current events
      final intermediates = <IbyMatchIntermediateResult>[];

      // Helper to find goals scored in a specific period only
      void addIntermediate(int period) {
        // Only add intermediate result if period has ended (Periodslut event exists)
        final periodEndEvent = currentEvents.firstWhere(
          (e) => e.period == period && e.matchEventTypeId == 9,
          orElse: () => currentEvents.first, // dummy
        );

        // Check if we found a real period end event
        if (periodEndEvent.matchEventTypeId == 9 &&
            periodEndEvent.period == period) {
          // Get score at start of this period (end of previous period or 0-0)
          int startHomeGoals = 0;
          int startAwayGoals = 0;

          if (period > 1) {
            // Find the last event of the previous period
            final prevPeriodEvents = currentEvents.where(
              (e) => e.period == period - 1,
            );
            if (prevPeriodEvents.isNotEmpty) {
              final prevPeriodLastEvent = prevPeriodEvents.last;
              startHomeGoals = prevPeriodLastEvent.goalsHomeTeam;
              startAwayGoals = prevPeriodLastEvent.goalsAwayTeam;
            }
          }

          // Goals scored IN this period = end score - start score
          final periodHomeGoals = periodEndEvent.goalsHomeTeam - startHomeGoals;
          final periodAwayGoals = periodEndEvent.goalsAwayTeam - startAwayGoals;

          intermediates.add(
            IbyMatchIntermediateResult(
              matchId: matchId,
              period: period,
              goalsHomeTeam: periodHomeGoals,
              goalsAwayTeam: periodAwayGoals,
            ),
          );
        }
      }

      // Check periods 1, 2, 3
      addIntermediate(1);
      addIntermediate(2);
      addIntermediate(3);

      // Determine match status based on latest event
      int status = 2; // Default active
      if (latestEvent.matchEventTypeId == 9) {
        // Periodslut
        status = 3; // Paus
      } else if (latestEvent.matchEventTypeId == 8) {
        // Periodstart
        status = 2; // Active
      }

      // Update match object
      // We must create a new object or modify existing if allowed.
      // IbyMatch fields are mutable, but we create a "copy" logic by fetching fresh wrapper if needed.
      // But here we can just update our local tracking object and push it.

      // To trigger Riverpod update reliably with identity check, we might want a shallow copy or
      // rely on the equality operator removal we did earlier.
      // Since we removed '==', it should update if we just pass the object (it's same instance).
      // Wait, passing same instance to StateProvider might NOT trigger if it checks identical().
      // Let's create a new list for events to ensure some change.

      // Modify state
      currentMatchState.matchStatus = status;
      currentMatchState.events = List.from(currentEvents); // New list
      currentMatchState.intermediateResults = List.from(
        intermediates,
      ); // New list
      currentMatchState.goalsHomeTeam = latestEvent.goalsHomeTeam;
      currentMatchState.goalsAwayTeam = latestEvent.goalsAwayTeam;

      // Force update.
      // Since we don't have copyWith easily available for all fields,
      // and we removed operator ==, we might need to force the provider to notify.
      // But StateProvider usually does 'if (old != new)'.
      // If we pass the SAME object reference, 'identical(old, new)' is true.
      // So we should try to clone it or create a new instance.
      // Easiest "clone" without copyWith for complex object:
      // Use cleanMockup and re-apply fields.

      final freshMatch = MatchMockupData.getMockupMatch();
      freshMatch.matchStatus = status;
      freshMatch.events = List.from(currentEvents);
      freshMatch.intermediateResults = List.from(intermediates);
      freshMatch.goalsHomeTeam = latestEvent.goalsHomeTeam;
      freshMatch.goalsAwayTeam = latestEvent.goalsAwayTeam;
      // Copy other fields if they changed dynamically? (Not for demo)

      ref.read(selectedMatchProvider.notifier).state = freshMatch;
      _streamController.add(currentEvents);

      _logger.d(
        'Simulated event $currentIndex: ${latestEvent.matchEventType} (Score: ${latestEvent.goalsHomeTeam}-${latestEvent.goalsAwayTeam})',
      );
    });
  }

  Future<void> _fetchAndUpdateMatch(int matchId, MatchService service) async {
    try {
      final match = await service.getMatch(matchId: matchId);
      ref.read(selectedMatchProvider.notifier).state = match;
      _streamController.add(match.events ?? []);

      // Handle status changes
      // Match statuses: 0=N/A, 1=Ej påbörjad, 2=Spel pågår, 3=Paus, 4=Färdigspelad
      if (match.matchStatus != _lastKnownStatus) {
        _logger.d(
          'Match $matchId status changed from ${_lastKnownStatus} to ${match.matchStatus}',
        );

        if (match.matchStatus == 4) {
          // Match finished - stop streaming
          _logger.d('Match $matchId finished, stopping streaming');
          stopStreaming();
        } else if (match.matchStatus == 2 || match.matchStatus == 3) {
          // Match is active or paused - adjust timer interval
          _logger.d('Match $matchId status changed, adjusting timer interval');
          _startTimerWithInterval(matchId, service, match.matchStatus);
        } else {
          // Match is not started or other status - stop streaming
          _logger.d(
            'Match $matchId no longer active/paused, stopping streaming',
          );
          stopStreaming();
        }

        _lastKnownStatus = match.matchStatus;
      }
    } catch (e) {
      _logger.e('Error fetching match', e);
    }
  }

  void stopStreaming() {
    _timer?.cancel();
    _timer = null;
    _currentMatchId = null;
    _lastKnownStatus = null;
    _logger.d('Streaming stopped and state cleared');
  }
}

class LiveEvents extends ConsumerWidget {
  final ScrollController scrollController;

  const LiveEvents({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveMatch = ref.watch(effectiveMatchProvider);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          LiveMatchCard(match: effectiveMatch),
          const SizedBox(height: 4),
          Expanded(
            child: effectiveMatch.matchId != 0
                ? _buildEventsList(context, ref)
                : Center(
                    child: Text(
                      l10n.translate('events.select_match_to_view_events'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, WidgetRef ref) {
    final isManualMode = ref.watch(isManualLineupModeProvider);

    return ref
        .watch(matchEventsStreamProvider)
        .when(
          data: (events) => _buildEventsListView(context, events, ref),
          loading: () => isManualMode
              ? _buildEventsListView(
                  context,
                  [],
                  ref,
                ) // Skip loading indicator in manual mode
              : Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
          error: (error, _) => Center(
            child: Text(
              '${context.l10n.translate('events.error_loading_events')}: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
  }

  Widget _buildEventsListView(
    BuildContext context,
    List<IbyMatchEvent> apiEvents,
    WidgetRef ref,
  ) {
    // Get manual events and combine with API events
    final manualEvents = ref.watch(manualEventsProvider);
    final allEvents = <IbyMatchEvent>[...apiEvents, ...manualEvents];

    // Sort by time (latest first for live display)
    allEvents.sort((a, b) {
      if (a.period != b.period) return b.period.compareTo(a.period);
      if (a.minute != b.minute) return b.minute.compareTo(a.minute);
      return b.second.compareTo(a.second);
    });

    if (allEvents.isEmpty) {
      final isManualMode = ref.watch(isManualLineupModeProvider);
      final l10n = context.l10n;
      return Center(
        child: Text(
          isManualMode
              ? l10n.translate('events.no_events_generated_yet')
              : l10n.translate('events.no_events_yet'),
        ),
      );
    }

    final effectiveMatch = ref.watch(effectiveMatchProvider);
    final isLive = effectiveMatch.matchStatus != 4;

    return ListView.builder(
      controller: scrollController,
      itemCount: allEvents.length,
      itemBuilder: (context, index) {
        final eventIndex = isLive ? index : allEvents.length - 1 - index;
        final event = allEvents[eventIndex];
        final isManual = manualEvents.contains(event);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 1, horizontal: 2),
          decoration: isManual
              ? BoxDecoration(
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.7),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(4),
                )
              : null,
          child: Stack(
            children: [
              EventWidget(key: ValueKey('${event.matchEventId}'), data: event),
              if (isManual)
                Positioned(
                  top: 2,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: const Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Contains AI-generated edits.
