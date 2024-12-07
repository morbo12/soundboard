import 'api_client.dart';
import 'api_constants.dart';

class SeasonService {
  final APIClient _apiClient;

  SeasonService(this._apiClient);

  Future<int> getSeason() async {
    final response = await _apiClient.authenticatedGet(APIConstants.season);
    if (response.statusCode == 200) {
      var data = response.data;
      final seasonID = data.first["SeasonID"];
      return seasonID;
    } else {
      throw Exception("Failed to get season");
    }
  }
}
