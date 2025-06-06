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
      return seasonID;

      // var data = response.data;
      // final seasonID = data.first["SeasonID"];
      // return seasonID;
    } else {
      throw Exception("Failed to get season");
    }
  }
}
