import 'package:flutter/material.dart';
import 'class_ssml_base.dart';

class CustomTtsEvent extends BaseSsmlEvent {
  CustomTtsEvent({required super.ref}) : super(loggerName: 'CustomTtsEvent');

  @override
  String formatContent() {
    // This method is required by the abstract class but not used for custom TTS
    return '';
  }

  @override
  Future<bool> getSay(BuildContext context) async {
    // This method is required by the abstract class but not used for custom TTS
    return true;
  }
}
