import 'package:flutter/foundation.dart';

@immutable
class ApiUsageData {
  final bool success;
  final String message;
  final String month;
  final DateTime resetsAt;
  final UsageStats usage;
  final UsageLimits limits;
  final UsageRemaining remaining;

  const ApiUsageData({
    required this.success,
    required this.message,
    required this.month,
    required this.resetsAt,
    required this.usage,
    required this.limits,
    required this.remaining,
  });

  factory ApiUsageData.fromJson(Map<String, dynamic> json) {
    return ApiUsageData(
      success: json['success'] as bool,
      message: json['message'] as String,
      month: json['month'] as String,
      resetsAt: DateTime.parse(json['resetsAt'] as String),
      usage: UsageStats.fromJson(json['usage'] as Map<String, dynamic>),
      limits: UsageLimits.fromJson(json['limits'] as Map<String, dynamic>),
      remaining: UsageRemaining.fromJson(
        json['remaining'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'month': month,
      'resetsAt': resetsAt.toIso8601String(),
      'usage': usage.toJson(),
      'limits': limits.toJson(),
      'remaining': remaining.toJson(),
    };
  }
}

@immutable
class UsageStats {
  final int ttsRequests;
  final int aiRequests;
  final double audioMinutes;
  final int aiTokens;

  const UsageStats({
    required this.ttsRequests,
    required this.aiRequests,
    required this.audioMinutes,
    required this.aiTokens,
  });

  factory UsageStats.fromJson(Map<String, dynamic> json) {
    return UsageStats(
      ttsRequests: json['ttsRequests'] as int,
      aiRequests: json['aiRequests'] as int,
      audioMinutes: (json['audioMinutes'] as num).toDouble(),
      aiTokens: json['aiTokens'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ttsRequests': ttsRequests,
      'aiRequests': aiRequests,
      'audioMinutes': audioMinutes,
      'aiTokens': aiTokens,
    };
  }
}

@immutable
class UsageLimits {
  final int ttsRequestsPerMonth;
  final int aiRequestsPerMonth;
  final int audioMinutesPerMonth;

  const UsageLimits({
    required this.ttsRequestsPerMonth,
    required this.aiRequestsPerMonth,
    required this.audioMinutesPerMonth,
  });

  factory UsageLimits.fromJson(Map<String, dynamic> json) {
    return UsageLimits(
      ttsRequestsPerMonth: json['ttsRequestsPerMonth'] as int,
      aiRequestsPerMonth: json['aiRequestsPerMonth'] as int,
      audioMinutesPerMonth: json['audioMinutesPerMonth'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ttsRequestsPerMonth': ttsRequestsPerMonth,
      'aiRequestsPerMonth': aiRequestsPerMonth,
      'audioMinutesPerMonth': audioMinutesPerMonth,
    };
  }
}

@immutable
class UsageRemaining {
  final int ttsRequests;
  final int aiRequests;
  final double audioMinutes;

  const UsageRemaining({
    required this.ttsRequests,
    required this.aiRequests,
    required this.audioMinutes,
  });

  factory UsageRemaining.fromJson(Map<String, dynamic> json) {
    return UsageRemaining(
      ttsRequests: json['ttsRequests'] as int,
      aiRequests: json['aiRequests'] as int,
      audioMinutes: (json['audioMinutes'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ttsRequests': ttsRequests,
      'aiRequests': aiRequests,
      'audioMinutes': audioMinutes,
    };
  }
}
