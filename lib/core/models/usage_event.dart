import 'package:flutter/foundation.dart';

@immutable
class UsageEvent {
  final String eventType;
  final String feature;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;
  final String deviceId;

  const UsageEvent({
    required this.eventType,
    required this.feature,
    required this.metadata,
    required this.timestamp,
    required this.deviceId,
  });

  factory UsageEvent.fromJson(Map<String, dynamic> json) {
    return UsageEvent(
      eventType: json['eventType'] as String,
      feature: json['feature'] as String,
      metadata: json['metadata'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deviceId: json['deviceId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eventType': eventType,
      'feature': feature,
      'metadata': metadata,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'deviceId': deviceId,
    };
  }
}

@immutable
class UsageEventsBatch {
  final List<UsageEvent> events;
  final DateTime createdAt;

  const UsageEventsBatch({required this.events, required this.createdAt});

  factory UsageEventsBatch.fromJson(Map<String, dynamic> json) {
    return UsageEventsBatch(
      events: (json['events'] as List<dynamic>)
          .map((e) => UsageEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events': events.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toUtc().toIso8601String(),
    };
  }
}
