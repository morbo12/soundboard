import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/api_usage.dart';
import 'package:soundboard/core/services/auth_service.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/properties.dart';

final apiUsageServiceProvider = Provider<ApiUsageService>((ref) {
  return ApiUsageService(ref);
});

final currentApiUsageProvider = StateProvider<ApiUsageData?>((ref) => null);

class ApiUsageService {
  final Ref ref;
  final Logger logger = const Logger('ApiUsageService');

  ApiUsageService(this.ref);

  String get baseUrl {
    final settings = SettingsBox();
    return settings.apiBaseUrl;
  }

  Future<ApiUsageData?> fetchUsage() async {
    try {
      final authService = ref.read(authServiceProvider);
      final token = await authService.getValidToken();

      if (token == null) {
        logger.w('No valid token available for usage check');
        return null;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/api/usage/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usageData = ApiUsageData.fromJson(data);

        // Update the provider with the latest data
        ref.read(currentApiUsageProvider.notifier).state = usageData;

        logger.d('Usage data fetched successfully');
        return usageData;
      } else {
        logger.e(
          'Failed to fetch usage: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      logger.e('Error fetching usage data', e, stackTrace);
      return null;
    }
  }

  /// Check if a specific limit is approaching (>80% usage)
  bool isApproachingLimit(ApiUsageData usage) {
    final ttsLimit = usage.limits.ttsRequestsPerMonth;
    final aiLimit = usage.limits.aiRequestsPerMonth;
    final audioLimit = usage.limits.audioMinutesPerMonth;

    final ttsPercentage = ttsLimit != null && ttsLimit > 0
        ? (usage.usage.ttsRequests / ttsLimit) * 100
        : 0.0;
    final aiPercentage = aiLimit != null && aiLimit > 0
        ? (usage.usage.aiRequests / aiLimit) * 100
        : 0.0;
    final audioPercentage = audioLimit != null && audioLimit > 0
        ? (usage.usage.audioMinutes / audioLimit) * 100
        : 0.0;

    return ttsPercentage > 80 || aiPercentage > 80 || audioPercentage > 80;
  }

  /// Check if any limit has been exceeded
  bool hasExceededLimit(ApiUsageData usage) {
    final ttsRemaining = usage.remaining.ttsRequests;
    final aiRemaining = usage.remaining.aiRequests;
    final audioRemaining = usage.remaining.audioMinutes;

    return (ttsRemaining != null && ttsRemaining <= 0) ||
        (aiRemaining != null && aiRemaining <= 0) ||
        (audioRemaining != null && audioRemaining <= 0);
  }
}
