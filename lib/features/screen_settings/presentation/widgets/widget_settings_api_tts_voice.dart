import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/providers/auth_providers.dart';
import 'package:soundboard/core/utils/logger.dart';

class SettingsApiTtsVoice extends ConsumerStatefulWidget {
  const SettingsApiTtsVoice({super.key});

  @override
  ConsumerState<SettingsApiTtsVoice> createState() =>
      _SettingsApiTtsVoiceState();
}

class _SettingsApiTtsVoiceState extends ConsumerState<SettingsApiTtsVoice> {
  final Logger logger = const Logger('SettingsApiTtsVoice');

  @override
  Widget build(BuildContext context) {
    final settings = SettingsBox();
    final currentVoice = settings.azVoiceName;

    logger.d("Current API Voice: $currentVoice");

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showVoicePicker(context, ref, currentVoice),
            child: AutoSizeText(
              currentVoice.isNotEmpty ? currentVoice : "Select Voice",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }

  void _showVoicePicker(
    BuildContext context,
    WidgetRef ref,
    String currentVoice,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Select API Voice",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Voice list from API
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final voicesAsync = ref.watch(apiVoicesProvider);

                    return voicesAsync.when(
                      data: (voices) {
                        if (voices == null || voices.isEmpty) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.voice_over_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No voices available.\nPlease check your API connection.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          itemCount: voices.length,
                          itemBuilder: (context, index) {
                            final voice = voices[index];
                            final isSelected = voice == currentVoice;

                            return ListTile(
                              title: Text(voice),
                              subtitle: _getVoiceDescription(voice),
                              leading: Icon(
                                Icons.record_voice_over,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey,
                              ),
                              trailing: isSelected
                                  ? Icon(
                                      Icons.check_circle,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    )
                                  : null,
                              selected: isSelected,
                              selectedTileColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              onTap: () {
                                // Update the selected voice
                                final settings = SettingsBox();
                                settings.azVoiceName = voice;

                                logger.i("Voice updated to: $voice");

                                // Show success message
                                FlutterToastr.show(
                                  "Voice updated: $voice",
                                  context,
                                  duration: FlutterToastr.lengthLong,
                                  position: FlutterToastr.bottom,
                                  backgroundColor: Colors.green,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                  ),
                                );

                                // Close the bottom sheet
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      loading: () => const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Loading voices from API...'),
                          ],
                        ),
                      ),
                      error: (error, stackTrace) {
                        logger.e('Error loading voices: $error', stackTrace);
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading voices:\n$error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  ref.invalidate(apiVoicesProvider);
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Refresh button
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.invalidate(apiVoicesProvider);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Voices'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget? _getVoiceDescription(String voiceName) {
    // Extract language and gender info from voice name if possible
    if (voiceName.contains('sv-SE')) {
      return const Text(
        'Swedish',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    } else if (voiceName.contains('en-US')) {
      return const Text(
        'English (US)',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    } else if (voiceName.contains('en-GB')) {
      return const Text(
        'English (UK)',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    } else if (voiceName.contains('Neural')) {
      return const Text(
        'Neural Voice',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      );
    }
    return null;
  }
}

// Contains AI-generated edits.
