import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static void showErrorMessage(BuildContext context, String message) {
    if (kDebugMode) {
      print(message);
    }

    // Display the error message to the user using a suitable UI component
    // For example, you can use a SnackBar:
    SnackBar snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
