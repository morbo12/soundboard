import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:soundboard/features/innebandy_api/application/api_client_provider.dart';
import 'package:soundboard/utils/logger.dart';
import 'dart:convert';
import 'api_constants.dart';
import 'api_config.dart';
import 'access_token_data.dart';

class APIClient {
  late Dio _dio;
  final Ref _ref;
  final Logger logger = const Logger('APIClient');

  APIClient(this._ref) {
    _dio = Dio(BaseOptions(
      baseUrl: APIConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: APIConfig.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: APIConfig.receiveTimeout),
      sendTimeout: const Duration(milliseconds: APIConfig.sendTimeout),
    ));

    _dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  Future<AccessTokenData> getAccessToken() async {
    final cachedToken = _ref.read(accessTokenProvider);

    if (cachedToken != null &&
        DateTime.now()
            .isBefore(DateTime.parse(cachedToken.accessTokenExpiration))) {
      logger.d(
          "Token is NOT expired: NOW: ${DateTime.now()} - Token: ${cachedToken.accessTokenExpiration}");
      return cachedToken;
    }

    logger.d("Token is expired or null. Fetching new token.");
    final response = await http
        .get(Uri.parse('${APIConstants.baseUrl}${APIConstants.startKit}'));

    if (response.statusCode == 200) {
      final newToken = AccessTokenData.fromJson(json.decode(response.body));
      _ref.read(accessTokenProvider.notifier).state = newToken;
      logger.d('New access token: ${newToken.accessToken}');
      return newToken;
    } else {
      throw Exception(
          'Failed to get access token : ${response.body} ${response.request}');
    }
  }

  Future<Response> authenticatedGet(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    final token = await getAccessToken();
    options ??= Options();
    options.headers ??= {};
    options.headers!['Authorization'] = 'Bearer ${token.accessToken}';
    return get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      final response = await _dio.get(path,
          queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path,
      {dynamic data,
      Map<String, dynamic>? queryParameters,
      Options? options}) async {
    try {
      final response = await _dio.post(path,
          data: data, queryParameters: queryParameters, options: options);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.badResponse:
        return BadResponseException(
            'Bad response: ${error.response?.statusCode}');
      case DioExceptionType.cancel:
        return RequestCancelledException();
      default:
        return UnknownException('An unknown error occurred');
    }
  }
}

class TimeoutException implements Exception {}

class BadResponseException implements Exception {
  final String message;
  BadResponseException(this.message);
}

class RequestCancelledException implements Exception {}

class UnknownException implements Exception {
  final String message;
  UnknownException(this.message);
}
