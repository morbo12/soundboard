import 'dart:io';
import 'package:flutter/foundation.dart';

/// Model representing a file in a custom category
@immutable
class CustomCategoryFile {
  final String fileName;
  final String filePath;
  final String customCategoryId;
  final int fileSizeBytes;
  final DateTime lastModified;

  const CustomCategoryFile({
    required this.fileName,
    required this.filePath,
    required this.customCategoryId,
    required this.fileSizeBytes,
    required this.lastModified,
  });

  /// Create from a File object
  factory CustomCategoryFile.fromFile(File file, String customCategoryId) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final stats = file.statSync();

    return CustomCategoryFile(
      fileName: fileName,
      filePath: file.path,
      customCategoryId: customCategoryId,
      fileSizeBytes: stats.size,
      lastModified: stats.modified,
    );
  }

  /// Get the file extension
  String get extension {
    return fileName.split('.').last.toLowerCase();
  }

  /// Get formatted file size
  String get formattedSize {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  /// Get the file name without extension
  String get nameWithoutExtension {
    final parts = fileName.split('.');
    if (parts.length > 1) {
      return parts.sublist(0, parts.length - 1).join('.');
    }
    return fileName;
  }

  /// Convert to JSON for persistence if needed
  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'filePath': filePath,
      'customCategoryId': customCategoryId,
      'fileSizeBytes': fileSizeBytes,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  /// Create from JSON
  factory CustomCategoryFile.fromJson(Map<String, dynamic> json) {
    return CustomCategoryFile(
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      customCategoryId: json['customCategoryId'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomCategoryFile &&
        other.fileName == fileName &&
        other.customCategoryId == customCategoryId;
  }

  @override
  int get hashCode => Object.hash(fileName, customCategoryId);

  @override
  String toString() {
    return 'CustomCategoryFile(fileName: $fileName, customCategoryId: $customCategoryId, size: $formattedSize)';
  }

  /// Copy with new values
  CustomCategoryFile copyWith({
    String? fileName,
    String? filePath,
    String? customCategoryId,
    int? fileSizeBytes,
    DateTime? lastModified,
  }) {
    return CustomCategoryFile(
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      customCategoryId: customCategoryId ?? this.customCategoryId,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}
