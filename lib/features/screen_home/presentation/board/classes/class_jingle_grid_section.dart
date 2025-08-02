import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import '../../../../../common/widgets/class_draggable_jingle_button.dart';
import 'class_jingle_grid_config_notifier.dart';

class JingleGridSection extends ConsumerWidget {
  const JingleGridSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridConfig = ref.watch(jingleGridConfigProvider);
    final (columns, rows) = ref.watch(gridSettingsProvider);
    final jingleManagerAsync = ref.watch(jingleManagerProvider);

    return jingleManagerAsync.when(
      data: (jingleManager) {
        // Get special jingles from the jingle manager
        final specialJingles = jingleManager.audioManager.audioInstances
            .where(
              (audio) => audio.audioCategory == AudioCategory.specialJingle,
            )
            .toList();

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: rows * columns,
          itemBuilder: (context, index) {
            final audioFile = gridConfig[index];
            return DraggableJingleButton(
              index: index,
              audioFile: audioFile,
              specialJingles: specialJingles,
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading jingle manager: $error')),
    );
  }
}
