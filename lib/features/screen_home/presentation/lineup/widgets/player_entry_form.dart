import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/providers/manual_lineup_providers.dart';

class PlayerEntryFormDialog extends ConsumerStatefulWidget {
  final bool isHomeTeam;
  final Set<int> existingNumbers;
  final TeamPlayer? editingPlayer;
  final int? editingIndex;

  const PlayerEntryFormDialog({
    super.key,
    required this.isHomeTeam,
    required this.existingNumbers,
    this.editingPlayer,
    this.editingIndex,
  });

  @override
  ConsumerState<PlayerEntryFormDialog> createState() =>
      _PlayerEntryFormDialogState();
}

class _PlayerEntryFormDialogState extends ConsumerState<PlayerEntryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  String _selectedPosition = 'Forward';
  bool _isCaptain = false;

  final List<String> _positions = [
    'Målvakt',
    'Vänsterback',
    'Högerback',
    'Back',
    'Vänsterforward',
    'Högerforward',
    'Forward',
    'Center',
  ];

  @override
  void initState() {
    super.initState();

    if (widget.editingPlayer != null) {
      _nameController.text = widget.editingPlayer!.name ?? '';
      _numberController.text = widget.editingPlayer!.shirtNo?.toString() ?? '';
      _selectedPosition = widget.editingPlayer!.position ?? 'Forward';
      _isCaptain = widget.editingPlayer!.captain ?? false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.editingPlayer != null ? 'Edit Player' : 'Add Player'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Player Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Player Name *',
                  hintText: 'Enter player name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Player name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Shirt Number
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Shirt Number *',
                  hintText: 'Enter shirt number (1-99)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Shirt number is required';
                  }

                  final number = int.tryParse(value.trim());
                  if (number == null) {
                    return 'Please enter a valid number';
                  }

                  if (number < 1 || number > 99) {
                    return 'Shirt number must be between 1 and 99';
                  }

                  // Check for duplicate numbers (excluding current player if editing)
                  final existingNumbers = Set<int>.from(widget.existingNumbers);
                  if (widget.editingPlayer != null &&
                      widget.editingPlayer!.shirtNo != null) {
                    existingNumbers.remove(widget.editingPlayer!.shirtNo!);
                  }

                  if (existingNumbers.contains(number)) {
                    return 'Shirt number $number is already taken';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Position
              DropdownButtonFormField<String>(
                initialValue: _selectedPosition,
                decoration: const InputDecoration(
                  labelText: 'Position',
                  border: OutlineInputBorder(),
                ),
                items: _positions.map((position) {
                  return DropdownMenuItem<String>(
                    value: position,
                    child: Text(position),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPosition = value ?? 'Forward';
                  });
                },
              ),
              const SizedBox(height: 16),

              // Captain checkbox
              CheckboxListTile(
                title: const Text('Captain'),
                subtitle: const Text('Mark this player as team captain'),
                value: _isCaptain,
                onChanged: (value) {
                  setState(() {
                    _isCaptain = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _savePlayer,
          child: Text(widget.editingPlayer != null ? 'Update' : 'Add'),
        ),
      ],
    );
  }

  void _savePlayer() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final player = TeamPlayer(
      shirtNo: int.parse(_numberController.text.trim()),
      name: _nameController.text.trim(),
      position: _selectedPosition,
      captain: _isCaptain,
      // Set other optional fields
      playerId: 0, // Manual entries don't have API IDs
      personId: 0,
      teamId: 0,
      age: null,
      positionId: null,
    );

    final provider = widget.isHomeTeam
        ? manualHomeTeamPlayersProvider
        : manualAwayTeamPlayersProvider;

    if (widget.editingPlayer != null && widget.editingIndex != null) {
      // Update existing player
      final currentPlayers = List<TeamPlayer>.from(ref.read(provider));
      currentPlayers[widget.editingIndex!] = player;
      ref.read(provider.notifier).state = currentPlayers;
    } else {
      // Add new player
      final currentPlayers = List<TeamPlayer>.from(ref.read(provider));
      currentPlayers.add(player);
      // Sort by shirt number
      currentPlayers.sort((a, b) => (a.shirtNo ?? 0).compareTo(b.shirtNo ?? 0));
      ref.read(provider.notifier).state = currentPlayers;
    }

    Navigator.of(context).pop();
  }
}
