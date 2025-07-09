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

    // Only add initial empty list if not already initialized
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
    final selectedMatch = ref.watch(selectedMatchProvider);

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          LiveMatchCard(match: selectedMatch),
          const SizedBox(height: 4),
          Expanded(
            child: selectedMatch.matchId != 0
                ? _buildEventsList(context, ref)
                : const Center(child: Text('Select a match to view events')),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, WidgetRef ref) {
    return ref
        .watch(matchEventsStreamProvider)
        .when(
          data: (events) => _buildEventsListView(events, ref),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              'Error loading events: $error',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        );
  }

  Widget _buildEventsListView(List<IbyMatchEvent> events, WidgetRef ref) {
    if (events.isEmpty) return const Center(child: Text('No events yet'));

    final selectedMatch = ref.watch(selectedMatchProvider);
    final isLive = selectedMatch.matchStatus != 4;

    return ListView.builder(
      controller: scrollController,
      itemCount: events.length,
      itemBuilder: (context, index) {
        final eventIndex = isLive ? index : events.length - 1 - index;
        return EventWidget(
          key: ValueKey('${events[eventIndex].matchEventId}'),
          data: events[eventIndex],
        );
      },
    );
  }
}

// Contains AI-generated edits.
