import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_event.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/providers/manual_lineup_providers.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/services/manual_event_service.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';

// Custom input formatter for mm:ss time format
class _TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove any non-digit characters except colon
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9:]'), '');

    // Limit length to 5 characters (mm:ss)
    if (newText.length > 5) {
      newText = newText.substring(0, 5);
    }

    // Auto-insert colon after 2 digits
    if (newText.length >= 2 && !newText.contains(':')) {
      newText = '${newText.substring(0, 2)}:${newText.substring(2)}';
    }

    // Ensure proper format
    if (newText.length > 2 && newText[2] != ':') {
      newText = '${newText.substring(0, 2)}:${newText.substring(2)}';
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class ManualEventGeneratorWidget extends ConsumerStatefulWidget {
  final double availableWidth;
  final double availableHeight;

  const ManualEventGeneratorWidget({
    super.key,
    required this.availableWidth,
    required this.availableHeight,
  });

  @override
  ConsumerState<ManualEventGeneratorWidget> createState() =>
      _ManualEventGeneratorWidgetState();
}

class _ManualEventGeneratorWidgetState
    extends ConsumerState<ManualEventGeneratorWidget> {
  String selectedEventType = 'goal';
  bool isHomeTeam = true;
  TeamPlayer? selectedPlayer;
  TeamPlayer? selectedAssistPlayer; // Add assist player selection
  String selectedPenaltyCode = '201'; // Default to "Slag"
  int selectedPeriod = 1; // Default period
  final TextEditingController _minuteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Listen to text changes to update button state
    _minuteController.addListener(() {
      setState(() {
        // This will trigger a rebuild and re-evaluate _canGenerateEvent()
      });
    });
  }

  @override
  void dispose() {
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final homeTeamPlayers = ref.watch(manualHomeTeamPlayersProvider);
    final awayTeamPlayers = ref.watch(manualAwayTeamPlayersProvider);

    return Container(
      width: widget.availableWidth,
      height: widget.availableHeight,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          // Compact Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              'Quick Event Generator',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  // Row 1: Event Type + Time + Team Selection
                  Row(
                    children: [
                      // Event Type (Compact dropdown)
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Event',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 36,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: theme.colorScheme.outline.withValues(
                                    alpha: 0.4,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(6),
                                color: theme.colorScheme.surface,
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedEventType,
                                  isDense: true,
                                  isExpanded: true,
                                  icon: Icon(
                                    Icons.keyboard_arrow_down,
                                    size: 16,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  style: theme.textTheme.bodyMedium,
                                  items: [
                                    const DropdownMenuItem(
                                      value: 'goal',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.sports_soccer,
                                            size: 14,
                                            color: Colors.green,
                                          ),
                                          SizedBox(width: 4),
                                          Text('Mål'),
                                        ],
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'penalty',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.rectangle,
                                            size: 14,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 4),
                                          Text('Utvisning'),
                                        ],
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'timeout',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.pause,
                                            size: 14,
                                            color: Colors.orange,
                                          ),
                                          SizedBox(width: 4),
                                          Text('Timeout'),
                                        ],
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'period_start',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.play_arrow,
                                            size: 14,
                                            color: Colors.blue,
                                          ),
                                          SizedBox(width: 4),
                                          Text('Periodstart'),
                                        ],
                                      ),
                                    ),
                                    const DropdownMenuItem(
                                      value: 'period_end',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.stop,
                                            size: 14,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 4),
                                          Text('Periodslut'),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() {
                                        selectedEventType = value;
                                        selectedPlayer = null;
                                        selectedAssistPlayer = null;
                                        selectedPenaltyCode = '201';
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Time Input (Compact)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Time',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              height: 36,
                              child: TextFormField(
                                controller: _minuteController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.outline
                                          .withValues(alpha: 0.4),
                                    ),
                                  ),
                                  hintText: 'Ex. 12:30',
                                  hintStyle: theme.textTheme.bodySmall
                                      ?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                ),
                                style: theme.textTheme.bodyMedium,
                                keyboardType: TextInputType.text,
                                inputFormatters: [_TimeInputFormatter()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Team Toggle (Compact Switch)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Team',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 36,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        isHomeTeam = true;
                                        selectedPlayer = null;
                                        selectedAssistPlayer = null;
                                      }),
                                      child: Container(
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                left: Radius.circular(6),
                                              ),
                                          color: isHomeTeam
                                              ? theme.colorScheme.primary
                                              : Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'H',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: isHomeTeam
                                                      ? theme
                                                            .colorScheme
                                                            .onPrimary
                                                      : theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() {
                                        isHomeTeam = false;
                                        selectedPlayer = null;
                                        selectedAssistPlayer = null;
                                      }),
                                      child: Container(
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              const BorderRadius.horizontal(
                                                right: Radius.circular(6),
                                              ),
                                          color: !isHomeTeam
                                              ? theme.colorScheme.primary
                                              : Colors.transparent,
                                        ),
                                        child: Center(
                                          child: Text(
                                            'A',
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: !isHomeTeam
                                                      ? theme
                                                            .colorScheme
                                                            .onPrimary
                                                      : theme
                                                            .colorScheme
                                                            .onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2: Contextual selections based on event type
                  Row(
                    children: [
                      // Player Selection (for goals and penalties)
                      if (_shouldShowPlayerSelection()) ...[
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Player',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: theme.colorScheme.surface,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<TeamPlayer>(
                                    value: selectedPlayer,
                                    hint: Text(
                                      'Select player',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    isDense: true,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                    items:
                                        (isHomeTeam
                                                ? homeTeamPlayers
                                                : awayTeamPlayers)
                                            .map(
                                              (player) => DropdownMenuItem(
                                                value: player,
                                                child: Text(
                                                  '${player.shirtNo} - ${player.name ?? "Unknown"}',
                                                  style:
                                                      theme.textTheme.bodySmall,
                                                ),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) =>
                                        setState(() => selectedPlayer = value),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Assist Player Selection (only for goals)
                      if (selectedEventType == 'goal') ...[
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Assist (optional)',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: theme.colorScheme.surface,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<TeamPlayer>(
                                    value: selectedAssistPlayer,
                                    hint: Text(
                                      'No assist',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                    isDense: true,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                    items: [
                                      DropdownMenuItem<TeamPlayer>(
                                        value: null,
                                        child: Text(
                                          'No assist',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ),
                                      ...(isHomeTeam
                                              ? homeTeamPlayers
                                              : awayTeamPlayers)
                                          .where(
                                            (player) =>
                                                player != selectedPlayer,
                                          ) // Exclude the goal scorer
                                          .map(
                                            (player) => DropdownMenuItem(
                                              value: player,
                                              child: Text(
                                                '${player.shirtNo} - ${player.name ?? "Unknown"}',
                                                style:
                                                    theme.textTheme.bodySmall,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    ],
                                    onChanged: (value) => setState(
                                      () => selectedAssistPlayer = value,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Penalty Code Selection (only for penalties)
                      if (selectedEventType == 'penalty') ...[
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Penalty Type',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: theme.colorScheme.surface,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedPenaltyCode,
                                    isDense: true,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                    items: PenaltyTypes.penaltyTypes
                                        .map(
                                          (penalty) => DropdownMenuItem(
                                            value: penalty.code,
                                            child: Text(
                                              '${penalty.code} - ${penalty.name}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) => setState(
                                      () => selectedPenaltyCode = value!,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Period Selection (for period start/end)
                      if (_shouldShowPeriodSelection()) ...[
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Period',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 36,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withValues(
                                      alpha: 0.4,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                  color: theme.colorScheme.surface,
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: selectedPeriod,
                                    isDense: true,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 16,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    style: theme.textTheme.bodyMedium,
                                    items: [1, 2, 3]
                                        .map(
                                          (period) => DropdownMenuItem(
                                            value: period,
                                            child: Text(
                                              'Period $period',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) =>
                                        setState(() => selectedPeriod = value!),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Generate Button (Full width, prominent)
                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: ElevatedButton.icon(
                      onPressed: _canGenerateEvent() ? _generateEvent : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        elevation: _canGenerateEvent() ? 2 : 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle, size: 18),
                      label: Text(
                        'Generate Event',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowPlayerSelection() {
    return selectedEventType == 'goal' || selectedEventType == 'penalty';
  }

  bool _shouldShowPeriodSelection() {
    return selectedEventType == 'period_start' ||
        selectedEventType == 'period_end';
  }

  bool _canGenerateEvent() {
    if (_minuteController.text.isEmpty) return false;
    if (_shouldShowPlayerSelection() && selectedPlayer == null) return false;
    return true;
  }

  void _generateEvent() async {
    try {
      // Parse mm:ss format time
      int minute = 0;
      int second = 0;
      final timeText = _minuteController.text;
      if (timeText.contains(':')) {
        final parts = timeText.split(':');
        if (parts.length == 2) {
          minute = int.tryParse(parts[0]) ?? 0;
          second = int.tryParse(parts[1]) ?? 0;
        }
      } else {
        // Fallback: treat as minutes only
        minute = int.tryParse(timeText) ?? 0;
      }

      final effectiveMatch = ref.read(effectiveMatchProvider);
      final currentEvents = ref.read(manualEventsProvider);

      // Generate new event ID
      final eventId = DateTime.now().millisecondsSinceEpoch;

      // Create the event based on type
      IbyMatchEvent? newEvent;

      // Calculate current goals
      final homeGoals = currentEvents
          .where(
            (e) =>
                e.matchEventType == 'Mål' &&
                e.matchTeamName == effectiveMatch.homeTeam,
          )
          .length;
      final awayGoals = currentEvents
          .where(
            (e) =>
                e.matchEventType == 'Mål' &&
                e.matchTeamName == effectiveMatch.awayTeam,
          )
          .length;

      switch (selectedEventType) {
        case 'goal':
          if (selectedPlayer != null) {
            newEvent = ManualEventService.createGoalEvent(
              eventId: eventId,
              matchId: effectiveMatch.matchId,
              playerName: selectedPlayer!.name ?? 'Unknown',
              shirtNo: selectedPlayer!.shirtNo ?? 0,
              teamName: isHomeTeam
                  ? effectiveMatch.homeTeam
                  : effectiveMatch.awayTeam,
              teamId: isHomeTeam
                  ? (effectiveMatch.homeTeamId ?? 0)
                  : (effectiveMatch.awayTeamId ?? 0),
              minute: minute,
              second: second,
              period: selectedPeriod,
              periodName: 'Period $selectedPeriod',
              goalsHomeTeam: homeGoals + (isHomeTeam ? 1 : 0),
              goalsAwayTeam: awayGoals + (!isHomeTeam ? 1 : 0),
              assistName: selectedAssistPlayer?.name,
              assistShirtNo: selectedAssistPlayer?.shirtNo,
            );
          }
          break;

        case 'penalty':
          if (selectedPlayer != null) {
            newEvent = ManualEventService.createPenaltyEvent(
              eventId: eventId,
              matchId: effectiveMatch.matchId,
              playerName: selectedPlayer!.name ?? 'Unknown',
              shirtNo: selectedPlayer!.shirtNo ?? 0,
              teamName: isHomeTeam
                  ? effectiveMatch.homeTeam
                  : effectiveMatch.awayTeam,
              teamId: isHomeTeam
                  ? (effectiveMatch.homeTeamId ?? 0)
                  : (effectiveMatch.awayTeamId ?? 0),
              minute: minute,
              second: second,
              period: selectedPeriod,
              periodName: 'Period $selectedPeriod',
              penaltyCode: selectedPenaltyCode,
              penaltyName:
                  PenaltyTypes.getPenaltyInfo(selectedPenaltyCode)['name'] ??
                  'Unknown',
              goalsHomeTeam: homeGoals,
              goalsAwayTeam: awayGoals,
            );
          }
          break;

        case 'timeout':
          newEvent = ManualEventService.createTimeoutEvent(
            eventId: eventId,
            matchId: effectiveMatch.matchId,
            teamName: isHomeTeam
                ? effectiveMatch.homeTeam
                : effectiveMatch.awayTeam,
            teamId: isHomeTeam
                ? (effectiveMatch.homeTeamId ?? 0)
                : (effectiveMatch.awayTeamId ?? 0),
            minute: minute,
            second: second,
            period: selectedPeriod,
            periodName: 'Period $selectedPeriod',
            goalsHomeTeam: homeGoals,
            goalsAwayTeam: awayGoals,
            isHomeTeam: isHomeTeam,
          );
          break;

        case 'period_start':
          newEvent = ManualEventService.createPeriodEvent(
            eventId: eventId,
            matchId: effectiveMatch.matchId,
            minute: minute,
            second: second,
            period: selectedPeriod,
            periodName: 'Period $selectedPeriod',
            goalsHomeTeam: homeGoals,
            goalsAwayTeam: awayGoals,
            isStart: true,
          );
          break;

        case 'period_end':
          newEvent = ManualEventService.createPeriodEvent(
            eventId: eventId,
            matchId: effectiveMatch.matchId,
            minute: minute,
            second: second,
            period: selectedPeriod,
            periodName: 'Period $selectedPeriod',
            goalsHomeTeam: homeGoals,
            goalsAwayTeam: awayGoals,
            isStart: false,
          );
          break;
      }

      if (newEvent != null) {
        // Add to manual events
        final updatedEvents = [...currentEvents, newEvent];
        ref.read(manualEventsProvider.notifier).state = updatedEvents;

        // Clear form after successful generation
        _minuteController.clear();
        setState(() {
          selectedPlayer = null;
          selectedAssistPlayer = null;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event generated successfully!')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error generating event: $e')));
      }
    }
  }
}

// Contains AI-generated edits.
