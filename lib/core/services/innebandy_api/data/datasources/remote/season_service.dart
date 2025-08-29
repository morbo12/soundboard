import 'package:soundboard/core/services/innebandy_api/core/config/api_constants.dart';

import 'api_client.dart';

class SeasonService {
  final APIClient _apiClient;

  SeasonService(this._apiClient);

  Future<int> getCurrentSeason() async {
    final response = await _apiClient.authenticatedGet(APIConstants.season);
    if (response.statusCode == 200) {
      var data = response.data.where((val) => val["IsCurrentSeason"] == true);
      // dev.log('access token is -> $data');
      final seasonID = data.first["SeasonID"];

      // Handle edge case: During June 20 - September 1st, return previous season ID
      final now = DateTime.now();
      final currentYear = now.year;
      final june20 = DateTime(currentYear, 6, 20);
      final september1 = DateTime(currentYear, 9, 1);

      if (now.isAfter(june20) && now.isBefore(september1)) {
        return seasonID - 1;
      }

      return seasonID;

      // var data = response.data;
      // final seasonID = data.first["SeasonID"];
      // return seasonID;
    } else {
      throw Exception("Failed to get season");
    }
  }
}
