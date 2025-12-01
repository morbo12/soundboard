import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog to preview and edit SSML before sending to TTS engine
class SsmlPreviewDialog extends StatefulWidget {
  final String initialSsml;
  final VoidCallback onCancel;
  final Future<void> Function(String ssml) onConfirm;

  const SsmlPreviewDialog({
    super.key,
    required this.initialSsml,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  State<SsmlPreviewDialog> createState() => _SsmlPreviewDialogState();
}

class _SsmlPreviewDialogState extends State<SsmlPreviewDialog>
    with SingleTickerProviderStateMixin {
  late TextEditingController _controller;
  late TabController _tabController;
  bool _isProcessing = false;
  int _currentView = 0; // 0: WYSIWYG, 1: Code, 2: Preview
  List<String> _validationErrors = [];
  List<SsmlSegment> _segments = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSsml);
    _tabController = TabController(length: 3, vsync: this);
    _parseSSML();
    _validateSsml();
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _validateSsml() {
    final errors = <String>[];
    final text = _controller.text;

    // Check for basic XML structure
    if (!text.contains('<speak')) {
      errors.add('Missing <speak> root element');
    }
    if (!text.contains('</speak>')) {
      errors.add('Missing closing </speak> tag');
    }

    // Check for common unclosed tags
    final openTags = RegExp(
      r'<(voice|prosody|break|emphasis|say-as|lang|mstts:express-as)\b[^>]*>',
    );
    final closeTags = RegExp(
      r'</(voice|prosody|emphasis|say-as|lang|mstts:express-as)>',
    );

    final opens = openTags.allMatches(text).length;
    final closes = closeTags.allMatches(text).length;

    if (opens > closes) {
      errors.add('Possible unclosed tags detected');
    }

    setState(() => _validationErrors = errors);
  }

  String _stripSsmlTags(String ssml) {
    return ssml
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _parseSSML() {
    final segments = <SsmlSegment>[];
    final text = _controller.text;

    // Extract content between speak tags
    final speakContent =
        RegExp(
          r'<speak[^>]*>(.*?)</speak>',
          dotAll: true,
        ).firstMatch(text)?.group(1) ??
        text;

    _parseSSMLContent(speakContent.trim(), segments);

    setState(() => _segments = segments);
  }

  void _parseSSMLContent(String content, List<SsmlSegment> segments) {
    if (content.isEmpty) return;

    int position = 0;

    while (position < content.length) {
      // Find the next tag
      final nextTagStart = content.indexOf('<', position);

      if (nextTagStart == -1) {
        // No more tags, add remaining text
        final remainingText = content.substring(position).trim();
        if (remainingText.isNotEmpty) {
          segments.add(SsmlSegment(type: SsmlType.text, text: remainingText));
        }
        break;
      }

      // Add any text before the tag
      if (nextTagStart > position) {
        final textBeforeTag = content.substring(position, nextTagStart).trim();
        if (textBeforeTag.isNotEmpty) {
          segments.add(SsmlSegment(type: SsmlType.text, text: textBeforeTag));
        }
      }

      // Find the tag name
      final tagEnd = content.indexOf('>', nextTagStart);
      if (tagEnd == -1) break;

      final tagContent = content.substring(nextTagStart, tagEnd + 1);

      // Self-closing break tag
      if (tagContent.startsWith('<break')) {
        final timeMatch = RegExp(r'time="(\d+)ms"').firstMatch(tagContent);
        final strengthMatch = RegExp(
          r'strength="([^"]+)"',
        ).firstMatch(tagContent);
        segments.add(
          SsmlSegment(
            type: SsmlType.pause,
            text: 'Pause',
            duration: timeMatch != null ? int.parse(timeMatch.group(1)!) : 500,
            strength: strengthMatch?.group(1),
          ),
        );
        position = tagEnd + 1;
      }
      // Say-as tag - parse inline with text
      else if (tagContent.startsWith('<say-as')) {
        final closeTag = '</say-as>';
        final closeIndex = content.indexOf(closeTag, tagEnd);
        if (closeIndex != -1) {
          final innerContent = content.substring(tagEnd + 1, closeIndex).trim();
          final interpretAs = RegExp(
            r'''interpret-as=["']([^"']+)["']''',
          ).firstMatch(tagContent)?.group(1);
          final format = RegExp(
            r'''format=["']([^"']+)["']''',
          ).firstMatch(tagContent)?.group(1);
          // Validate interpretAs is in allowed list (case-insensitive)
          const allowedInterpretAs = [
            'cardinal',
            'ordinal',
            'characters',
            'spell-out',
            'digits',
            'fraction',
            'unit',
            'date',
            'time',
            'telephone',
            'address',
            'name',
          ];
          final normalizedInterpretAs = interpretAs?.toLowerCase();
          final validInterpretAs =
              normalizedInterpretAs != null &&
                  allowedInterpretAs.contains(normalizedInterpretAs)
              ? normalizedInterpretAs
              : 'cardinal';
          segments.add(
            SsmlSegment(
              type: SsmlType.sayAs,
              text: innerContent,
              interpretAs: validInterpretAs,
              format: format,
            ),
          );
          position = closeIndex + closeTag.length;
        } else {
          position = tagEnd + 1;
        }
      }
      // Prosody tag - skip the tag itself and parse content
      else if (tagContent.startsWith('<prosody')) {
        final closeTag = '</prosody>';
        final closeIndex = content.indexOf(closeTag, tagEnd);
        if (closeIndex != -1) {
          final innerContent = content.substring(tagEnd + 1, closeIndex);
          // Just recursively parse the inner content, ignoring prosody wrapper
          _parseSSMLContent(innerContent, segments);
          position = closeIndex + closeTag.length;
        } else {
          position = tagEnd + 1;
        }
      }
      // Express-as tag - skip the tag itself and parse content
      else if (tagContent.startsWith('<mstts:express-as')) {
        final closeTag = '</mstts:express-as>';
        final closeIndex = content.indexOf(closeTag, tagEnd);
        if (closeIndex != -1) {
          final innerContent = content.substring(tagEnd + 1, closeIndex);
          // Just recursively parse the inner content, ignoring express-as wrapper
          _parseSSMLContent(innerContent, segments);
          position = closeIndex + closeTag.length;
        } else {
          position = tagEnd + 1;
        }
      }
      // Voice tag - skip the tag itself and parse content
      else if (tagContent.startsWith('<voice')) {
        final closeTag = '</voice>';
        final closeIndex = content.indexOf(closeTag, tagEnd);
        if (closeIndex != -1) {
          final innerContent = content.substring(tagEnd + 1, closeIndex);
          // Just recursively parse the inner content, ignoring voice wrapper
          _parseSSMLContent(innerContent, segments);
          position = closeIndex + closeTag.length;
        } else {
          position = tagEnd + 1;
        }
      }
      // Emphasis tag
      else if (tagContent.startsWith('<emphasis')) {
        final closeTag = '</emphasis>';
        final closeIndex = content.indexOf(closeTag, tagEnd);
        if (closeIndex != -1) {
          final innerContent = content.substring(tagEnd + 1, closeIndex).trim();
          final level = RegExp(
            r'''level=["']([^"']+)["']''',
          ).firstMatch(tagContent)?.group(1);
          // Validate level is in allowed list
          const allowedLevels = ['strong', 'moderate', 'reduced'];
          final validLevel = level != null && allowedLevels.contains(level)
              ? level
              : 'strong';
          segments.add(
            SsmlSegment(
              type: SsmlType.emphasis,
              text: innerContent,
              emphasisLevel: validLevel,
            ),
          );
          position = closeIndex + closeTag.length;
        } else {
          position = tagEnd + 1;
        }
      }
      // Phoneme tag
      else if (tagContent.startsWith('<phoneme')) {
        final closeTag = '</phoneme>';
        final closeIndex = content.indexOf(closeTag, tagEnd);
        if (closeIndex != -1) {
          final innerContent = content.substring(tagEnd + 1, closeIndex).trim();
          final alphabet = RegExp(
            r'''alphabet=["']([^"']+)["']''',
          ).firstMatch(tagContent)?.group(1);
          final ph = RegExp(
            r'''ph=["']([^"']+)["']''',
          ).firstMatch(tagContent)?.group(1);
          // Validate alphabet is in allowed list
          const allowedAlphabets = ['ipa', 'sapi'];
          final validAlphabet =
              alphabet != null && allowedAlphabets.contains(alphabet)
              ? alphabet
              : 'ipa';
          segments.add(
            SsmlSegment(
              type: SsmlType.phoneme,
              text: innerContent,
              alphabet: validAlphabet,
              ph: ph,
            ),
          );
          position = closeIndex + closeTag.length;
        } else {
          position = tagEnd + 1;
        }
      }
      // Sub tag
      else if (tagContent.startsWith('<sub')) {
        final closeTag = '</sub>';
        final closeIndex = content.indexOf(closeTag, tagEnd);
        if (closeIndex != -1) {
          final innerContent = content.substring(tagEnd + 1, closeIndex).trim();
          final alias = RegExp(
            r'''alias=["']([^"']+)["']''',
          ).firstMatch(tagContent)?.group(1);
          segments.add(
            SsmlSegment(type: SsmlType.sub, text: innerContent, alias: alias),
          );
          position = closeIndex + closeTag.length;
        } else {
          position = tagEnd + 1;
        }
      }
      // Lang tag
      else if (tagContent.startsWith('<lang')) {
        final closeTag = '</lang>';
        final closeIndex = content.indexOf(closeTag, tagEnd);
        if (closeIndex != -1) {
          final innerContent = content.substring(tagEnd + 1, closeIndex).trim();
          final lang = RegExp(
            r'''xml:lang=["']([^"']+)["']''',
          ).firstMatch(tagContent)?.group(1);
          segments.add(
            SsmlSegment(
              type: SsmlType.lang,
              text: innerContent,
              language: lang,
            ),
          );
          position = closeIndex + closeTag.length;
        } else {
          position = tagEnd + 1;
        }
      }
      // Skip unknown or closing tags
      else {
        position = tagEnd + 1;
      }
    }
  }

  void _rebuildSSML() {
    final buffer = StringBuffer();
    buffer.write(
      '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" ',
    );
    buffer.write(
      'xmlns:mstts="https://azure.microsoft.com/services/cognitive-services/text-to-speech/" ',
    );
    buffer.write('xml:lang="sv-SE">');

    for (final segment in _segments) {
      switch (segment.type) {
        case SsmlType.text:
          buffer.write(segment.text);
          break;
        case SsmlType.pause:
          buffer.write('<break');
          if (segment.strength != null) {
            buffer.write(' strength="${segment.strength}"');
          } else {
            buffer.write(' time="${segment.duration}ms"');
          }
          buffer.write('/>');
          break;
        case SsmlType.emphasis:
          buffer.write(
            '<emphasis level="${segment.emphasisLevel ?? 'strong'}">${segment.text}</emphasis>',
          );
          break;
        case SsmlType.prosody:
          buffer.write('<prosody');
          if (segment.rate != null) buffer.write(' rate="${segment.rate}"');
          if (segment.pitch != null) buffer.write(' pitch="${segment.pitch}"');
          if (segment.volume != null)
            buffer.write(' volume="${segment.volume}"');
          buffer.write('>${segment.text}</prosody>');
          break;
        case SsmlType.sayAs:
          buffer.write(
            '<say-as interpret-as="${segment.interpretAs ?? 'cardinal'}"',
          );
          if (segment.format != null)
            buffer.write(' format="${segment.format}"');
          buffer.write('>${segment.text}</say-as>');
          break;
        case SsmlType.phoneme:
          buffer.write(
            '<phoneme alphabet="${segment.alphabet ?? 'ipa'}" ph="${segment.ph ?? ''}">${segment.text}</phoneme>',
          );
          break;
        case SsmlType.sub:
          buffer.write(
            '<sub alias="${segment.alias ?? ''}">${segment.text}</sub>',
          );
          break;
        case SsmlType.lang:
          buffer.write(
            '<lang xml:lang="${segment.language ?? 'en-US'}">${segment.text}</lang>',
          );
          break;
        case SsmlType.voice:
          buffer.write(
            '<voice name="${segment.voiceName ?? ''}">${segment.text}</voice>',
          );
          break;
        case SsmlType.expressAs:
          buffer.write('<mstts:express-as');
          if (segment.style != null) buffer.write(' style="${segment.style}"');
          if (segment.styleDegree != null) {
            buffer.write(' styledegree="${segment.styleDegree}"');
          }
          if (segment.role != null) buffer.write(' role="${segment.role}"');
          buffer.write('>${segment.text}</mstts:express-as>');
          break;
      }
    }

    buffer.write('</speak>');
    _controller.text = buffer.toString();
    _validateSsml();
  }

  Future<void> _handleConfirm() async {
    setState(() => _isProcessing = true);
    try {
      await widget.onConfirm(_controller.text);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleCancel() {
    widget.onCancel();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plainText = _stripSsmlTags(_controller.text);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      child: Container(
        width: screenSize.width * 0.85,
        height: screenSize.height * 0.85,
        constraints: const BoxConstraints(
          minWidth: 900,
          minHeight: 700,
          maxWidth: 1400,
          maxHeight: 900,
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.code, color: theme.colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SSML Editor',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Edit speech markup before sending to TTS',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // View mode toggle
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(
                      value: 0,
                      icon: Icon(Icons.edit, size: 18),
                      label: Text('Visual'),
                    ),
                    ButtonSegment(
                      value: 1,
                      icon: Icon(Icons.code, size: 18),
                      label: Text('Code'),
                    ),
                    ButtonSegment(
                      value: 2,
                      icon: Icon(Icons.preview, size: 18),
                      label: Text('Preview'),
                    ),
                  ],
                  selected: {_currentView},
                  onSelectionChanged: (Set<int> selection) {
                    setState(() => _currentView = selection.first);
                    if (_currentView == 0) _parseSSML();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Validation warnings
            if (_validationErrors.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationErrors.join(', '),
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Quick Actions Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildQuickButton(
                    context,
                    'Format',
                    Icons.format_align_left,
                    _formatSsml,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickButton(
                    context,
                    'Validate',
                    Icons.check_circle_outline,
                    _validateSsml,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickButton(context, 'Copy', Icons.copy, () {
                    Clipboard.setData(ClipboardData(text: _controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  }),
                  const Spacer(),
                  Text(
                    '${_controller.text.length} chars',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Editor Area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: _validationErrors.isEmpty
                        ? theme.colorScheme.outline.withOpacity(0.5)
                        : Colors.orange,
                    width: _validationErrors.isEmpty ? 1 : 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildEditorView(theme),
              ),
            ),
            const SizedBox(height: 16),

            // Common SSML Tags Reference
            _buildQuickReference(theme),
            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isProcessing ? null : _handleCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _handleConfirm,
                  icon: _isProcessing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(_isProcessing ? 'Sending...' : 'Send to TTS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return TextButton.icon(
      onPressed: _isProcessing ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildEditorView(ThemeData theme) {
    switch (_currentView) {
      case 0:
        return _buildWysiwygEditor(theme);
      case 1:
        return _buildSsmlCodeEditor(theme);
      case 2:
        return _buildPlainTextView(_stripSsmlTags(_controller.text), theme);
      default:
        return _buildSsmlCodeEditor(theme);
    }
  }

  Widget _buildWysiwygEditor(ThemeData theme) {
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildWysiwygButton(
                  context,
                  'Text',
                  Icons.text_fields,
                  () => _addSegment(
                    SsmlSegment(type: SsmlType.text, text: 'New text'),
                  ),
                ),
                const SizedBox(width: 4),
                _buildWysiwygButton(
                  context,
                  'Pause',
                  Icons.pause_circle,
                  () => _addSegment(
                    SsmlSegment(
                      type: SsmlType.pause,
                      text: 'Pause',
                      duration: 500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildWysiwygButton(
                  context,
                  'Emphasis',
                  Icons.format_bold,
                  () => _addSegment(
                    SsmlSegment(
                      type: SsmlType.emphasis,
                      text: 'Emphasized text',
                      emphasisLevel: 'strong',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildWysiwygButton(
                  context,
                  'Prosody',
                  Icons.tune,
                  () => _addSegment(
                    SsmlSegment(
                      type: SsmlType.prosody,
                      text: 'Modified speech',
                      rate: 'medium',
                      pitch: 'medium',
                      volume: 'medium',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildWysiwygButton(
                  context,
                  'Say As',
                  Icons.pin,
                  () => _addSegment(
                    SsmlSegment(
                      type: SsmlType.sayAs,
                      text: '12345',
                      interpretAs: 'cardinal',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildWysiwygButton(
                  context,
                  'Language',
                  Icons.language,
                  () => _addSegment(
                    SsmlSegment(
                      type: SsmlType.lang,
                      text: 'Foreign text',
                      language: 'en-US',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildWysiwygButton(
                  context,
                  'Express-As',
                  Icons.theater_comedy,
                  () => _addSegment(
                    SsmlSegment(
                      type: SsmlType.expressAs,
                      text: 'Expressive speech',
                      style: 'cheerful',
                      styleDegree: '1.0',
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _buildWysiwygButton(
                  context,
                  'Substitute',
                  Icons.swap_horiz,
                  () => _addSegment(
                    SsmlSegment(
                      type: SsmlType.sub,
                      text: 'SSML',
                      alias: 'Speech Synthesis Markup Language',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Segments list
        Expanded(
          child: _segments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.text_fields,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No content yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add elements using the toolbar above',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _segments.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _segments.removeAt(oldIndex);
                      _segments.insert(newIndex, item);
                      _rebuildSSML();
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildSegmentCard(_segments[index], index, theme);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSegmentCard(SsmlSegment segment, int index, ThemeData theme) {
    return Card(
      key: ValueKey(index),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(_getSegmentIcon(segment.type)),
        title: _buildSegmentEditor(segment, index, theme),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () {
                setState(() {
                  _segments.removeAt(index);
                  _rebuildSSML();
                });
              },
            ),
            const Icon(Icons.drag_handle),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentEditor(SsmlSegment segment, int index, ThemeData theme) {
    switch (segment.type) {
      case SsmlType.text:
        return TextFormField(
          initialValue: segment.text,
          decoration: const InputDecoration(
            hintText: 'Enter text to speak',
            border: InputBorder.none,
          ),
          maxLines: null,
          onChanged: (value) {
            segment.text = value;
            _rebuildSSML();
          },
        );
      case SsmlType.pause:
        return Row(
          children: [
            const Text('Type: ', style: TextStyle(fontSize: 12)),
            DropdownButton<String?>(
              value: segment.strength != null ? 'strength' : 'time',
              isDense: true,
              items: const [
                DropdownMenuItem(value: 'time', child: Text('Duration')),
                DropdownMenuItem(value: 'strength', child: Text('Strength')),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == 'strength') {
                    segment.strength = 'medium';
                  } else {
                    segment.strength = null;
                  }
                  _rebuildSSML();
                });
              },
            ),
            const SizedBox(width: 16),
            if (segment.strength == null)
              Expanded(
                child: Row(
                  children: [
                    const Text('Duration: ', style: TextStyle(fontSize: 12)),
                    SizedBox(
                      width: 100,
                      child: TextFormField(
                        initialValue: segment.duration.toString(),
                        decoration: const InputDecoration(
                          suffixText: 'ms',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          segment.duration = int.tryParse(value) ?? 500;
                          _rebuildSSML();
                        },
                      ),
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: Row(
                  children: [
                    const Text('Strength: ', style: TextStyle(fontSize: 12)),
                    DropdownButton<String>(
                      value: segment.strength,
                      isDense: true,
                      items:
                          [
                                'none',
                                'x-weak',
                                'weak',
                                'medium',
                                'strong',
                                'x-strong',
                              ]
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          segment.strength = value;
                          _rebuildSSML();
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        );
      case SsmlType.emphasis:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: segment.text,
              decoration: const InputDecoration(
                hintText: 'Emphasized text',
                border: InputBorder.none,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: null,
              onChanged: (value) {
                segment.text = value;
                _rebuildSSML();
              },
            ),
            Row(
              children: [
                const Text('Level: ', style: TextStyle(fontSize: 12)),
                DropdownButton<String>(
                  value: segment.emphasisLevel ?? 'strong',
                  isDense: true,
                  items: ['strong', 'moderate', 'reduced']
                      .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      segment.emphasisLevel = value;
                      _rebuildSSML();
                    });
                  },
                ),
              ],
            ),
          ],
        );
      case SsmlType.prosody:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: segment.text,
              decoration: const InputDecoration(
                hintText: 'Text with prosody changes',
                border: InputBorder.none,
              ),
              maxLines: null,
              onChanged: (value) {
                segment.text = value;
                _rebuildSSML();
              },
            ),
            Wrap(
              spacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Rate:', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    DropdownButton<String>(
                      value: segment.rate ?? 'medium',
                      isDense: true,
                      items: ['x-slow', 'slow', 'medium', 'fast', 'x-fast']
                          .map(
                            (r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          segment.rate = value;
                          _rebuildSSML();
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pitch:', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    DropdownButton<String>(
                      value: segment.pitch ?? 'medium',
                      isDense: true,
                      items: ['x-low', 'low', 'medium', 'high', 'x-high']
                          .map(
                            (p) => DropdownMenuItem(
                              value: p,
                              child: Text(
                                p,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          segment.pitch = value;
                          _rebuildSSML();
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Volume:', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    DropdownButton<String>(
                      value: segment.volume ?? 'medium',
                      isDense: true,
                      items:
                          [
                                'silent',
                                'x-soft',
                                'soft',
                                'medium',
                                'loud',
                                'x-loud',
                              ]
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(
                                    v,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          segment.volume = value;
                          _rebuildSSML();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      case SsmlType.sayAs:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: segment.text,
              decoration: const InputDecoration(
                hintText: 'Text to interpret',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                segment.text = value;
                _rebuildSSML();
              },
            ),
            Row(
              children: [
                const Text('Interpret as:', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: segment.interpretAs ?? 'cardinal',
                  isDense: true,
                  items:
                      [
                            'cardinal',
                            'ordinal',
                            'characters',
                            'spell-out',
                            'digits',
                            'fraction',
                            'unit',
                            'date',
                            'time',
                            'telephone',
                            'address',
                            'name',
                          ]
                          .map(
                            (i) => DropdownMenuItem(
                              value: i,
                              child: Text(
                                i,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      segment.interpretAs = value;
                      _rebuildSSML();
                    });
                  },
                ),
              ],
            ),
          ],
        );
      case SsmlType.phoneme:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: segment.text,
              decoration: const InputDecoration(
                hintText: 'Written text',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                segment.text = value;
                _rebuildSSML();
              },
            ),
            Row(
              children: [
                const Text('Alphabet:', style: TextStyle(fontSize: 12)),
                DropdownButton<String>(
                  value: segment.alphabet ?? 'ipa',
                  isDense: true,
                  items: ['ipa', 'sapi']
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      segment.alphabet = value;
                      _rebuildSSML();
                    });
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: segment.ph ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Phonetic pronunciation',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      segment.ph = value;
                      _rebuildSSML();
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      case SsmlType.sub:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: segment.text,
              decoration: const InputDecoration(
                hintText: 'Written text',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                segment.text = value;
                _rebuildSSML();
              },
            ),
            TextFormField(
              initialValue: segment.alias ?? '',
              decoration: const InputDecoration(
                labelText: 'Spoken as (alias)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                segment.alias = value;
                _rebuildSSML();
              },
            ),
          ],
        );
      case SsmlType.lang:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: segment.text,
              decoration: const InputDecoration(
                hintText: 'Text in foreign language',
                border: InputBorder.none,
              ),
              maxLines: null,
              onChanged: (value) {
                segment.text = value;
                _rebuildSSML();
              },
            ),
            Row(
              children: [
                const Text('Language:', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: segment.language ?? 'en-US',
                  isDense: true,
                  items:
                      [
                            'en-US',
                            'en-GB',
                            'sv-SE',
                            'de-DE',
                            'fr-FR',
                            'es-ES',
                            'it-IT',
                            'pt-BR',
                            'ja-JP',
                            'zh-CN',
                          ]
                          .map(
                            (l) => DropdownMenuItem(value: l, child: Text(l)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setState(() {
                      segment.language = value;
                      _rebuildSSML();
                    });
                  },
                ),
              ],
            ),
          ],
        );
      case SsmlType.voice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: segment.text,
              decoration: const InputDecoration(
                hintText: 'Text with different voice',
                border: InputBorder.none,
              ),
              maxLines: null,
              onChanged: (value) {
                segment.text = value;
                _rebuildSSML();
              },
            ),
            TextFormField(
              initialValue: segment.voiceName ?? '',
              decoration: const InputDecoration(
                labelText: 'Voice name (e.g., sv-SE-SofieNeural)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                segment.voiceName = value;
                _rebuildSSML();
              },
            ),
          ],
        );
      case SsmlType.expressAs:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              initialValue: segment.text,
              decoration: const InputDecoration(
                hintText: 'Text with speaking style',
                border: InputBorder.none,
              ),
              maxLines: null,
              onChanged: (value) {
                segment.text = value;
                _rebuildSSML();
              },
            ),
            Wrap(
              spacing: 12,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Style:', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    DropdownButton<String>(
                      value: segment.style ?? 'cheerful',
                      isDense: true,
                      items:
                          [
                                'cheerful',
                                'sad',
                                'angry',
                                'excited',
                                'friendly',
                                'terrified',
                                'shouting',
                                'whispering',
                                'hopeful',
                                'calm',
                                'fearful',
                                'empathetic',
                                'newscast',
                                'customer-service',
                              ]
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: (value) {
                        setState(() {
                          segment.style = value;
                          _rebuildSSML();
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Degree:', style: TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 80,
                      child: TextFormField(
                        initialValue: segment.styleDegree ?? '1.0',
                        decoration: const InputDecoration(
                          hintText: '0.01-2.0',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          segment.styleDegree = value;
                          _rebuildSSML();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
    }
  }

  IconData _getSegmentIcon(SsmlType type) {
    switch (type) {
      case SsmlType.text:
        return Icons.text_fields;
      case SsmlType.pause:
        return Icons.pause_circle;
      case SsmlType.emphasis:
        return Icons.format_bold;
      case SsmlType.prosody:
        return Icons.tune;
      case SsmlType.sayAs:
        return Icons.pin;
      case SsmlType.phoneme:
        return Icons.record_voice_over;
      case SsmlType.sub:
        return Icons.swap_horiz;
      case SsmlType.lang:
        return Icons.language;
      case SsmlType.voice:
        return Icons.person;
      case SsmlType.expressAs:
        return Icons.theater_comedy;
    }
  }

  void _addSegment(SsmlSegment segment) {
    setState(() {
      _segments.add(segment);
      _rebuildSSML();
    });
  }

  Widget _buildWysiwygButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: _isProcessing ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildSsmlCodeEditor(ThemeData theme) {
    return TextField(
      controller: _controller,
      maxLines: null,
      expands: true,
      onChanged: (_) => _validateSsml(),
      decoration: const InputDecoration(
        hintText: 'Edit SSML content here...',
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
      ),
      style: TextStyle(
        fontFamily: 'Courier New',
        fontSize: 13,
        color: theme.colorScheme.onSurface,
        height: 1.5,
      ),
      enabled: !_isProcessing,
    );
  }

  Widget _buildPlainTextView(String plainText, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        plainText,
        style: TextStyle(
          fontSize: 14,
          color: theme.colorScheme.onSurface,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildQuickReference(ThemeData theme) {
    return ExpansionTile(
      dense: true,
      title: Text(
        'Common SSML Tags',
        style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTagChip('<break time="500ms"/>', 'Pause'),
              _buildTagChip(
                '<emphasis level="strong">text</emphasis>',
                'Emphasis',
              ),
              _buildTagChip('<prosody rate="slow">text</prosody>', 'Speed'),
              _buildTagChip('<prosody pitch="high">text</prosody>', 'Pitch'),
              _buildTagChip('<lang xml:lang="en-US">text</lang>', 'Language'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag, String label) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      onPressed: () {
        final selection = _controller.selection;
        if (selection.isValid && !selection.isCollapsed) {
          final selectedText = _controller.text.substring(
            selection.start,
            selection.end,
          );
          final wrappedTag = tag.replaceAll('text', selectedText);
          _controller.text = _controller.text.replaceRange(
            selection.start,
            selection.end,
            wrappedTag,
          );
        }
        _validateSsml();
      },
    );
  }

  void _formatSsml() {
    String formatted = _controller.text;

    // Basic XML formatting - add newlines after major tags
    formatted = formatted
        .replaceAll('><', '>\n<')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    setState(() {
      _controller.text = formatted;
      _validateSsml();
    });
  }
}

/// SSML segment types based on Azure Speech Service SSML specification
enum SsmlType {
  text,
  pause, // <break>
  emphasis, // <emphasis>
  prosody, // <prosody> for rate, pitch, volume
  sayAs, // <say-as> for dates, numbers, etc.
  phoneme, // <phoneme> for pronunciation
  sub, // <sub> for substitution
  lang, // <lang> for language switching
  voice, // <voice> for voice changing
  expressAs, // <mstts:express-as> for speaking style
}

/// Represents a segment of SSML content
class SsmlSegment {
  SsmlType type;
  String text;

  // Break attributes
  int duration; // milliseconds
  String? strength; // none, x-weak, weak, medium, strong, x-strong

  // Prosody attributes
  String? rate; // x-slow, slow, medium, fast, x-fast, or percentage
  String? pitch; // x-low, low, medium, high, x-high, or relative values
  String? volume; // silent, x-soft, soft, medium, loud, x-loud, or percentage

  // Emphasis attributes
  String? emphasisLevel; // strong, moderate, reduced

  // Say-as attributes
  String?
  interpretAs; // cardinal, ordinal, characters, date, time, telephone, etc.
  String? format; // For dates and times

  // Phoneme attributes
  String? alphabet; // ipa or sapi
  String? ph; // Phonetic pronunciation

  // Substitution
  String? alias; // Text to speak instead of written text

  // Language
  String? language; // Language code (e.g., en-US, sv-SE)

  // Voice
  String? voiceName; // Voice name

  // Express-as attributes (Azure specific)
  String? style; // cheerful, sad, angry, excited, friendly, terrified, etc.
  String? styleDegree; // 0.01 to 2.0
  String? role; // narrator, character roles

  SsmlSegment({
    required this.type,
    required this.text,
    this.duration = 500,
    this.strength,
    this.rate,
    this.pitch,
    this.volume,
    this.emphasisLevel,
    this.interpretAs,
    this.format,
    this.alphabet,
    this.ph,
    this.alias,
    this.language,
    this.voiceName,
    this.style,
    this.styleDegree,
    this.role,
  });
}
