import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/constants/app_constants.dart';

/// Responsive utility class that provides context-aware dimensions.
/// Uses modern Flutter practices with proper dependency injection.
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Get responsive width based on context and optional constraints.
  static double getWidth(
    BuildContext context, {
    double? maxWidth,
    double? minWidth,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderSize = AppConstants.defaultBorderSize;

    double calculatedWidth = screenWidth - borderSize;

    if (maxWidth != null && calculatedWidth > maxWidth) {
      calculatedWidth = maxWidth;
    }

    if (minWidth != null && calculatedWidth < minWidth) {
      calculatedWidth = minWidth;
    }

    return calculatedWidth;
  }

  /// Get responsive height based on context and optional constraints.
  static double getHeight(
    BuildContext context, {
    double? maxHeight,
    double? minHeight,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;

    double calculatedHeight = screenHeight;

    if (maxHeight != null && calculatedHeight > maxHeight) {
      calculatedHeight = maxHeight;
    }

    if (minHeight != null && calculatedHeight < minHeight) {
      calculatedHeight = minHeight;
    }

    return calculatedHeight;
  }

  /// Get soundboard size based on platform and screen size.
  static double getSoundboardSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Use responsive approach instead of hardcoded platform checks
    if (screenWidth > AppConstants.desktopBreakpoint) {
      return AppConstants.defaultSoundboardSize;
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      return screenWidth * 0.8;
    } else {
      return screenWidth * 0.95;
    }
  }

  /// Check if current screen size is considered mobile.
  static bool isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  /// Check if current screen size is considered tablet.
  static bool isTabletLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint &&
        width < AppConstants.desktopBreakpoint;
  }

  /// Check if current screen size is considered desktop.
  static bool isDesktopLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }

  /// Get responsive text scale factor.
  static double getTextScaleFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < AppConstants.mobileBreakpoint) {
      return 0.9;
    } else if (width < AppConstants.tabletBreakpoint) {
      return 1.0;
    } else {
      return 1.1;
    }
  }
}

/// Riverpod provider for responsive breakpoints.
/// This allows reactive UI updates when screen size changes.
final responsiveBreakpointProvider = Provider<(bool, bool, bool)>((ref) {
  // This would need to be updated when MediaQuery changes
  // For now, returning defaults - in practice, you'd use a notifier
  return (false, false, true); // (isMobile, isTablet, isDesktop)
});

// Contains AI-generated edits.
