// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:gap/gap.dart';
// import 'package:soundboard/features/screen_home/presentation/board/classes/class_button.dart';
// import 'package:soundboard/constants/globals.dart';
// import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';

// class Row2lineup extends ConsumerWidget {
//   const Row2lineup({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Button(
//           isSelected: true,
//           noLines: 2,
//           onTap: () {
//             jingleManager.audioManager.playAudio(
//               AudioCategory.clapJingle,
//               ref,
//               random: true,
//             );
//           },
//           primaryText: 'KLAPPA\nHÄNDERNA',
//           secondaryText: 'N/A',
//         ),
//         const Gap(10),
//         // Button to play the 'Värdegrund' audio
//         Button(
//           noLines: 1,
//           isSelected: true,
//           // isDisabled: false,
//           onTap: () {
//             jingleManager.audioManager.playAudio(
//               AudioCategory.powerupJingle,
//               ref,
//             );
//           },
//           primaryText: 'Fulltalig',
//           secondaryText: 'N/A',
//         ),
//         const Gap(10),
//         Button(
//           noLines: 1,
//           isSelected: true,
//           // isDisabled: false,
//           onTap: () {
//             jingleManager.audioManager.playAudio(
//               AudioCategory.penaltyJingle,
//               ref,
//             );
//           },
//           primaryText: 'Utvisning',
//           secondaryText: 'N/A',
//         ),
//       ],
//     );
//   }
// }
