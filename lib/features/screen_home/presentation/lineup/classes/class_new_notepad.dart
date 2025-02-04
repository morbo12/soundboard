import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';

class GoalInputWidget extends ConsumerStatefulWidget {
  final String team;

  GoalInputWidget({super.key, required this.team});

  @override
  _GoalInputWidgetState createState() => _GoalInputWidgetState();
}

class _GoalInputWidgetState extends ConsumerState<GoalInputWidget> {
  final TextEditingController _controller = TextEditingController();
  String _time = '';
  String _scorer = '';
  String _assist = '';
  String _errorMessage = '';
  static const double _smallFontSize = 16.0;

  String _parseTime(String timeStr) {
    if (timeStr.isEmpty) return '';

    // Remove any leading zeros
    timeStr = timeStr.replaceFirst(RegExp(r'^0+'), '');

    try {
      int timeInt = int.parse(timeStr);

      // Handle different input lengths
      if (timeStr.length <= 2) {
        if (timeInt > 59) throw FormatException('Invalid minutes/seconds');
        return '00:${timeInt.toString().padLeft(2, '0')}';
      } else if (timeStr.length == 3) {
        int minutes = timeInt ~/ 100;
        int seconds = timeInt % 100;
        if (seconds > 59) throw FormatException('Invalid seconds');
        if (minutes > 20) throw FormatException('Time cannot exceed 20:00');
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      } else if (timeStr.length == 4) {
        int minutes = timeInt ~/ 100;
        int seconds = timeInt % 100;
        if (seconds > 59) throw FormatException('Invalid seconds');
        if (minutes > 20) throw FormatException('Time cannot exceed 20:00');
        return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      }
    } catch (e) {
      return '';
    }

    return '';
  }

  void _parseInput(String input) {
    setState(() {
      _errorMessage = '';
    });

    // Split the input by spaces
    List<String> parts = input.split(' ');

    try {
      // Parse time (first part)
      if (parts.isNotEmpty) {
        _time = _parseTime(parts[0]);
      }

      // Parse scorer number (second part)
      if (parts.length > 1) {
        try {
          int scorer = int.parse(parts[1]);
          if (scorer >= 1 && scorer <= 99) {
            print("Scorer: $scorer");
            _scorer = _findPlayerIdByNumber(scorer, ref);
          } else {
            _scorer = '';
          }
        } catch (e) {
          _scorer = '';
        }
      }

      // Parse assist number (third part) - optional
      if (parts.length > 2) {
        try {
          int assist = int.parse(parts[2]);
          if (assist >= 1 && assist <= 99) {
            _assist = _findPlayerIdByNumber(assist, ref);
          } else {
            _assist = '';
          }
        } catch (e) {
          _assist = '';
        }
      } else {
        _assist = '';
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is FormatException ? e.message : 'Invalid format';
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final playerState = ref.watch(playerStatesProvider.notifier);

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: TextField(
            onTap: () {
              _assist = '';
              _scorer = '';
            },
            controller: _controller,
            decoration: InputDecoration(
              labelText: 'Goal scratchpad (time scorer [assist])',
              hintText: 'Exempel: 112 10 7 (01:12, #10, #7)',
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
            ),
            keyboardType: TextInputType.number,
            onChanged: (input) {
              _parseInput(input);
            },
          ),
        ),
        SizedBox(height: 10),
        Card(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Container(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_time.isNotEmpty)
                    Text('Tid: $_time',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: _smallFontSize)),
                  if (_scorer.isNotEmpty)
                    Text(
                      'Mål: $_scorer',
                      style: TextStyle(
                          color: Colors.lime,
                          fontWeight: FontWeight.bold,
                          fontSize: _smallFontSize),
                    ),
                  if (_assist.isNotEmpty)
                    Text('Assist: $_assist',
                        style: TextStyle(
                            color: Colors.lime,
                            fontWeight: FontWeight.bold,
                            fontSize: _smallFontSize)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _findPlayerIdByNumber(int number, WidgetRef ref) {
    final selectedMatchLineup = ref.read(lineupProvider);

    if (widget.team == "homeTeam") {
      final homePlayer = selectedMatchLineup.homeTeamPlayers.firstWhere(
        (player) => player.shirtNo == number,
        orElse: () => TeamPlayer(shirtNo: 0, name: '', position: ''),
      );
      if (homePlayer.shirtNo == number) {
        return '${homePlayer.shirtNo}-${homePlayer.name}';
      }
    } else if (widget.team == "awayTeam") {
      final awayPlayer = selectedMatchLineup.awayTeamPlayers.firstWhere(
        (player) => player.shirtNo == number,
        orElse: () => TeamPlayer(shirtNo: null, name: '', position: ''),
      );

      if (awayPlayer?.shirtNo == number) {
        return '${awayPlayer.shirtNo}-${awayPlayer.name}';
      }
    }
    return '';
  }
}
