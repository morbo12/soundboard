import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';

class DateSelector extends ConsumerWidget {
  final VoidCallback callback;

  const DateSelector({super.key, required this.callback});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(matchSetupStateProvider).selectedDate;

    return ElevatedButton(
      onPressed: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != selectedDate) {
          ref.read(matchSetupStateProvider.notifier).updateDate(picked);
          callback();
        }
      },
      child: Text(
        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
      ),
    );
  }
}
