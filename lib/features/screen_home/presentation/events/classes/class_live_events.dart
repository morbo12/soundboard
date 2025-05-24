import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soundboard/features/innebandy_api/data/datasources/remote/api_client_provider.dart';
import 'package:soundboard/features/innebandy_api/data/datasources/remote/match_service.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match_event.dart';
import 'package:soundboard/features/screen_home/presentation/events/classes/class_period_score.dart';
import 'package:soundboard/features/screen_home/presentation/events/classes/class_tts_dialog.dart';
import '../../live/widget_event.dart';

part 'class_live_events.g.dart';

@riverpod
class MatchEventsStream extends _$MatchEventsStream {
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
      debugPrint('Error fetching match: $e');
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
    return SizedBox(
      width: 350,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            _buildHeader(context, ref),
            _buildEventsList(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStreamingButton(context, ref),
          const PeriodScores(),
          _buildTtsButton(context, ref),
        ],
      ),
    );
  }

  Widget _buildStreamingButton(BuildContext context, WidgetRef ref) {
    final selectedMatch = ref.watch(selectedMatchProvider);
    return TextButton(
      onPressed: () {
        if (selectedMatch.matchId != 0) {
          ref
              .read(matchEventsStreamProvider.notifier)
              .startStreaming(selectedMatch.matchId);
        }
      },
      child: Text(
        'Matchhändelser',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildEventsList(BuildContext context, WidgetRef ref) {
    final isStreaming =
        ref.read(matchEventsStreamProvider.notifier)._timer?.isActive ?? false;

    return Expanded(
      child: ref
          .watch(matchEventsStreamProvider)
          .when(
            data: (events) {
              // Only show loading when actively streaming and have no events
              if (isStreaming && events.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final selectedMatch = ref.watch(selectedMatchProvider);
              final isLive = selectedMatch.matchStatus != 4;

              return ListView.builder(
                controller: scrollController,
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final eventIndex = isLive ? index : events.length - 1 - index;
                  return EventWidget(
                    key: ValueKey(
                      '${events[eventIndex].matchEventId}_${events[eventIndex].timeStamp}',
                    ),
                    data: events[eventIndex],
                  );
                },
              );
            },
            loading: () {
              // Only show loading indicator if we're actively streaming
              return isStreaming
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox.shrink();
            },
            error: (error, stackTrace) => Center(
              child: Text(
                'Error loading events: $error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
    );
  }

  Widget _buildTtsButton(BuildContext context, WidgetRef ref) {
    return TextButton(
      onPressed: () => TtsDialog.show(context, ref),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.record_voice_over,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            'Custom TTS',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}
