import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_federations.dart';
import 'package:soundboard/features/innebandy_api/data/providers.dart';
import 'package:soundboard/properties.dart';

class FederationSelector extends ConsumerStatefulWidget {
  const FederationSelector({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FederationSelectorState();
}

class _FederationSelectorState extends ConsumerState<FederationSelector> {
  @override
  Widget build(BuildContext context) {
    final federationId = ref.watch(selectedFederationProvider);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _selectFederation(context),
            child: federationId != 0
                ? AutoSizeText(
                    Federation.getNameById(federationId),
                    textAlign: TextAlign.center,
                  )
                : const AutoSizeText(
                    "Välj förbund",
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ],
    );
  }

  void _selectFederation(BuildContext context) {
    final federationList = Federation.getFacilitiesList();
    final currentFederationId = ref.read(selectedFederationProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: federationList.length,
        itemBuilder: (context, index) {
          final federation = federationList[index];
          final isSelected =
              Federation.getIdByName(federation) == currentFederationId;

          return ListTile(
            title: Text(federation),
            selected: isSelected,
            onTap: () {
              final id = Federation.getIdByName(federation);
              ref.read(selectedVenueProvider.notifier).state = id;
              SettingsBox().federationId = id;
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
