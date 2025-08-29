/// SSML (Speech Synthesis Markup Language) utilities for audio processing
class SSMLHeader {
  /// Private constructor to prevent instantiation
  const SSMLHeader._();

  /// Wraps the provided input with SSML speak tags
  ///
  /// Parameters:
  /// - [input]: The text content to be wrapped with SSML speak tags
  /// - [language]: The language code for xml:lang attribute (defaults to 'en-US')
  ///
  /// Returns a properly formatted SSML string with speak tags
  static String wrapWithSpeakTags(String input, {String language = 'en-US'}) {
    return '''<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="https://www.w3.org/2001/mstts" xml:lang="$language">
$input
</speak>''';
  }

  /// Creates a complete SSML document with custom attributes
  ///
  /// Parameters:
  /// - [input]: The text content to be wrapped
  /// - [version]: SSML version (defaults to '1.0')
  /// - [language]: Language code for xml:lang attribute (defaults to 'en-US')
  /// - [xmlns]: Main XML namespace (defaults to standard SSML namespace)
  /// - [msttsNamespace]: Microsoft Text-to-Speech namespace (optional)
  ///
  /// Returns a customizable SSML document
  static String createSSMLDocument(
    String input, {
    String version = '1.0',
    String language = 'en-US',
    String xmlns = 'http://www.w3.org/2001/10/synthesis',
    String? msttsNamespace = 'https://www.w3.org/2001/mstts',
  }) {
    final namespaceAttribute = msttsNamespace != null
        ? ' xmlns:mstts="$msttsNamespace"'
        : '';

    return '''<speak version="$version" xmlns="$xmlns"$namespaceAttribute xml:lang="$language">
$input
</speak>''';
  }

  /// Validates if a string is properly wrapped with SSML speak tags
  ///
  /// Parameters:
  /// - [ssmlContent]: The SSML content to validate
  ///
  /// Returns true if the content has proper speak tags
  static bool isValidSSMLDocument(String ssmlContent) {
    final trimmed = ssmlContent.trim();
    return trimmed.startsWith('<speak') && trimmed.endsWith('</speak>');
  }

  /// Extracts the content from within SSML speak tags
  ///
  /// Parameters:
  /// - [ssmlContent]: The SSML document to extract content from
  ///
  /// Returns the inner content without the speak tags, or null if invalid
  static String? extractContent(String ssmlContent) {
    if (!isValidSSMLDocument(ssmlContent)) {
      return null;
    }

    final startIndex = ssmlContent.indexOf('>') + 1;
    final endIndex = ssmlContent.lastIndexOf('</speak>');

    if (startIndex < endIndex) {
      return ssmlContent.substring(startIndex, endIndex).trim();
    }

    return null;
  }
}

// Contains AI-generated edits.
