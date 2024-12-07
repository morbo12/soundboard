import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

final selectedDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.fromMillisecondsSinceEpoch(0);
});

final matchesProvider = StateProvider<List<IbyVenueMatch>>((ref) {
  return [
    IbyVenueMatch(
        matchId: 0,
        categoryName: 'Ingen match vald',
        competitionName: 'Ingen match vald',
        matchNo: '0',
        matchDateTime: '2023-11-25T10:00:00',
        homeTeam: 'N/A',
        awayTeam: 'N/A',
        awayTeamLogotypeUrl: '',
        homeTeamLogotypeUrl: '',
        seasonId: 0,
        venue: '0',
        referee1: '',
        referee2: '',
        matchStatus: 0)
  ];
});
