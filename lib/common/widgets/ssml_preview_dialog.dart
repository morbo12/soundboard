import 'package:flutter/material.dart';

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

class _SsmlPreviewDialogState extends State<SsmlPreviewDialog> {
  late TextEditingController _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialSsml);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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

    return Dialog(
      child: Container(
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'SSML Preview & Edit',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Review and edit the SSML before sending to TTS engine',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  expands: true,
                  decoration: InputDecoration(
                    hintText: 'Edit SSML content here...',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  style: const TextStyle(
                    fontFamily: 'Courier New',
                    fontSize: 13,
                  ),
                  enabled: !_isProcessing,
                ),
              ),
            ),
            const SizedBox(height: 20),
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
}
