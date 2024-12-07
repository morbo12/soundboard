import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/features/innebandy_api/application/api_client.dart';
import 'package:soundboard/features/innebandy_api/application/match_service.dart';
import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

import '../live/widget_event.dart';

Timer? _timer;

class LiveEvents extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  const LiveEvents({super.key, required this.scrollController});
  @override
  ConsumerState<LiveEvents> createState() => _LiveEventsState();
}

class _LiveEventsState extends ConsumerState<LiveEvents> {
  bool streamerRunning = false;
  StreamController<List<MatchEvent>> streamController =
      StreamController<List<MatchEvent>>();
  late Stream<List<MatchEvent>>? userStream;
  late IbyVenueMatch updatedMatch;
  late List<MatchEvent> matchEventList;
  late int liveindex;

  @override
  void dispose() {
    streamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // streamController.add(user);
    userStream = streamController.stream;
    // print("SCROLLCONTROLLER: ${scrollController.position.pixels}");
  }

  @override
  Widget build(BuildContext context) {
    final selectedMatch = ref.watch(selectedMatchProvider);

    return SizedBox(
      width: 300,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
        child: Column(
          children: [
            // Header for Matchhändelser
            Container(
              // Top row with rounded corners
              // width: maxWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextButton(
                          onLongPress: () {
                            if (kDebugMode) {
                              print("Timer cancelled");
                            }
                            setState(() {
                              if (_timer != null) {
                                _timer?.cancel();
                                streamerRunning = false;
                              }
                            });
                          },
                          onPressed: () {
                            if (kDebugMode) {
                              print("Starting streamer");
                            }
                            streamerRunning
                                ? null
                                : startMatchStreaming(
                                    matchId: selectedMatch.matchId);
                            streamerRunning = true;
                          },
                          child: Text(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer),
                            "Matchhändelser",
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
            // Line under header
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceTint),
              ),
            ),
            // Box for ListTiles

            SizedBox(
              height: MediaQuery.of(context).size.height > 600
                  ? MediaQuery.of(context).size.height -
                      150 -
                      DefaultConstants().appBarHeight
                  : 500,
              child: StreamBuilder(
                  stream: userStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<MatchEvent>? data = snapshot.data;
                      return ListView.separated(
                        controller: widget.scrollController,
                        // reverse: true,
                        shrinkWrap: true,
                        itemCount: data!.length,
                        itemBuilder: (context, index) {
                          selectedMatch.matchStatus != 4
                              ? liveindex =
                                  index // Events are added on top during live
                              : liveindex = data.length -
                                  1 -
                                  index; // Reverse index if match has ended
                          return EventWidget(data: data[liveindex]);
                        },
                        separatorBuilder: (BuildContext context, int index) =>
                            const Divider(
                          thickness: 1,
                          height: 5,
                        ),
                      );
                    } else {
                      return const Text("No Data");
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> startMatchStreaming({required int matchId}) async {
    // if (matchId != 4) {
    // Start streaming or initiate periodic refresh here
    // Example: create a Timer that calls getMatch every X seconds
    const refreshInterval = Duration(seconds: 3); // Adjust as needed

    // Lets try to just pull once before we start the timer
    try {
      // Call the getMatch API and update the UI
      // final accessToken = await APIService().getAccessToken();
      final apiClient = APIClient();
      final matchService = MatchService(apiClient);
      updatedMatch = await matchService.getMatch(matchId: matchId);

      matchEventList = updatedMatch.events!;
      streamController.add(matchEventList);
    } catch (e) {
      // Handle errors, e.g., log or show a message
      if (kDebugMode) {
        print('Error during streaming: $e');
      }
    }

    // Starting periodic timer
    if (kDebugMode) {
      print("starting timer");
    }
    _timer = Timer.periodic(refreshInterval, (Timer timer) async {
      try {
        // Call the getMatch API and update the UI
        final apiClient = APIClient();
        final matchService = MatchService(apiClient);
        updatedMatch = await matchService.getMatch(matchId: matchId);

        matchEventList = updatedMatch.events!;
        // Update the UI with the new match data
        // Assuming you have a function to update the UI, replace with actual code
        // updateUI(updatedMatch);
        streamController.add(matchEventList);

        // Check if the match status changed, and stop the timer if needed
        if (updatedMatch.matchStatus == 4) {
          if (kDebugMode) {
            print(
                "Timer cancelled direct as we are not Live - ${updatedMatch.matchStatus}");
          }
          timer.cancel();
          streamerRunning = false;
        }
      } catch (e) {
        // Handle errors, e.g., log or show a message
        if (kDebugMode) {
          print('Error during streaming: $e');
        }
      }
    });
  }
  // }
}