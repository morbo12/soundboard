import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/providers/manual_lineup_providers.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/widgets/player_entry_form.dart';

class ManualLineupEntryWidget extends ConsumerStatefulWidget {
  final double availableWidth;
  final double availableHeight;

  const ManualLineupEntryWidget({
    super.key,
    required this.availableWidth,
    required this.availableHeight,
  });

  @override
  ConsumerState<ManualLineupEntryWidget> createState() =>
      _ManualLineupEntryWidgetState();
}

class _ManualLineupEntryWidgetState
    extends ConsumerState<ManualLineupEntryWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeTeamName = ref.watch(manualHomeTeamNameProvider);
    final awayTeamName = ref.watch(manualAwayTeamNameProvider);
    final theme = Theme.of(context);

    return Container(
      width: widget.availableWidth,
      height: widget.availableHeight,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          // Team name editing row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: homeTeamName,
                  decoration: const InputDecoration(
                    labelText: 'Home Team',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(manualHomeTeamNameProvider.notifier).state = value;
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Text('vs'),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: awayTeamName,
                  decoration: const InputDecoration(
                    labelText: 'Away Team',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  onChanged: (value) {
                    ref.read(manualAwayTeamNameProvider.notifier).state = value;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Team tabs
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: homeTeamName),
                Tab(text: awayTeamName),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeamEditor(context, true),
                _buildTeamEditor(context, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamEditor(BuildContext context, bool isHomeTeam) {
    final players = ref.watch(
      isHomeTeam
          ? manualHomeTeamPlayersProvider
          : manualAwayTeamPlayersProvider,
    );
    final theme = Theme.of(context);

    return Column(
      children: [
        // Add player button and quick actions
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddPlayerDialog(context, isHomeTeam),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Player'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () =>
                    _showAddMultiplePlayersDialog(context, isHomeTeam),
                icon: const Icon(Icons.group_add),
                label: const Text('Add Players'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _clearTeam(isHomeTeam),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Players list
        Expanded(
          child: players.isEmpty
              ? Center(
                  child: Text(
                    'No players added yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 2.0),
                      child: ListTile(
                        leading: CircleAvatar(child: Text('${player.shirtNo}')),
                        title: Text(player.name ?? 'Unknown'),
                        subtitle: Text(player.position ?? 'Unknown'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _editPlayer(context, isHomeTeam, index);
                            } else if (value == 'delete') {
                              _removePlayer(isHomeTeam, index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showAddPlayerDialog(BuildContext context, bool isHomeTeam) {
    showDialog(
      context: context,
      builder: (context) => PlayerEntryFormDialog(
        isHomeTeam: isHomeTeam,
        existingNumbers: _getExistingNumbers(isHomeTeam),
      ),
    );
  }

  void _showAddMultiplePlayersDialog(BuildContext context, bool isHomeTeam) {
    int numberOfPlayers =
        6; // Default for Innebandy (5 field players + 1 goalkeeper)

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Multiple Players'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How many players do you want to add?'),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Players: '),
                  Expanded(
                    child: Slider(
                      value: numberOfPlayers.toDouble(),
                      min: 1,
                      max: 20,
                      divisions: 19,
                      label: numberOfPlayers.toString(),
                      onChanged: (value) {
                        setDialogState(() {
                          numberOfPlayers = value.round();
                        });
                      },
                    ),
                  ),
                  Text(numberOfPlayers.toString()),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addMultiplePlayers(isHomeTeam, numberOfPlayers);
                Navigator.of(context).pop();
              },
              child: const Text('Add Players'),
            ),
          ],
        ),
      ),
    );
  }

  void _addMultiplePlayers(bool isHomeTeam, int count) {
    final provider = isHomeTeam
        ? manualHomeTeamPlayersProvider
        : manualAwayTeamPlayersProvider;

    final currentPlayers = List<TeamPlayer>.from(ref.read(provider));
    final existingNumbers = _getExistingNumbers(isHomeTeam);

    int shirtNumber = 1;
    bool hasGoalkeeper = currentPlayers.any((p) => p.position == 'Målvakt');

    for (int i = 0; i < count; i++) {
      // Find next available shirt number
      while (existingNumbers.contains(shirtNumber)) {
        shirtNumber++;
      }

      // First player should be goalkeeper if none exists
      String position = (!hasGoalkeeper && i == 0) ? 'Målvakt' : 'Forward';
      if (!hasGoalkeeper && i == 0) hasGoalkeeper = true;

      currentPlayers.add(
        TeamPlayer(
          shirtNo: shirtNumber,
          name: 'Player $shirtNumber',
          position: position,
        ),
      );

      existingNumbers.add(shirtNumber);
      shirtNumber++;
    }

    ref.read(provider.notifier).state = currentPlayers;
  }

  void _editPlayer(BuildContext context, bool isHomeTeam, int index) {
    final players = ref.read(
      isHomeTeam
          ? manualHomeTeamPlayersProvider
          : manualAwayTeamPlayersProvider,
    );

    showDialog(
      context: context,
      builder: (context) => PlayerEntryFormDialog(
        isHomeTeam: isHomeTeam,
        existingNumbers: _getExistingNumbers(isHomeTeam),
        editingPlayer: players[index],
        editingIndex: index,
      ),
    );
  }

  void _removePlayer(bool isHomeTeam, int index) {
    final provider = isHomeTeam
        ? manualHomeTeamPlayersProvider
        : manualAwayTeamPlayersProvider;

    final currentPlayers = List<TeamPlayer>.from(ref.read(provider));
    currentPlayers.removeAt(index);
    ref.read(provider.notifier).state = currentPlayers;
  }

  void _clearTeam(bool isHomeTeam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Team'),
        content: const Text(
          'Are you sure you want to remove all players from this team?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final provider = isHomeTeam
                  ? manualHomeTeamPlayersProvider
                  : manualAwayTeamPlayersProvider;
              ref.read(provider.notifier).state = [];
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Set<int> _getExistingNumbers(bool isHomeTeam) {
    final players = ref.read(
      isHomeTeam
          ? manualHomeTeamPlayersProvider
          : manualAwayTeamPlayersProvider,
    );
    return players.map((p) => p.shirtNo ?? 0).where((n) => n > 0).toSet();
  }
}

// Contains AI-generated edits.
