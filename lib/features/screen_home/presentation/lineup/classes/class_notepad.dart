import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_color_state_notifier.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';

class Notepad extends ConsumerStatefulWidget {
  final dynamic availableWidth;

  const Notepad({super.key, required this.availableWidth});

  @override
  ConsumerState<Notepad> createState() => _NotepadState();
}

class _NotepadState extends ConsumerState<Notepad> {
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _assistController = TextEditingController();
  final TextEditingController _penaltyPlayerController =
      TextEditingController();
  // State variables
  bool _showTimeError = false;
  String? _selectedPenaltyCode;
  int _selectedEventTypeIndex = 0; // 0 for Goal, 1 for Penalty
  int _selectedTeamIndex = 0; // 0 for Home, 1 for Away

  @override
  void dispose() {
    _timeController.dispose();
    _penaltyPlayerController.dispose();
    _goalController.dispose();
    _assistController.dispose();
    // Reset highlighted players when disposing
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final playerState = ref.watch(playerStatesProvider.notifier);
    late final List<PenaltyType> _penaltyTypes = PenaltyTypes.penaltyTypes;
    // String _selectedTeam = 'home'; // Default to 'home'

    return Row(
      children: [
        // Time Input
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                fillColor: theme.colorScheme.secondaryContainer,
                labelText: 'Time',
                filled: true,
                counterText: '',
              ),
              textAlign: TextAlign.center,
              controller: _timeController,
              maxLength: 4,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: 18,
                color: _showTimeError
                    ? Colors.red
                    : theme.colorScheme.onSecondaryContainer,
              ),
              onTap: () {
                _timeController.clear();
                _goalController.clear();
                _assistController.clear();
                _penaltyPlayerController.clear();
                playerState.clearAllStates();
              },
              onChanged: _handleTimeInput,
            ),
          ),
        ),
        ToggleButtons(
          isSelected: [_selectedTeamIndex == 0, _selectedTeamIndex == 1],
          onPressed: (index) {
            setState(() {
              _selectedTeamIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Theme.of(context).colorScheme.primary,
          color: Theme.of(context).colorScheme.onSurface,
          constraints: const BoxConstraints(
            minHeight: 36.0,
            minWidth: 72.0,
          ),
          children: const [
            Text('Home'),
            Text('Away'),
          ],
        ),

        // Event Type Dropdown
        ToggleButtons(
          isSelected: [
            _selectedEventTypeIndex == 0,
            _selectedEventTypeIndex == 1
          ],
          onPressed: (index) {
            setState(() {
              _selectedEventTypeIndex = index;
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Theme.of(context).colorScheme.primary,
          color: Theme.of(context).colorScheme.onSurface,
          constraints: const BoxConstraints(
            minHeight: 36.0,
            minWidth: 72.0,
          ),
          children: const [
            Text('Goal'),
            Text('Penalty'),
          ],
        ),
// Modified Goal Maker field
        if (_selectedEventTypeIndex == 0) ...[
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: theme.colorScheme.secondaryContainer,
                  labelText: 'Goal',
                  filled: true,
                  counterText: '',
                ),
                controller: _goalController,
                maxLength: 2,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                // onTap: () => _goalMakerController.clear(),
                onChanged: (value) {
                  final numberValue = int.tryParse(value) ?? 0;
                  String playerId = _findPlayerIdByNumber(numberValue, ref);

                  playerState.setGoalState(playerId);

                  // ref.read(highlightedPlayerProvider.notifier).state = {
                  //   ...ref.read(highlightedPlayerProvider),
                  //   'goal': {
                  //     'number': numberValue,
                  //     'id': playerId,
                  //     'team': _selectedTeamIndex == 0 ? 'home' : 'away',
                  // },
                  // };
                },
              ),
            ),
          ),
          // Modified Assist field
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: theme.colorScheme.secondaryContainer,
                  labelText: 'Assist',
                  filled: true,
                  counterText: '',
                ),
                controller: _assistController,
                maxLength: 2,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onTap: () => _assistController.clear(),
                onChanged: (value) {
                  String playerId =
                      _findPlayerIdByNumber(int.tryParse(value) ?? 0, ref);
                  playerState.setAssistState(playerId);
                },
              ),
            ),
          ),
        ],

        // For penalties
        if (_selectedEventTypeIndex == 1) ...[
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: TextField(
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: theme.colorScheme.secondaryContainer,
                  labelText: 'Player',
                  filled: true,
                  counterText: '', // Hides the counter
                ),
                controller: _penaltyPlayerController,
                maxLength: 2,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: (value) {
                  String playerId =
                      _findPlayerIdByNumber(int.tryParse(value) ?? 0, ref);
                  playerState.setPenaltyState(playerId);
                },
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  isDense: true,
                  fillColor: theme.colorScheme.secondaryContainer,
                  labelText: 'Penalty Code',
                  filled: true,
                ),
                value: _selectedPenaltyCode,
                selectedItemBuilder: (BuildContext context) {
                  // This builds the selected item display
                  return _penaltyTypes.map<Widget>((PenaltyType penaltyType) {
                    String displayText =
                        '${penaltyType.code} - ${penaltyType.name} (${penaltyType.penaltyTime})';
                    if (displayText.length > 55) {
                      displayText = '${displayText.substring(0, 55)}...';
                    }
                    return Text(displayText);
                  }).toList();
                },
                items: _penaltyTypes.map((penaltyType) {
                  // This builds the dropdown items
                  return DropdownMenuItem<String>(
                    value: penaltyType.code,
                    child: Text(
                      '${penaltyType.code} - ${penaltyType.name} (${penaltyType.penaltyTime})',
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedPenaltyCode = newValue;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _handleTimeInput(String value) {
    if (value.length >= 3) {
      String minutes = value.substring(0, value.length - 2);
      String seconds = value.substring(value.length - 2);

      int minutesInt = int.parse(minutes);
      int secondsInt = int.parse(seconds);

      if (minutesInt > 20) {
        setState(() {
          _showTimeError = true;
        });
        _flashRedAndClear();
        return;
      }

      if (secondsInt > 59) secondsInt = 59;

      String formattedTime =
          '$minutesInt:${secondsInt.toString().padLeft(2, '0')}';

      _timeController.value = TextEditingValue(
        text: formattedTime,
        selection: TextSelection.collapsed(offset: formattedTime.length),
      );
      setState(() {
        _showTimeError = false;
      });
    }
  }

  String _findPlayerIdByNumber(int number, WidgetRef ref) {
    final selectedMatchLineup = ref.read(lineupProvider);

    if (_selectedTeamIndex == 0) {
      // Check home team players
      final homePlayer = selectedMatchLineup.homeTeamPlayers.firstWhere(
        (player) => player.shirtNo == number,
        orElse: () => TeamPlayer(shirtNo: 0, name: '', position: ''),
      );
      if (homePlayer.shirtNo == number) {
        return '${homePlayer.shirtNo}-${homePlayer.name}';
      }
    } else if (_selectedTeamIndex == 1) {
      // Check away team players
      final awayPlayer = selectedMatchLineup.awayTeamPlayers.firstWhere(
        (player) => player.shirtNo == number,
        orElse: () => TeamPlayer(shirtNo: null, name: '', position: ''),
      );

      if (awayPlayer.shirtNo == number) {
        return '${awayPlayer.shirtNo}-${awayPlayer.name}';
      }
    }
    return '';
  }

  void _flashRedAndClear() {
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showTimeError = false;
        _timeController.clear();
      });
    });
  }
}
