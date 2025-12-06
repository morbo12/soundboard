import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/models/ai_model.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/services/ai_models_service.dart';
import 'package:soundboard/core/providers/auth_providers.dart';
import 'package:soundboard/core/utils/logger.dart';

final _aiModelsProvider = FutureProvider.autoDispose<List<AiModel>>((
  ref,
) async {
  final authService = ref.read(authServiceProvider);
  final modelsService = AiModelsService(authService);
  return modelsService.fetchModels();
});

/// Widget for selecting the AI model to use for sentence generation.
///
/// This widget displays a dropdown of available AI models fetched from the
/// Soundboard API. It is only visible when an API product key is configured.
class AiModelSelector extends ConsumerWidget {
  static const Logger _logger = Logger('AiModelSelector');
  final SettingsBox _settings = SettingsBox();

  AiModelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check if API key is configured
    if (_settings.apiProductKey.trim().isEmpty) {
      return const _NoApiKeyWarning();
    }

    final modelsAsync = ref.watch(_aiModelsProvider);

    return modelsAsync.when(
      loading: () => const _LoadingIndicator(),
      error: (error, stack) {
        _logger.e('Error loading AI models: $error', stack);
        return _ErrorDisplay(error: error);
      },
      data: (models) {
        if (models.isEmpty) {
          return const _NoModelsAvailable();
        }

        final currentModel = _settings.aiModel;
        // Ensure current model is in the list, otherwise use first model
        final selectedModel = models.any((m) => m.id == currentModel)
            ? currentModel
            : models.first.id;

        // Update setting if current model is not in list
        if (selectedModel != currentModel) {
          _settings.aiModel = selectedModel;
        }

        return _ModelDropdown(
          models: models,
          selectedModelId: selectedModel,
          onChanged: (modelId) {
            if (modelId != null) {
              _settings.aiModel = modelId;
              _logger.i('AI model changed to: $modelId');
            }
          },
        );
      },
    );
  }
}

class _ModelDropdown extends StatelessWidget {
  final List<AiModel> models;
  final String selectedModelId;
  final ValueChanged<String?> onChanged;

  const _ModelDropdown({
    required this.models,
    required this.selectedModelId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: selectedModelId,
          decoration: InputDecoration(
            labelText: 'AI Model',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: models.map((model) {
            return DropdownMenuItem(value: model.id, child: Text(model.name));
          }).toList(),
          onChanged: onChanged,
        ),
        const Gap(8),
        _ModelDescription(
          model: models.firstWhere((m) => m.id == selectedModelId),
        ),
      ],
    );
  }
}

class _ModelDescription extends StatelessWidget {
  final AiModel model;

  const _ModelDescription({required this.model});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.description,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(4),
          Wrap(
            spacing: 8,
            children: [
              _InfoChip(
                label: 'Type: ${model.type}',
                icon: Icons.category_outlined,
              ),
              if (model.supportsTemperature)
                const _InfoChip(
                  label: 'Temperature control',
                  icon: Icons.thermostat_outlined,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      avatar: Icon(icon, size: 14),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        Gap(12),
        Text('Loading AI models...'),
      ],
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final Object error;

  const _ErrorDisplay({required this.error});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              'Failed to load AI models: $error',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoModelsAvailable extends StatelessWidget {
  const _NoModelsAvailable();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              'No AI models available. Please check your API configuration.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoApiKeyWarning extends StatelessWidget {
  const _NoApiKeyWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_outlined,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
          const Gap(12),
          Expanded(
            child: Text(
              'AI features require an API product key. Please configure your API settings.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
