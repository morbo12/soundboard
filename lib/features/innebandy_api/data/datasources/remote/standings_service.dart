import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundboard/features/innebandy_api/core/config/api_constants.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/standings.dart';
import 'package:soundboard/features/innebandy_api/presentation/providers/standings_provider.dart';
import 'api_client.dart';

class StandingsService {
  final APIClient _apiClient;

  StandingsService(this._apiClient);

  Future<Standings> getCurrentStandings(IbyMatch match, WidgetRef ref) async {
    final path = APIConstants.standings.replaceAll(
      '{competitionId}',
      match.competitionId.toString(),
    );

    final response = await _apiClient.authenticatedGet(path);
    if (response.statusCode == 200) {
      final standings = Standings.fromJson(response.data);
      // Update the standings provider
      ref.read(standingsProvider.notifier).state = standings;
      return standings;
    } else {
      throw Exception("Failed to get standings");
    }
  }
}
