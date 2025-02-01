import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/application/api_client.dart';
import 'access_token_data.dart';

final accessTokenProvider = StateProvider<AccessTokenData?>((ref) => null);

final apiClientProvider = Provider((ref) => APIClient(ref));
