// test/utils/logger_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/utils/logger.dart';

void main() {
  group('Logger', () {
    late Logger logger;
    late List<String> logOutput;

    // Setup to capture debugPrint output
    setUp(() {
      logger = const Logger('TestTag');
      logOutput = [];

      // Override debugPrint to capture output
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          logOutput.add(message);
        }
      };
    });

    test('Logger constructor sets tag correctly', () {
      expect(logger.tag, equals('TestTag'));
    });

    test('setLogLevel changes global log level', () {
      // Save original level to restore later
      final originalLevel = Logger.level;

      try {
        // Test changing log level
        Logger.setLogLevel(LogLevel.nothing);
        expect(Logger.level, equals(LogLevel.nothing));

        Logger.setLogLevel(LogLevel.verbose);
        expect(Logger.level, equals(LogLevel.verbose));
      } finally {
        // Restore original level
        Logger.level = originalLevel;
      }
    });

    test('_getLevelTag returns correct tag for each level', () {
      // Using private method for testing
      expect(logger.getLevelTag(LogLevel.verbose), equals('V'));
      expect(logger.getLevelTag(LogLevel.debug), equals('D'));
      expect(logger.getLevelTag(LogLevel.info), equals('I'));
      expect(logger.getLevelTag(LogLevel.warning), equals('W'));
      expect(logger.getLevelTag(LogLevel.error), equals('E'));
    });

    test('log methods respect log level filtering', () {
      // Set log level to warning
      final originalLevel = Logger.level;
      Logger.setLogLevel(LogLevel.warning);

      try {
        // These should not log anything
        logger.v('Verbose message');
        logger.d('Debug message');
        logger.i('Info message');

        // These should log
        logger.w('Warning message');
        logger.e('Error message');

        expect(logOutput.length, equals(2));
        expect(logOutput[0], contains('[TestTag] W: Warning message'));
        expect(logOutput[1], contains('[TestTag] E: Error message'));
      } finally {
        Logger.level = originalLevel;
      }
    });

    test('log methods include error and stack trace when provided', () {
      Logger.setLogLevel(LogLevel.verbose);
      final error = Exception('Test error');
      final stackTrace = StackTrace.current;

      logger.e('Error occurred', error, stackTrace);

      expect(logOutput.length, equals(3));
      expect(logOutput[0], contains('[TestTag] E: Error occurred'));
      expect(
          logOutput[1], contains('[TestTag] E: Error: Exception: Test error'));
      expect(logOutput[2], contains('[TestTag] E: StackTrace:'));
    });

    test('log methods format time correctly', () {
      Logger.setLogLevel(LogLevel.verbose);

      logger.i('Test message');

      // Check time format: HH:MM:SS.mmm
      final timePattern = RegExp(r'\d{2}:\d{2}:\d{2}\.\d{3}');
      expect(timePattern.hasMatch(logOutput[0]), isTrue);
    });

    test('all log level methods work correctly', () {
      Logger.setLogLevel(LogLevel.verbose);
      logOutput.clear();

      logger.v('Verbose message');
      logger.d('Debug message');
      logger.i('Info message');
      logger.w('Warning message');
      logger.e('Error message');

      expect(logOutput.length, equals(5));
      expect(logOutput[0], contains('[TestTag] V: Verbose message'));
      expect(logOutput[1], contains('[TestTag] D: Debug message'));
      expect(logOutput[2], contains('[TestTag] I: Info message'));
      expect(logOutput[3], contains('[TestTag] W: Warning message'));
      expect(logOutput[4], contains('[TestTag] E: Error message'));
    });

    test('debug mode sets appropriate default log level', () {
      // This is tricky to test since kDebugMode is a compile-time constant
      // We can only verify the current behavior
      if (kDebugMode) {
        expect(Logger.level, equals(LogLevel.verbose));
      } else {
        expect(Logger.level, equals(LogLevel.warning));
      }
    });
  });
}
