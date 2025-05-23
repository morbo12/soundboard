// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:soundboard/features/screen_home/presentation/board/classes/class_button.dart';
// import 'package:soundboard/constants/globals.dart';
// import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';
// import 'package:soundboard/utils/logger.dart';

// class Row1Ratata extends ConsumerWidget {
//   const Row1Ratata({super.key});
//   final Logger logger = const Logger('Row1Ratata');

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Button to play 'RATATA' jingle
//         Button(
//           isSelected: true,
//           onTap: () {
//             // playJingle(audioSources.ratataFile);
//             logger.d(jingleManager.audioManager.audioInstances.first.filePath);

//             jingleManager.audioManager.playAudio(
//               AudioCategory.ratataJingle,
//               ref,
//             );
//           },
//           primaryText: 'RATATA',
//           secondaryText: 'N/A',
//         ),
//         const Gap(10),
//         // Button to play a random clap jingle
//         // Button(
//         //   isSelected: true,
//         //   noLines: 2,
//         //   onTap: () {
//         //     jingleManager.audioManager
//         //         .playAudio(AudioCategory.clapJingle, ref, random: true);
//         //   },
//         //   primaryText: 'KLAPPA\nHÄNDERNA',
//         //   secondaryText: 'N/A',
//         // ),
//         // const Gap(10),
//         // Button to play a random generic jingle
//         Button(
//           isSelected: true,
//           onTap: () {
//             jingleManager.audioManager.playAudio(
//               AudioCategory.genericJingle,
//               ref,
//               sequential: true,
//             );
//           },
//           primaryText: 'JINGLE',
//           secondaryText: '(sequential)',
//         ),
//         const Gap(10),

//         Button(
//           isSelected: true,
//           onTap: () {
//             jingleManager.audioManager.playAudio(
//               AudioCategory.genericJingle,
//               ref,
//               random: true,
//               shortFade: true,
//             );
//           },
//           primaryText: 'JINGLE',
//           secondaryText: '(random)',
//         ),
//       ],
//     );
//   }
// }
