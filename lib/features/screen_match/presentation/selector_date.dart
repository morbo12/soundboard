import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/features/screen_match/presentation/providers.dart';

// String selectedDate = "";

class DateSelector extends ConsumerStatefulWidget {
  final now = DateTime.now();
  final Function callback;
  DateSelector({super.key, required this.callback});

  @override
  ConsumerState<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends ConsumerState<DateSelector> {
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed:
                () => _selectDate(context, ref, selectedDate, widget.callback),
            child:
                selectedDate.compareTo(
                          DateTime.fromMillisecondsSinceEpoch(0),
                        ) !=
                        0
                    ? AutoSizeText(
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                      textAlign: TextAlign.center,
                    )
                    : const AutoSizeText(
                      "Välj Datum",
                      textAlign: TextAlign.center,
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
    Function callback,
  ) async {
    final initialDate =
        selectedDate.compareTo(DateTime.fromMillisecondsSinceEpoch(0)) != 0
            ? selectedDate
            : DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990, 1, 1),
      lastDate: DateTime(2050, 12, 31),
      locale: const Locale('sv', 'SE'),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      ref.read(selectedDateProvider.notifier).state = pickedDate;
      callback();
    }
  }
}
