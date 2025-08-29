import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/core/config/access_token_data.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/api_client.dart';

final accessTokenProvider = StateProvider<AccessTokenData?>((ref) => null);

final apiClientProvider = Provider((ref) => APIClient(ref));
