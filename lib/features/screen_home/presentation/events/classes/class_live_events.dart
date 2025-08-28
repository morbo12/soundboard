import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/api_client_provider.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/match_service.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_event.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/screen_home/presentation/events/widgets/live_match_card.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/providers/manual_lineup_providers.dart';
import '../../live/widget_event.dart';

part 'class_live_events.g.dart';

@riverpod
class MatchEventsStream extends _$MatchEventsStream {
  static const _logger = Logger('MatchEventsStream');

  Timer? _timer;
  final _streamController = StreamController<List<IbyMatchEvent>>.broadcast();
  bool _isInitialized = false;

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
    if (_timer?.isActive ?? false) return;

    final apiClient = ref.watch(apiClientProvider);
    final matchService = MatchService(apiClient);

    // Clear existing events when starting a new stream
    _streamController.add([]);

    // Initial fetch
    await _fetchAndUpdateMatch(matchId, matchService);

    // Start periodic updates
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _fetchAndUpdateMatch(matchId, matchService),
    );
  }

  Future<void> _fetchAndUpdateMatch(int matchId, MatchService service) async {
    try {
      final match = await service.getMatch(matchId: matchId);
      ref.read(selectedMatchProvider.notifier).state = match;
      _streamController.add(match.events ?? []);
      if (match.matchStatus == 4) {
        stopStreaming();
      }
    } catch (e) {
      _logger.e('Error fetching match', e);
    }
  }

  void stopStreaming() {
    _timer?.cancel();
    _timer = null;
  }
}

class LiveEvents extends ConsumerWidget {
  final ScrollController scrollController;

  const LiveEvents({super.key, required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveMatch = ref.watch(effectiveMatchProvider);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          LiveMatchCard(match: effectiveMatch),
          const SizedBox(height: 4),
          Expanded(
            child: effectiveMatch.matchId != 0
                ? _buildEventsList(context, ref)
                : const Center(child: Text('Select a match to view events')),
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
          data: (events) => _buildEventsListView(events, ref),
          loading: () => isManualMode
              ? _buildEventsListView(
                  [],
                  ref,
                ) // Skip loading indicator in manual mode
              : Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
          error: (error, _) => Center(
            child: Text(
              'Error loading events: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
  }

  Widget _buildEventsListView(List<IbyMatchEvent> apiEvents, WidgetRef ref) {
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
      return Center(
        child: Text(
          isManualMode
              ? 'No events generated yet. Use the event generator below to create events.'
              : 'No events yet',
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
