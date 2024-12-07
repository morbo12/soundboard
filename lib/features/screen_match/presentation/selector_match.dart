import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/common_widgets/widget_match.dart';
import 'package:soundboard/features/screen_match/presentation/providers.dart';
// import 'package:soundboard/widget/styles.dart';

class MatchSelector extends ConsumerStatefulWidget {
  // final List<IbyVenueMatch> matches;
  const MatchSelector({super.key});

  @override
  ConsumerState<MatchSelector> createState() => _MatchSelectorState();
}

class _MatchSelectorState extends ConsumerState<MatchSelector> {
  // final List<IbyVenueMatch> _matches = matches;
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    final matches = ref.watch(matchesProvider);
    if (kDebugMode) {
      print("Length of matches is : ${matches.length}");
    }

    // TextStyle styleBoldContainer = TextStyle(
    //     fontSize: fontSize,
    //     fontWeight: FontWeight.bold,
    //     color: Theme.of(context).colorScheme.onTertiaryContainer);
    // TextStyle styleNormal = TextStyle(
    //     fontSize: fontSize,
    //     fontWeight: FontWeight.normal,
    //     color: Theme.of(context).colorScheme.onTertiary);
    // TextStyle styleTitle = TextStyle(
    //     fontSize: fontSize,
    //     fontWeight: FontWeight.bold,
    //     color: Theme.of(context).colorScheme.onTertiary);

    return Row(
      children: [
        Expanded(
          child: ListView.separated(
            // controller: controller,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: matches.length,
            // padding: const EdgeInsets.only(left: 20),
            itemBuilder: (BuildContext context, int index) {
              return Row(mainAxisSize: MainAxisSize.max, children: [
                Expanded(
                    child:
                        MatchButton2(readonly: false, match: matches[index])),
              ]);
            },
            separatorBuilder: (BuildContext context, int index) => Divider(
              thickness: 1,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }
}
