import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/core/utils/logger.dart';

class UploadButtonToDir extends ConsumerStatefulWidget {
  final String directoryName; // Updated to be more descriptive

  const UploadButtonToDir({
    super.key,
    required this.directoryName,
  }); // Updated constructor

  @override
  ConsumerState<UploadButtonToDir> createState() => UploadButtonToDirState();
}

class UploadButtonToDirState extends ConsumerState<UploadButtonToDir> {
  File? file;
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);
  final Logger logger = const Logger('UploadButtonToDir');

  Future<void> _copyFileToDestination(List<File>? files) async {
    if (files == null) return;

    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir = Directory(
      '${appSupportDir.path}/${widget.directoryName}',
    );

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    for (var sourceFile in files) {
      // final File sourceFile = File(file);
      final String targetPath = Platform.isWindows
          ? '${targetDir.path}/${sourceFile.path.split('\\').last}'
          : '${targetDir.path}/${sourceFile.path.split('/').last}';

      try {
        await sourceFile.copy(targetPath);
        logger.d("File copied to $targetPath");
      } catch (e) {
        logger.d("Failed to copy file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tmp_category = widget.directoryName == "GenericJingles"
        ? AudioCategory.genericJingle
        : widget.directoryName == "GoalJingles"
        ? AudioCategory.goalJingle
        : widget.directoryName == "ClapJingles"
        ? AudioCategory.clapJingle
        : widget.directoryName == "SpecialJingles"
        ? AudioCategory.specialJingle
        : widget.directoryName == "GoalHorn"
        ? AudioCategory.goalHorn
        : AudioCategory.specialJingle;

    final jingleManagerAsync = ref.watch(jingleManagerProvider);

    return jingleManagerAsync.when(
      data: (jingleManager) {
        final fileCount = jingleManager.audioManager.audioInstances
            .where((element) => element.audioCategory == tmp_category)
            .length;

        return _buildModernCard(
          context, 
          fileCount, 
          tmp_category,
          () => _handleUpload(tmp_category),
        );
      },
      loading: () => _buildModernCard(context, 0, tmp_category, null, isLoading: true),
      error: (error, stack) => _buildModernCard(context, 0, tmp_category, null, hasError: true),
    );
  }

  Widget _buildModernCard(BuildContext context, int fileCount, AudioCategory category, VoidCallback? onTap, {bool isLoading = false, bool hasError = false}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get category-specific styling
    final categoryInfo = _getCategoryInfo(category);
    
    String statusText = isLoading 
        ? "Loading..." 
        : hasError 
            ? "Error" 
            : "($fileCount files)";
    
    Color containerColor = hasError 
        ? colorScheme.errorContainer 
        : categoryInfo['containerColor'];

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                containerColor,
                containerColor.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: categoryInfo['iconColor'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryInfo['icon'],
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.directoryName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: hasError 
                            ? colorScheme.onErrorContainer
                            : categoryInfo['textColor'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${categoryInfo['description']} $statusText',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasError 
                            ? colorScheme.onErrorContainer.withAlpha(200)
                            : categoryInfo['textColor'].withAlpha(200),
                      ),
                    ),
                    if (!isLoading && !hasError) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildFeatureChip(context, 'Quick Upload'),
                          const SizedBox(width: 8),
                          _buildFeatureChip(context, 'Multi-Select'),
                          const SizedBox(width: 8),
                          _buildFeatureChip(context, 'Audio Files'),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!isLoading) ...[
                Icon(
                  hasError ? Icons.error : Icons.cloud_upload,
                  color: hasError 
                      ? colorScheme.onErrorContainer
                      : categoryInfo['textColor'],
                ),
              ] else ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo(AudioCategory category) {
    final colorScheme = Theme.of(context).colorScheme;
    
    switch (category) {
      case AudioCategory.goalJingle:
        return {
          'icon': Icons.sports_soccer,
          'iconColor': const Color(0xFF4CAF50), // Green for goals
          'containerColor': Color.alphaBlend(
            const Color(0xFF4CAF50).withAlpha(80),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Upload goal celebration sounds',
        };
      case AudioCategory.clapJingle:
        return {
          'icon': Icons.front_hand,
          'iconColor': const Color(0xFF2196F3), // Blue for clap
          'containerColor': Color.alphaBlend(
            const Color(0xFF2196F3).withAlpha(80),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Upload crowd clapping sounds',
        };
      case AudioCategory.specialJingle:
        return {
          'icon': Icons.star,
          'iconColor': const Color(0xFFE6B422), // Yellow/Gold for special
          'containerColor': Color.alphaBlend(
            const Color(0xFFE6B422).withAlpha(80),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Upload special event sounds',
        };
      case AudioCategory.goalHorn:
        return {
          'icon': Icons.campaign,
          'iconColor': const Color(0xFFFF5722), // Red/Orange for horn
          'containerColor': Color.alphaBlend(
            const Color(0xFFFF5722).withAlpha(80),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Upload air horn celebrations',
        };
      case AudioCategory.genericJingle:
        return {
          'icon': Icons.music_note,
          'iconColor': const Color(0xFF9C27B0), // Purple for generic
          'containerColor': Color.alphaBlend(
            const Color(0xFF9C27B0).withAlpha(80),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Upload generic jingle sounds',
        };
      default:
        return {
          'icon': Icons.upload_file,
          'iconColor': colorScheme.primary,
          'containerColor': colorScheme.secondaryContainer,
          'textColor': colorScheme.onSecondaryContainer,
          'description': 'Upload audio files',
        };
    }
  }

  Widget _buildFeatureChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleUpload(AudioCategory category) async {
    pickFile(
      allowedExtensions: Platform.isWindows
          ? ['mp3', 'flac']
          : ['mp3', 'flac', 'ogg'],
      allowMultiple: true,
      onMultipleFilesSelected: (files) async {
        if (!mounted) return;

        logger.d("VALUE: $files");

        // Copy the files to destination
        await _copyFileToDestination(files);

        ref.read(jingleManagerProvider.notifier).reinitialize();
      },
      onError: (errorMessage) {
        // Handle error, maybe show a snackbar
      },
      onCancelled: () {
        // Handle cancellation if needed
      },
    );
  }
}
