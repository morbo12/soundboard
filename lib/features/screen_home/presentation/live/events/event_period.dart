import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_event.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/ssml/class_ssml_event_card.dart';
import 'package:soundboard/utils/logger.dart';

class PeriodEvent extends ConsumerWidget {
  const PeriodEvent({super.key, required this.data});
  final IbyMatchEvent data;
  final Logger logger = const Logger('PeriodEvent');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: data.matchEventTypeId == 8
                  ? null
                  : () {
                      EventCardSsml(ref: ref, data: data).getEventText(context);
                      logger.d("End period Button pressed");
                    },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) => Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
              child: AutoSizeText(
                "${data.matchEventTypeId == 8 ? "Start" : "Slut"} period ${data.period}",
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ]);
  }
}
