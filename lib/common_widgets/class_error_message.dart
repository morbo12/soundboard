import 'package:flutter/material.dart';
import 'package:soundboard/utils/logger.dart';

class ErrorHandler {
  static void showErrorMessage(BuildContext context, String message) {
    final Logger logger = const Logger('ErrorHandler');

    logger.d(message);

    // Display the error message to the user using a suitable UI component
    // For example, you can use a SnackBar:
    SnackBar snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
