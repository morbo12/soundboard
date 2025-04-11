import 'dart:core';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/features/innebandy_api/application/api_client_provider.dart';
import 'package:soundboard/features/innebandy_api/application/match_service.dart';
import 'package:soundboard/features/innebandy_api/application/season_service.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/innebandy_api/data/providers.dart';
import 'package:soundboard/features/screen_match/presentation/providers.dart';
import 'package:soundboard/features/screen_match/presentation/selector_federationselector.dart';
import 'package:soundboard/features/screen_match/presentation/selector_date.dart';
import 'package:soundboard/features/screen_match/presentation/selector_match.dart';
import 'package:soundboard/features/screen_match/presentation/selector_venue.dart';
import 'package:soundboard/utils/logger.dart';

class MatchSetupScreen extends ConsumerStatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  MatchSetupScreenState createState() => MatchSetupScreenState();
}

class MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  List<IbyMatch> matches = [];

  final Logger logger = const Logger('MatchSetupScreen');

  void _getMatches() async {
    final selectedVenue = ref.watch(selectedVenueProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    logger.d("_getMatches");

    // final apiClient = APIClient(ref);
    final apiClient = ref.watch(apiClientProvider);
    final seasonService = SeasonService(apiClient);
    final matchService = MatchService(apiClient);

    final seasonId = await seasonService.getCurrentSeason();
    logger.d("SeasonID: $seasonId");
    logger.d(
      "date: ${DateFormat('yyyy-MM-dd').format(selectedDate)} | seasonId: $seasonId | venueId: $selectedVenue",
    );

    ref.read(matchesProvider.notifier).state = await matchService
        .getMatchesInVenue(
          date: DateFormat('yyyy-MM-dd').format(selectedDate),
          seasonId: seasonId,
          venueId: selectedVenue,
        );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // logger.d("matches.length is : ${matches.length}");

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: ScreenSizeUtil.getWidth(context, maxWidth: 700),
            height: ScreenSizeUtil.getHeight(context),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  const AutoSizeText("Välj Förbund"),
                  const Gap(10),
                  const FederationSelector(),
                  const AutoSizeText("Välj Anläggning"),
                  const Gap(10),
                  const VenueSelector(),
                  const Gap(10),
                  const AutoSizeText("Välj Datum"),
                  const Gap(10),
                  DateSelector(callback: _getMatches),
                  const Gap(10),
                  // const CreateContentPlayerWidget(),
                  const AutoSizeText("Välj Match (scrolla listan nedan)"),
                  const Gap(10),
                  // MatchButton2(readonly: false, match: selectedMatch),
                  const Expanded(flex: 2, child: MatchSelector()),
                  const Gap(10),
                  // Row(children: [Expanded(child: createLineup)]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
