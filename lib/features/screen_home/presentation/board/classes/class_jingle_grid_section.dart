import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/jingle_manager/application/class_static_audiofiles.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'class_draggable_jingle_button.dart';
import 'class_jingle_grid_config_notifier.dart';

class JingleGridSection extends ConsumerWidget {
  const JingleGridSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gridConfig = ref.watch(jingleGridConfigProvider);
    final (columns, rows) = ref.watch(gridSettingsProvider);

    return FutureBuilder<List<AudioFile>>(
      future: AudioConfigurations.getSpecialJingles(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final specialJingles = snapshot.data!;
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
    );
  }
}
