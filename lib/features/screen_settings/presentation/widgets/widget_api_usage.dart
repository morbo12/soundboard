import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/api_usage.dart';
import 'package:soundboard/core/services/api_usage_service.dart';

class ApiUsageWidget extends ConsumerStatefulWidget {
  const ApiUsageWidget({super.key});

  @override
  ConsumerState<ApiUsageWidget> createState() => _ApiUsageWidgetState();
}

class _ApiUsageWidgetState extends ConsumerState<ApiUsageWidget> {
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsage();
  }

  Future<void> _fetchUsage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = ref.read(apiUsageServiceProvider);
      await service.fetchUsage();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load usage data';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usage = ref.watch(currentApiUsageProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'API Usage',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _isLoading ? null : _fetchUsage,
                  tooltip: 'Refresh usage data',
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              Center(
                child: Column(
                  children: [
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fetchUsage,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            else if (usage == null)
              const Center(child: Text('No usage data available'))
            else
              _buildUsageDetails(context, usage),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageDetails(BuildContext context, ApiUsageData usage) {
    final theme = Theme.of(context);
    final service = ref.read(apiUsageServiceProvider);
    final isApproaching = service.isApproachingLimit(usage);
    final hasExceeded = service.hasExceededLimit(usage);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasExceeded)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: theme.colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You have exceeded one or more usage limits',
                    style: TextStyle(color: theme.colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          )
        else if (isApproaching)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are approaching your usage limits (>80%)',
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        _buildUsageItem(
          context,
          'TTS Requests',
          usage.usage.ttsRequests,
          usage.limits.ttsRequestsPerMonth,
          usage.remaining.ttsRequests,
          Icons.record_voice_over,
        ),
        const Divider(),
        _buildUsageItem(
          context,
          'AI Requests',
          usage.usage.aiRequests,
          usage.limits.aiRequestsPerMonth,
          usage.remaining.aiRequests,
          Icons.psychology,
        ),
        const Divider(),
        _buildUsageItem(
          context,
          'Audio Minutes',
          usage.usage.audioMinutes,
          usage.limits.audioMinutesPerMonth,
          usage.remaining.audioMinutes,
          Icons.audiotrack,
          isMinutes: true,
        ),
        const SizedBox(height: 12),
        Text(
          'Resets: ${_formatDate(usage.resetsAt)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageItem(
    BuildContext context,
    String label,
    num used,
    num limit,
    num remaining,
    IconData icon, {
    bool isMinutes = false,
  }) {
    final theme = Theme.of(context);
    final percentage = (used / limit * 100).clamp(0.0, 100.0);
    final isExceeded = remaining <= 0;
    final isWarning = percentage > 80;

    Color getProgressColor() {
      if (isExceeded) return theme.colorScheme.error;
      if (isWarning) return Colors.orange;
      return theme.colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.onSurface),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
                  minHeight: 8,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: getProgressColor(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isMinutes
                    ? 'Used: ${used.toStringAsFixed(1)} min'
                    : 'Used: $used',
                style: theme.textTheme.bodySmall,
              ),
              Text(
                isMinutes
                    ? 'Remaining: ${remaining.toStringAsFixed(1)} min'
                    : 'Remaining: $remaining',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isExceeded
                      ? theme.colorScheme.error
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
