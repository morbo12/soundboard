import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_color_state_notifier.dart';

class GoalInputWidget extends ConsumerStatefulWidget {
  final String team;
  const GoalInputWidget({super.key, required this.team});

  @override
  _GoalInputWidgetState createState() => _GoalInputWidgetState();
}

class _GoalInputWidgetState extends ConsumerState<GoalInputWidget> {
  final _controller = TextEditingController();
  Timer? _debounceTimer;
  String _time = '';
  String _scorer = '';
  String _assist = '';
  String _errorMessage = '';

  void _processInput(String input) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      final parts = input.split(' ');
      setState(() {
        _errorMessage = '';
        _time = _parseTime(parts.isNotEmpty ? parts[0] : '');
        _scorer = parts.length > 1 ? _findPlayer(parts[1]) : '';
        _assist = parts.length > 2 ? _findPlayer(parts[2]) : '';
      });

      // Debugging
      if (kDebugMode) {
        if (kDebugMode) {
          print('Scorer: $_scorer');
        }
      }
      if (kDebugMode) {
        print('Assist: $_assist');
      }

      // Update player states if valid
      final playerState = ref.read(playerStatesProvider.notifier);
      if (_scorer.isNotEmpty) {
        if (kDebugMode) {
          print('Setting scorer state: $_scorer');
        }
        playerState.setGoalState(_scorer);
      }
      if (_assist.isNotEmpty) {
        if (kDebugMode) {
          print('Setting assist state: $_assist');
        }
        playerState.setAssistState(_assist);
      }
    });
  }

  String _parseTime(String timeStr) {
    if (timeStr.isEmpty) return '';

    try {
      final time = int.parse(timeStr.replaceFirst(RegExp(r'^0+'), ''));
      if (timeStr.length <= 2) {
        return time <= 59 ? '00:${time.toString().padLeft(2, '0')}' : '';
      }
      final minutes = time ~/ 100;
      final seconds = time % 100;
      return (seconds <= 59 && minutes <= 20)
          ? '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
          : '';
    } catch (e) {
      return '';
    }
  }

  String _findPlayer(String numberStr) {
    try {
      final number = int.parse(numberStr);
      if (number < 1 || number > 99) return '';

      final lineup = ref.read(lineupProvider);
      final players = widget.team == "homeTeam"
          ? lineup.homeTeamPlayers
          : lineup.awayTeamPlayers;

      final player = players.firstWhere(
        (p) => p.shirtNo == number,
        orElse: () => TeamPlayer(shirtNo: 0, name: '', position: ''),
      );

      return player.shirtNo == number ? '${player.shirtNo}-${player.name}' : '';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.read(playerStatesProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Goal scratchpad (time scorer [assist])',
              hintText: 'Example: 112 10 7 (01:12, #10, #7)',
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            ),
            keyboardType: TextInputType.number,
            onChanged: _processInput,
            onTap: () => setState(() {
              _scorer = '';
              _assist = '';
              playerState.clearAllStates();
            }),
          ),
        ),
        const SizedBox(height: 10),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_time.isNotEmpty)
                  Text('Tid: $_time',
                      style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      )),
                if (_scorer.isNotEmpty)
                  Text('Mål: $_scorer',
                      style: const TextStyle(
                        color: Colors.lime,
                        fontWeight: FontWeight.bold,
                      )),
                if (_assist.isNotEmpty)
                  Text('Assist: $_assist',
                      style: const TextStyle(
                        color: Colors.lime,
                        fontWeight: FontWeight.bold,
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
