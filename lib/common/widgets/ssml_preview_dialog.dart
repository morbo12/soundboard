import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/services/ai_sentence_service.dart';
import 'package:soundboard/core/services/auth_service.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/pregame_stats.dart';
import 'package:soundboard/core/services/innebandy_api/presentation/providers/pregame_stats_provider.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Dialog to preview and edit SSML before sending to TTS engine
class SsmlPreviewDialog extends ConsumerStatefulWidget {
  final String initialSsml;
  final VoidCallback onCancel;
  final Future<void> Function(String ssml) onConfirm;

  // Optional: For lineup mode with multiple sections
  final Map<String, String>? sections;
  final Future<void> Function(Map<String, String> sections)? onConfirmSections;

  const SsmlPreviewDialog({
    super.key,
    required this.initialSsml,
    required this.onCancel,
    required this.onConfirm,
    this.sections,
    this.onConfirmSections,
  });

  @override
  ConsumerState<SsmlPreviewDialog> createState() => _SsmlPreviewDialogState();
}

// AI Enhance now supports only a single balanced style; enum removed.

class _SsmlPreviewDialogState extends ConsumerState<SsmlPreviewDialog> {
  late TextEditingController _plainTextController;
  late TextEditingController _ssmlController;
  bool _isProcessing = false;
  bool _showPlainText = true; // true: Plain Text, false: SSML Code
  List<String> _validationErrors = [];
  bool _isEnhancing = false;
  // No per-style selection; only balanced mode is supported

  // For multi-section mode (lineup)
  bool _isMultiSection = false;
  String _currentSection = 'welcome';
  Map<String, TextEditingController> _sectionPlainTextControllers = {};
  Map<String, TextEditingController> _sectionSsmlControllers = {};

  @override
  void initState() {
    super.initState();

    _isMultiSection = widget.sections != null;

    if (_isMultiSection) {
      // Initialize controllers for each section
      for (final entry in widget.sections!.entries) {
        _sectionSsmlControllers[entry.key] = TextEditingController(
          text: entry.value,
        );
        _sectionPlainTextControllers[entry.key] = TextEditingController(
          text: _stripSsmlTags(entry.value),
        );
      }
    } else {
      // Single section mode
      _ssmlController = TextEditingController(text: widget.initialSsml);
      _plainTextController = TextEditingController(
        text: _stripSsmlTags(widget.initialSsml),
      );
    }

    _validateSsml();
  }

  @override
  void dispose() {
    if (_isMultiSection) {
      for (final controller in _sectionPlainTextControllers.values) {
        controller.dispose();
      }
      for (final controller in _sectionSsmlControllers.values) {
        controller.dispose();
      }
    } else {
      _plainTextController.dispose();
      _ssmlController.dispose();
    }
    super.dispose();
  }

  void _validateSsml() {
    final errors = <String>[];
    final text = _isMultiSection
        ? (_sectionSsmlControllers[_currentSection]?.text ?? '')
        : _ssmlController.text;

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
        // Convert break tags to newlines
        .replaceAll(RegExp(r'<break[^>]*/>'), '\n')
        // Remove all other SSML tags but keep their content
        .replaceAll(RegExp(r'<[^>]*>'), '')
        // Clean up multiple consecutive newlines and whitespace
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        // Trim each line to remove trailing spaces
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .join('\n')
        // Remove leading/trailing whitespace from entire text
        .trim();
  }

  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _wrapWithSsml(String plainText) {
    final escapedText = _escapeXml(plainText);
    final settings = SettingsBox();
    final voiceName = settings.azVoiceName;
    return '<speak version="1.0" xmlns="http://www.w3.org/2001/10/synthesis" '
        'xmlns:mstts="https://azure.microsoft.com/services/cognitive-services/text-to-speech/" '
        'xml:lang="sv-SE">'
        '<voice name="$voiceName">$escapedText</voice>'
        '</speak>';
  }

  Future<void> _handleConfirm() async {
    setState(() => _isProcessing = true);
    try {
      if (_isMultiSection && widget.onConfirmSections != null) {
        // Multi-section mode: collect all edited sections
        final editedSections = <String, String>{};
        for (final key in widget.sections!.keys) {
          final ssmlText = _showPlainText
              ? _wrapWithSsml(_sectionPlainTextControllers[key]!.text)
              : _sectionSsmlControllers[key]!.text;
          editedSections[key] = ssmlText;
        }
        await widget.onConfirmSections!(editedSections);
      } else {
        // Single section mode
        final ssmlToSend = _showPlainText
            ? _wrapWithSsml(_plainTextController.text)
            : _ssmlController.text;
        await widget.onConfirm(ssmlToSend);
      }
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
                        _isMultiSection ? 'Lineup SSML Editor' : 'SSML Editor',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _isMultiSection
                            ? 'Edit lineup sections: Welcome, Away Team, Home Team'
                            : 'Edit speech markup before sending to TTS',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                // View mode toggle
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.text_fields, size: 18),
                      label: Text('Plain Text'),
                    ),
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.code, size: 18),
                      label: Text('SSML Code'),
                    ),
                  ],
                  selected: {_showPlainText},
                  onSelectionChanged: (Set<bool> selection) {
                    setState(() => _showPlainText = selection.first);
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

            // Section tabs for multi-section mode
            if (_isMultiSection)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: SegmentedButton<String>(
                  segments: _buildSectionSegments(),
                  selected: {_currentSection},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _currentSection = selection.first;
                      _validateSsml();
                    });
                  },
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
                    final controller = _showPlainText
                        ? _plainTextController
                        : _ssmlController;
                    Clipboard.setData(ClipboardData(text: controller.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  }),
                  const SizedBox(width: 8),
                  // Single AI enhance button (balanced style only)
                  TextButton.icon(
                    onPressed: _isEnhancing ? null : _enhanceWithAI,
                    icon: const Icon(Icons.auto_awesome, size: 16),
                    label: Text('AI Enhance', style: theme.textTheme.bodySmall),
                  ),
                  if (_isEnhancing)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  const Spacer(),
                  Text(
                    '${_getCurrentController().text.length} chars',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Editor area
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildEditorView(theme),
              ),
            ),
            const SizedBox(height: 12),

            // Quick Reference
            _buildQuickReference(theme),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isProcessing ? null : _handleCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  onPressed: _isProcessing ? null : _handleConfirm,
                  child: _isProcessing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm'),
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
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildEditorView(ThemeData theme) {
    return _showPlainText
        ? _buildPlainTextEditor(theme)
        : _buildSsmlCodeEditor(theme);
  }

  Widget _buildPlainTextEditor(ThemeData theme) {
    final controller = _isMultiSection
        ? _sectionPlainTextControllers[_currentSection]!
        : _plainTextController;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: _isMultiSection
              ? 'Enter text for ${_getSectionDisplayName(_currentSection)}...'
              : 'Enter text to speak...',
          border: InputBorder.none,
        ),
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildSsmlCodeEditor(ThemeData theme) {
    final controller = _isMultiSection
        ? _sectionSsmlControllers[_currentSection]!
        : _ssmlController;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        onChanged: (_) => _validateSsml(),
        decoration: InputDecoration(
          hintText: _isMultiSection
              ? 'Edit SSML for ${_getSectionDisplayName(_currentSection)}...'
              : 'Edit SSML content here...',
          border: InputBorder.none,
        ),
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontFamily: 'Courier New',
          fontSize: 14,
          color: theme.colorScheme.onSurface,
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
        // Copy tag to clipboard for reference
        Clipboard.setData(ClipboardData(text: tag));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copied $label tag to clipboard')),
        );
      },
    );
  }

  void _formatSsml() {
    // Only format in SSML Code mode
    if (_showPlainText) return;

    final controller = _isMultiSection
        ? _sectionSsmlControllers[_currentSection]!
        : _ssmlController;

    String formatted = controller.text;

    // Basic XML formatting - add newlines after major tags
    formatted = formatted
        .replaceAll('><', '>\n<')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    setState(() {
      if (_isMultiSection) {
        _sectionSsmlControllers[_currentSection]!.text = formatted;
      } else {
        _ssmlController.text = formatted;
      }
      _validateSsml();
    });
  }

  List<ButtonSegment<String>> _buildSectionSegments() {
    final sections = widget.sections!;
    return sections.keys.map((key) {
      IconData icon;
      switch (key) {
        case 'welcome':
          icon = Icons.waving_hand;
          break;
        case 'awayTeam':
          icon = Icons.flight_takeoff;
          break;
        case 'homeTeam':
          icon = Icons.home;
          break;
        default:
          icon = Icons.description;
      }
      return ButtonSegment<String>(
        value: key,
        label: Text(_getSectionDisplayName(key)),
        icon: Icon(icon, size: 18),
      );
    }).toList();
  }

  String _getSectionDisplayName(String key) {
    switch (key) {
      case 'welcome':
        return 'Welcome';
      case 'awayTeam':
        return 'Away Team';
      case 'homeTeam':
        return 'Home Team';
      default:
        return key;
    }
  }

  TextEditingController _getCurrentController() {
    if (_isMultiSection) {
      return _showPlainText
          ? _sectionPlainTextControllers[_currentSection]!
          : _sectionSsmlControllers[_currentSection]!;
    } else {
      return _showPlainText ? _plainTextController : _ssmlController;
    }
  }

  bool _shouldUsePregameContext() =>
      _isMultiSection && _currentSection == 'welcome';

  String _mapResultSymbol(int value) {
    switch (value) {
      case 6:
        return 'V';
      case 4:
        return 'O';
      default:
        return 'F';
    }
  }

  String _formatLastGames(List<int> games) {
    if (games.isEmpty) return 'saknas';
    return games.map(_mapResultSymbol).join('');
  }

  String _formatTrend(int? trend) {
    if (trend == null || trend == 0) return '0';
    return trend > 0 ? '+$trend' : '$trend';
  }

  String? _buildPregameContext(PregameStats? stats) {
    if (stats == null) return null;

    final homeName = stats.homeTeam.trim();
    final awayName = stats.awayTeam.trim();
    final hRank = stats.homeTeamRanking != null
        ? '#${stats.homeTeamRanking}'
        : 'okänd plats';
    final aRank = stats.awayTeamRanking != null
        ? '#${stats.awayTeamRanking}'
        : 'okänd plats';
    final lastMeeting =
        (stats.homeTeamGoalsLastMeeting != null &&
            stats.awayTeamGoalsLastMeeting != null)
        ? 'Senaste mötet ${stats.homeTeamGoalsLastMeeting}-${stats.awayTeamGoalsLastMeeting}'
        : null;
    final h2h =
        'Inbördes ${stats.homeTeamMeetingWins}-${stats.meetingDraws}-${stats.awayTeamMeetingWins} (H-O-B)';
    final homeForm =
        'Form $homeName: ${_formatLastGames(stats.homeTeamLastGames)}';
    final awayForm =
        'Form $awayName: ${_formatLastGames(stats.awayTeamLastGames)}';

    final parts = [
      'Match: $homeName mot $awayName',
      'Tabell: $hRank vs $aRank',
      h2h,
      if (lastMeeting != null) lastMeeting,
      homeForm,
      awayForm,
    ];
    return parts.join('. ');
  }

  Future<void> _enhanceWithAI() async {
    final controller = _getCurrentController();
    final currentText = controller.text.trim();

    if (currentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter some text first to enhance')),
      );
      return;
    }

    setState(() => _isEnhancing = true);

    try {
      final authService = ref.read(authServiceProvider);
      final aiService = AiSentenceService(authService);

      // Strip SSML tags if in SSML mode to get plain text for enhancement
      final plainText = _showPlainText
          ? currentText
          : _stripSsmlTags(currentText);

      final pregameContext = _shouldUsePregameContext()
          ? _buildPregameContext(ref.read(pregameStatsProvider))
          : null;

      final systemPrompt = _getSystemPrompt();
      final userPrompt = _buildEnhancePrompt(
        plainText,
        pregameContext: pregameContext,
      );

      final suggestions = await aiService.generateSentences(
        prompt: userPrompt,
        systemPrompt: systemPrompt,
        temperature: _getTemperature(),
        maxTokens: 5000,
      );

      if (suggestions.isNotEmpty && mounted) {
        final enhancedText = suggestions.first.trim();

        // Log the AI-generated text for debugging
        const Logger('SsmlPreviewDialog').d('AI Enhanced Text: $enhancedText');

        setState(() {
          if (_isMultiSection) {
            if (_showPlainText) {
              _sectionPlainTextControllers[_currentSection]!.text =
                  enhancedText;
            } else {
              final wrappedSsml = _wrapWithSsml(enhancedText);
              const Logger('SsmlPreviewDialog').d('Wrapped SSML: $wrappedSsml');
              _sectionSsmlControllers[_currentSection]!.text = wrappedSsml;
              _validateSsml();
            }
          } else {
            if (_showPlainText) {
              _plainTextController.text = enhancedText;
            } else {
              final wrappedSsml = _wrapWithSsml(enhancedText);
              const Logger('SsmlPreviewDialog').d('Wrapped SSML: $wrappedSsml');
              _ssmlController.text = wrappedSsml;
              _validateSsml();
            }
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enhanced'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI enhancement failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isEnhancing = false);
      }
    }
  }

  String _getSystemPrompt() {
    // New balanced system prompt (Swedish) - follow user's instructions exactly
    return '''
Du är en energisk och entusiastisk svensk sportkommentator för innebandy.
Din uppgift är att förbättra given text till en engagerande annonsering.

OBLIGATORISKA REGLER (får aldrig brytas):
- Max 2-5 meningar.
- Välkomsttexter ska vara inbjudande och uppmuntrande till motståndarlaget, domarna och publiken.
- Aldrig ändra siffror, tid, namn, tröjnummer eller resultat.
- Resultat måste alltid skrivas med svenska ord och kommatecken:
1-0 → ett, noll, | 2-1 → två, ett, | 3-3 → tre, tre,
- Använd kommatecken för pauser och punkt för meningsslut.
- Undvik bindestreck.
- Skriv endast ren text, inga SSML-taggar.
- Lägg aldrig till information som inte finns i input.
- Skriv alltid numret på spelaren före namnet och med ett kommatecken emellan.
- Använd alltid "nummer X" för tröjnummer (inte bara "X").
- Använd Pregame-info endast om det är relevant för texten.
- Analysera och använd Pregame-info för att lägga till kontext om lagens form, tabellposition eller inbördes möten.
- Analysera och presenterna Form: V för vinst, O för oavgjort, F för förlust .
- Analysera och presentera Inbördes möten: H-O-B (Vinst för Hemmalaget-Oavgjort-Bortalaget).
- Tabellposition: Använd "placerade X i tabellen" för att ange lagens nuvarande position. Aldrig t.ex. Nummer X , Lag X etc.
- derby-matcher: Betona extra mycket vid derbymatcher mellan rivaliserande lag.
- Använd lagets fullständiga namn vid presentation av Inbördes möten och tabellposition.
- Anpassa tonen efter matchens betydelse (t.ex. final vs. vanlig match).
- Lag och spelarpresentation: Använd alltid fullständiga namn och tröjnummer vid presentation av lag och spelare.
- Lag och spelarpresentation: Enast laginformation, ingen välkomstfras.

STIL:
- Energi, tempo och passion.
- Mediumlånga, tydliga meningar.
- Kraftfulla verb, men inga överdrivna metaforer.
- Anoonering av händelser ska vara snabba och spännande.
- Undvik klichéer och överanvända fraser.
''';
  }

  String _buildEnhancePrompt(String text, {String? pregameContext}) {
    final buffer = StringBuffer(
      'Förbättra följande text enligt systemreglerna: Originaltext: "$text".',
    );
    if (pregameContext != null && pregameContext.isNotEmpty) {
      buffer.write(
        ' Pregame-info (använd max en kort rad om tabellplats/form/inbördes mötes): $pregameContext.',
      );
    }
    return buffer.toString();
  }

  double _getTemperature() {
    return 0.5;
  }

  // Removed multiple style names; only balanced supported.
}
