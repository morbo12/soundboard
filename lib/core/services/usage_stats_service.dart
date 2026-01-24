import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/usage_event.dart';
import 'package:soundboard/core/services/auth_service.dart';
import 'package:soundboard/core/utils/device_id_manager.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/properties.dart';

final usageStatsServiceProvider = Provider<UsageStatsService>((ref) {
  return UsageStatsService(ref);
});

class UsageStatsService {
  static const int maxBufferSize = 50;
  static final Duration flushInterval = kDebugMode
      ? const Duration(seconds: 10)
      : const Duration(minutes: 1);
  static const Duration eventRetentionDays = Duration(days: 14);

  final Ref ref;
  final Logger logger = const Logger('UsageStatsService');

  late Timer _flushTimer;
  List<UsageEvent> _buffer = [];

  UsageStatsService(this.ref) {
    _initializeFlushTimer();
  }

  String get baseUrl {
    final settings = SettingsBox();
    return settings.apiBaseUrl;
  }

  void _initializeFlushTimer() {
    logger.d(
      'Starting UsageStats flush timer: every ${flushInterval.inSeconds}s',
    );
    _flushTimer = Timer.periodic(flushInterval, (_) {
      _flushEvents();
    });
  }

  /// Record a usage event
  void recordEvent({
    required String eventType,
    required String feature,
    Map<String, dynamic>? metadata,
  }) {
    final settings = SettingsBox();

    // Respect opt-out setting
    if (!settings.usageStatsEnabled) {
      return;
    }

    final event = UsageEvent(
      eventType: eventType,
      feature: feature,
      metadata: metadata ?? {},
      timestamp: DateTime.now().toUtc(),
      deviceId: DeviceIdManager.getDeviceId(),
    );

    _buffer.add(event);
    logger.d('Event recorded: $eventType - $feature');

    // Flush if buffer is full
    if (_buffer.length >= maxBufferSize) {
      _flushEvents();
    }
  }

  /// Flush buffered events to backend
  Future<bool> _flushEvents() async {
    if (_buffer.isEmpty) {
      return true;
    }

    // Filter out old events (>14 days)
    _buffer = _buffer.where((event) {
      final age = DateTime.now().toUtc().difference(event.timestamp);
      if (age > eventRetentionDays) {
        logger.d('Discarding event older than 14 days: ${event.eventType}');
        return false;
      }
      return true;
    }).toList();

    if (_buffer.isEmpty) {
      return true;
    }

    try {
      final authService = ref.read(authServiceProvider);
      final token = await authService.getValidToken();

      if (token == null) {
        logger.w('No valid token for usage stats submission');
        return false;
      }

      final batch = UsageEventsBatch(
        events: List.from(_buffer),
        createdAt: DateTime.now().toUtc(),
      );

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/usage/events'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(batch.toJson()),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => http.Response('Timeout', 408),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.d(
          'Usage events submitted successfully (${_buffer.length} events)',
        );
        _buffer.clear();
        return true;
      } else {
        logger.w('Failed to submit usage events: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      logger.w('Error submitting usage events', e, stackTrace);
      return false;
    }
  }

  /// Manually trigger flush
  Future<bool> flush() async {
    return await _flushEvents();
  }

  /// Get current buffer size
  int getBufferSize() => _buffer.length;

  /// For diagnostics only
  Duration get flushEvery => flushInterval;

  /// Cleanup resources
  void dispose() {
    _flushTimer.cancel();
  }
}
