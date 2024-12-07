import 'dart:core';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:dart_date/dart_date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/features/innebandy_api/application/api_client.dart';
import 'package:soundboard/features/innebandy_api/application/match_service.dart';
import 'package:soundboard/features/innebandy_api/application/season_service.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:soundboard/features/innebandy_api/data/providers.dart';
import 'package:soundboard/features/screen_match/presentation/providers.dart';
import 'package:soundboard/features/screen_match/presentation/selector_federationselector.dart';
import 'package:soundboard/features/screen_match/presentation/selector_date.dart';
import 'package:soundboard/features/screen_match/presentation/selector_match.dart';
import 'package:soundboard/features/screen_match/presentation/selector_venue.dart';

class MatchSetupScreen extends ConsumerStatefulWidget {
  const MatchSetupScreen({super.key});

  @override
  MatchSetupScreenState createState() => MatchSetupScreenState();
}

class MatchSetupScreenState extends ConsumerState<MatchSetupScreen> {
  // List<IbyVenueMatch> matches = [selectedMatch];
  List<IbyVenueMatch> matches = [];

  // IbyMatchLineup lineup = [];
  // final double fontSize = 16;

  void _getMatches() async {
    final selectedVenue = ref.watch(selectedVenueProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    if (kDebugMode) {
      print("_getMatches");
    }
    final apiClient = APIClient();
    final seasonService = SeasonService(apiClient);
    final matchService = MatchService(apiClient);

    // final accessToken = await apiService.getAccessToken();
    // if (kDebugMode) {
    // print("MatchSetupScreenStateSeason: $accessToken");
    // }
    final seasonId = await seasonService.getSeason();
    if (kDebugMode) {
      print("MatchSetupScreenStateSeason: $seasonId");
    }
    if (kDebugMode) {
      print(
          "date: ${DateFormat('yyyy-MM-dd').format(selectedDate.toLocalTime)} | seasonId: $seasonId | venueId: $selectedVenue");
    }

    ref.read(matchesProvider.notifier).state =
        await matchService.getMatchesInVenue(
            date: DateFormat('yyyy-MM-dd').format(selectedDate.toLocalTime),
            seasonId: seasonId,
            venueId: selectedVenue);
    // print("Length is : ${matches.length}");
    // print(matches);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print("Length wod is : ${matches.length}");
    }

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
                  const AutoSizeText(
                    "Välj Förbund",
                  ),
                  const Gap(10),
                  const FederationSelector(),
                  const AutoSizeText(
                    "Välj Anläggning",
                  ),
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
                  const Expanded(
                    flex: 2,
                    child: MatchSelector(),
                  ),
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