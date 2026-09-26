import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:soundboard/core/services/innebandy_api/core/config/access_token_data.dart';
import 'package:soundboard/core/services/innebandy_api/core/config/api_config.dart';
import 'package:soundboard/core/services/innebandy_api/core/config/api_constants.dart';
import 'package:soundboard/core/services/innebandy_api/data/datasources/remote/api_client_provider.dart';
import 'package:soundboard/core/utils/logger.dart';

class APIClient {
  late Dio _dio;
  final Ref _ref;
  final Logger logger = const Logger('APIClient');

  APIClient(this._ref) {
    _dio = Dio(
      BaseOptions(
        baseUrl: APIConstants.baseUrl,
        connectTimeout: const Duration(
          milliseconds: APIConfig.connectionTimeout,
        ),
        receiveTimeout: const Duration(milliseconds: APIConfig.receiveTimeout),
        sendTimeout: const Duration(milliseconds: APIConfig.sendTimeout),
        headers: {
          'accept': 'application/json, text/plain, */*',
          'accept-encoding': 'gzip, deflate, br, zstd',
          'accept-language':
              'sv,en;q=0.9,en-GB;q=0.8,en-US;q=0.7,da;q=0.6,de;q=0.5,no;q=0.4',
          'dnt': '1',
          'origin': 'https://stats.innebandy.se',
          'referer': 'https://stats.innebandy.se/',
          'sec-ch-ua':
              '"Microsoft Edge";v="143", "Chromium";v="143", "Not A(Brand)";v="24"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': '"Windows"',
          'sec-fetch-dest': 'empty',
          'sec-fetch-mode': 'cors',
          'sec-fetch-site': 'same-site',
          'user-agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0',
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(responseBody: true, logPrint: _redactedLogPrint),
    );
  }

  static final RegExp _bearerTokenPattern = RegExp(
    r'Bearer\s+\S+',
    caseSensitive: false,
  );

  static void _redactedLogPrint(Object? object) {
    var text = object.toString();
    if (text.contains('Bearer')) {
      text = text.replaceAll(_bearerTokenPattern, 'Bearer <redacted>');
    }
    debugPrint(text);
  }

  DateTime? _tokenFetchBlockedUntil;
  static const Duration _tokenFetchCooldown = Duration(seconds: 30);

  Future<AccessTokenData> getAccessToken() async {
    final cachedToken = _ref.read(accessTokenProvider);
    final cachedExpiration = cachedToken == null
        ? null
        : DateTime.tryParse(cachedToken.accessTokenExpiration);

    if (cachedToken != null &&
        cachedExpiration != null &&
        DateTime.now().isBefore(cachedExpiration)) {
      logger.d(
        "Token is NOT expired: NOW: ${DateTime.now()} - Token: ${cachedToken.accessTokenExpiration}",
      );
      return cachedToken;
    }

    if (_tokenFetchBlockedUntil != null &&
        DateTime.now().isBefore(_tokenFetchBlockedUntil!)) {
      throw Exception('Access token fetch in cooldown');
    }

    logger.d("Token is expired or null. Fetching new token.");
    final http.Response response;
    try {
      response = await http.get(
        Uri.parse('${APIConstants.baseUrl}${APIConstants.startKit}'),
        headers: {
          'accept': 'application/json, text/plain, */*',
          'accept-encoding': 'gzip, deflate, br, zstd',
          'accept-language':
              'sv,en;q=0.9,en-GB;q=0.8,en-US;q=0.7,da;q=0.6,de;q=0.5,no;q=0.4',
          'dnt': '1',
          'origin': 'https://stats.innebandy.se',
          'referer': 'https://stats.innebandy.se/',
          'sec-ch-ua':
              '"Microsoft Edge";v="143", "Chromium";v="143", "Not A(Brand)";v="24"',
          'sec-ch-ua-mobile': '?0',
          'sec-ch-ua-platform': '"Windows"',
          'sec-fetch-dest': 'empty',
          'sec-fetch-mode': 'cors',
          'sec-fetch-site': 'same-site',
          'user-agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36 Edg/143.0.0.0',
        },
      );
    } catch (_) {
      _tokenFetchBlockedUntil = DateTime.now().add(_tokenFetchCooldown);
      rethrow;
    }

    if (response.statusCode == 200) {
      final newToken = AccessTokenData.fromJson(json.decode(response.body));
      _ref.read(accessTokenProvider.notifier).state = newToken;
      logger.d(
        'New access token acquired. Expires: ${newToken.accessTokenExpiration}',
      );
      return newToken;
    } else {
      _tokenFetchBlockedUntil = DateTime.now().add(_tokenFetchCooldown);
      throw Exception(
        'Failed to get access token (HTTP ${response.statusCode})',
      );
    }
  }

  Future<Response> authenticatedGet(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool attachAuthToken = false,
  }) async {
    if (!attachAuthToken) {
      return get(path, queryParameters: queryParameters, options: options);
    }
    final token = await getAccessToken();
    var response = await _getWithBearer(
      path,
      queryParameters: queryParameters,
      options: options,
      token: token,
    );
    if (response.statusCode == 401) {
      final inCooldown =
          _tokenFetchBlockedUntil != null &&
          DateTime.now().isBefore(_tokenFetchBlockedUntil!);
      if (!inCooldown) {
        _ref.read(accessTokenProvider.notifier).state = null;
        final fresh = await getAccessToken();
        response = await _getWithBearer(
          path,
          queryParameters: queryParameters,
          options: options,
          token: fresh,
        );
      }
    }
    if (response.statusCode == 401) {
      throw Exception('IBIS authentication failed (HTTP 401)');
    }
    return response;
  }

  Future<Response> _getWithBearer(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    required AccessTokenData token,
  }) {
    return get(
      path,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(
        headers: {
          ...?options?.headers,
          'Authorization': 'Bearer ${token.accessToken}',
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
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
          'Bad response: ${error.response?.statusCode}',
        );
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
