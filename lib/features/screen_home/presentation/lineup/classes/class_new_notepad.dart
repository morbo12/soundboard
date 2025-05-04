import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import 'package:soundboard/features/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_color_state_notifier.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';
import 'package:soundboard/utils/logger.dart';

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
  final logger = const Logger('GoalInputWidget');

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
      logger.d('Scorer: $_scorer');
      logger.d('Assist: $_assist');

      // Update player states if valid
      final playerState = ref.read(playerStatesProvider.notifier);
      if (_scorer.isNotEmpty) {
        logger.d('Setting scorer state: $_scorer');
        playerState.setGoalState(_scorer);
      }
      if (_assist.isNotEmpty) {
        logger.d('Setting assist state: $_assist');
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
      final players =
          widget.team == "homeTeam"
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
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              labelText: 'Goal (time scorer [assist])',
              hintText: '112 10 7',
              errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
              labelStyle: const TextStyle(fontSize: 12),
              hintStyle: const TextStyle(fontSize: 12),
            ),
            style: const TextStyle(fontSize: 12),
            keyboardType: TextInputType.number,
            onChanged: _processInput,
            onTap:
                () => setState(() {
                  _scorer = '';
                  _assist = '';
                  playerState.clearAllStates();
                }),
          ),
        ),
        if (_time.isNotEmpty || _scorer.isNotEmpty || _assist.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_time.isNotEmpty)
                    Text(
                      'Tid: $_time',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_scorer.isNotEmpty)
                    Text(
                      'Mål: $_scorer',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.lime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_assist.isNotEmpty)
                    Text(
                      'Assist: $_assist',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.lime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

class PenaltyInputWidget extends ConsumerStatefulWidget {
  final String team;
  const PenaltyInputWidget({super.key, required this.team});

  @override
  _PenaltyInputWidgetState createState() => _PenaltyInputWidgetState();
}

class _PenaltyInputWidgetState extends ConsumerState<PenaltyInputWidget> {
  final _controller = TextEditingController();
  final _penaltySearchController = TextEditingController();
  Timer? _debounceTimer;
  String _time = '';
  String _player = '';
  String _penaltyCode = '';
  String _errorMessage = '';
  final logger = const Logger('PenaltyInputWidget');
  List<PenaltyType> _filteredPenalties = [];
  bool _showPenaltySearch = false;

  @override
  void initState() {
    super.initState();
    _filteredPenalties = PenaltyTypes.penaltyTypes;
    _penaltySearchController.addListener(_filterPenalties);
  }

  void _filterPenalties() {
    final searchText = _penaltySearchController.text.trim();
    logger.d('Searching for: "$searchText"');

    setState(() {
      if (searchText.isEmpty) {
        _filteredPenalties = PenaltyTypes.penaltyTypes;
      } else {
        // Check if search text starts with a number (code search)
        final isCodeSearch = RegExp(r'^\d').hasMatch(searchText);

        _filteredPenalties =
            PenaltyTypes.penaltyTypes.where((penalty) {
              if (isCodeSearch) {
                // Search by code (exact match)
                return penalty.code == searchText;
              } else {
                // Search by name (exact word match)
                final searchWords = searchText.toLowerCase().split(' ');
                final penaltyWords = penalty.name.toLowerCase().split(' ');

                // Check if any word in the search text matches any word in the penalty name
                return searchWords.any(
                  (searchWord) => penaltyWords.any(
                    (penaltyWord) =>
                        penaltyWord == searchWord ||
                        penaltyWord.startsWith(searchWord),
                  ),
                );
              }
            }).toList();

        logger.d('Search type: ${isCodeSearch ? 'Code' : 'Name'}');
        logger.d('Found ${_filteredPenalties.length} matching penalties');
      }
    });
  }

  void _processInput(String input) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      final parts = input.split(' ');
      setState(() {
        _errorMessage = '';
        _time = _parseTime(parts.isNotEmpty ? parts[0] : '');

        // Only update player state if we have a complete player number
        final newPlayer = parts.length > 1 ? _findPlayer(parts[1]) : '';
        if (newPlayer != _player) {
          _player = newPlayer;
          // Update player states if valid
          final playerState = ref.read(playerStatesProvider.notifier);
          if (_player.isNotEmpty) {
            logger.d('Setting penalty state: $_player');
            playerState.setPenaltyState(_player);
          } else {
            playerState.clearAllStates();
          }
        }

        // Handle penalty code/name
        if (parts.length > 2) {
          final penaltyInput = parts[2];
          // Check if input is a code (starts with number)
          if (RegExp(r'^\d').hasMatch(penaltyInput)) {
            _penaltyCode = penaltyInput;
          } else {
            // Search for penalty by name
            final searchWords = penaltyInput.toLowerCase().split(' ');
            final matchingPenalty = PenaltyTypes.penaltyTypes.firstWhere((
              penalty,
            ) {
              final penaltyWords = penalty.name.toLowerCase().split(' ');
              return searchWords.any(
                (searchWord) => penaltyWords.any(
                  (penaltyWord) =>
                      penaltyWord == searchWord ||
                      penaltyWord.startsWith(searchWord),
                ),
              );
            }, orElse: () => PenaltyType(code: '', name: '', penaltyTime: ''));
            _penaltyCode = matchingPenalty.code;
          }
        } else {
          _penaltyCode = '';
        }
      });

      // Debugging
      logger.d('Player: $_player');
      logger.d('Penalty Code: $_penaltyCode');
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
      final players =
          widget.team == "homeTeam"
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

  String _getPenaltyInfo() {
    if (_penaltyCode.isEmpty) return '';
    final penaltyInfo = PenaltyTypes.getPenaltyInfo(_penaltyCode);
    return '${penaltyInfo['name']} (${penaltyInfo['time']})';
  }

  @override
  Widget build(BuildContext context) {
    final playerState = ref.read(playerStatesProvider.notifier);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  labelText: 'Penalty (time player code)',
                  hintText: '112 10 201',
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  labelStyle: const TextStyle(fontSize: 12),
                  hintStyle: const TextStyle(fontSize: 12),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, size: 20),
                    onPressed: () {
                      setState(() {
                        _showPenaltySearch = !_showPenaltySearch;
                        if (!_showPenaltySearch) {
                          _penaltySearchController.clear();
                          _filteredPenalties = PenaltyTypes.penaltyTypes;
                        }
                      });
                    },
                  ),
                ),
                style: const TextStyle(fontSize: 12),
                keyboardType: TextInputType.number,
                onChanged: _processInput,
                onTap:
                    () => setState(() {
                      _player = '';
                      _penaltyCode = '';
                      playerState.clearAllStates();
                    }),
              ),
              if (_showPenaltySearch)
                Container(
                  margin: const EdgeInsets.only(top: 4.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _penaltySearchController,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          hintText: 'Search penalty by code or name',
                          hintStyle: TextStyle(fontSize: 12),
                          prefixIcon: Icon(Icons.search, size: 20),
                        ),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Flexible(
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          child:
                              _filteredPenalties.isEmpty
                                  ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'No penalties found',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  )
                                  : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: _filteredPenalties.length,
                                    itemBuilder: (context, index) {
                                      final penalty = _filteredPenalties[index];
                                      return ListTile(
                                        dense: true,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                              vertical: 0.0,
                                            ),
                                        title: Text(
                                          '${penalty.code} - ${penalty.name}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        subtitle: Text(
                                          'Time: ${penalty.penaltyTime}',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        onTap: () {
                                          setState(() {
                                            _penaltyCode = penalty.code;
                                            _showPenaltySearch = false;
                                          });
                                        },
                                      );
                                    },
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        if (_time.isNotEmpty || _player.isNotEmpty || _penaltyCode.isNotEmpty)
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_time.isNotEmpty)
                    Text(
                      'Tid: $_time',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_player.isNotEmpty)
                    Text(
                      'Spelare: $_player',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.lime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (_penaltyCode.isNotEmpty)
                    Text(
                      'Utvisning: ${_getPenaltyInfo()}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.lime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
    _penaltySearchController.dispose();
    super.dispose();
  }
}
