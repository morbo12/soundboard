import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
import 'package:soundboard/features/screen_home/presentation/ssml/class_pre_ssml.dart';

class PeriodEvent extends ConsumerWidget {
  const PeriodEvent({super.key, required this.data});
  final MatchEvent data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: data.matchEventTypeID == 8
                  ? null
                  : () {
                      PreSsml(ref: ref, data: data).getEventText(context);
                      if (kDebugMode) {
                        print("End period Button pressed");
                      }
                    },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              child: AutoSizeText(
                "${data.matchEventTypeID == 8 ? "Start" : "Slut"} period ${data.period}",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ]);
  }
}
