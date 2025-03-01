import 'package:auto_size_text/auto_size_text.dart';
import 'package:dart_date/dart_date.dart';
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
  // final DatePickerController _datePickerController = DatePickerController();

  // final List<IbyMatch> _matches = matches;
  @override
  Widget build(BuildContext context) {
    // DateTime startDate = widget.now.subtract(const Duration(days: 7));
    // DateTime endDate = widget.now.add(const Duration(days: 14));
    final selectedDate = ref.watch(selectedDateProvider);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () =>
                _selectDate(context, ref, selectedDate, widget.callback),
            child: selectedDate
                        .compareTo(DateTime.fromMillisecondsSinceEpoch(0)) !=
                    0
                ? AutoSizeText(
                    DateFormat('yyyy-MM-dd').format(selectedDate.toLocalTime),
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
    // return EasyDateTimeLine(
    //   initialDate: DateTime.now(),
    //   // widgetWidth: 100,
    //   locale: 'sv_SE',
    //   headerProps: EasyHeaderProps(
    //       selectedDateStyle:
    //           TextStyle(color: Theme.of(context).colorScheme.onBackground),
    //       monthStyle:
    //           TextStyle(color: Theme.of(context).colorScheme.onBackground)),
    //   dayProps: EasyDayProps(
    //     height: 80,
    //     todayHighlightStyle: TodayHighlightStyle.withBackground,
    //     todayHighlightColor: Theme.of(context).colorScheme.secondaryContainer,
    //     inactiveDayStyle: const DayStyle(
    //       dayNumStyle: TextStyle(
    //         fontSize: 18.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     activeDayStyle: const DayStyle(
    //       dayNumStyle: TextStyle(
    //         fontSize: 18.0,
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     dayStructure: DayStructure.dayStrDayNum,
    //   ),
    //   // startDate: startDate,
    //   // selectedDate: widget.now,
    //   // datePickerController: _datePickerController,
    //   // endDate: endDate,
    //   // monthFontSize: 18,
    //   // dayFontSize: 22,
    //   // weekDayFontSize: 18,
    //   // normalTextColor: Theme.of(context).colorScheme.onPrimary,
    //   // normalColor: Theme.of(context).colorScheme.primary,
    //   // selectedColor: Theme.of(context).colorScheme.secondaryContainer,
    //   // selectedTextColor: Theme.of(context).colorScheme.onSecondaryContainer,
    //   // disabledColor: Theme.of(context).disabledColor,
    //   // disabledTextColor: Theme.of(context).disabledColor,
    //   onDateChange: (date) {
    //     setState(
    //       () {
    //         selectedDate = date.toString();
    //         widget.callback();
    //       },
    //     );
    //   },
    // );
  }

  Future<void> _selectDate(BuildContext context, WidgetRef ref,
      DateTime selectedDate, Function callback) async {
    final initialDate =
        selectedDate.compareTo(DateTime.fromMillisecondsSinceEpoch(0)) != 0
            ? selectedDate
            : DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1990, 1, 1),
      lastDate: DateTime(2050, 12, 31),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      ref.read(selectedDateProvider.notifier).state = pickedDate;
      callback();
    }
  }
}
