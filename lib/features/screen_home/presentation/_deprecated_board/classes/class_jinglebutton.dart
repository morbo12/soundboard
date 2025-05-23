// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:soundboard/constants/globals.dart';
// import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
// import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';

// class JingleButton extends ConsumerStatefulWidget {
//   final String primaryText;
//   final ButtonStyle? style;
//   final int? noLines;
//   final AudioCategory jingleCategory;

//   const JingleButton({
//     super.key,
//     required this.primaryText,
//     required this.jingleCategory,
//     this.style,
//     this.noLines,
//   });

//   @override
//   ConsumerState<JingleButton> createState() => JingleButtonState();
// }

// class JingleButtonState extends ConsumerState<JingleButton> {
//   AudioFile? selectedJingle;

//   Future<void> _showJinglePicker() async {
//     // Get jingles of the specified category
//     List<AudioFile> availableJingles =
//         jingleManager.audioManager.audioInstances
//             .where((audio) => audio.audioCategory == widget.jingleCategory)
//             .toList();

//     selectedJingle = await showDialog<AudioFile>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Select Jingle'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (availableJingles.isEmpty)
//                   const Padding(
//                     padding: EdgeInsets.all(16.0),
//                     child: Text('No jingles available for this category'),
//                   )
//                 else
//                   ...availableJingles.map(
//                     (jingle) => ListTile(
//                       leading: const Icon(Icons.music_note),
//                       title: Text(
//                         jingle.displayName.isNotEmpty
//                             ? jingle.displayName
//                             : jingle.filePath.split('/').last,
//                       ),
//                       onTap: () {
//                         setState(() {
//                           Navigator.of(context).pop(jingle);
//                         });
//                       },
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _playJingle() async {
//     if (selectedJingle != null) {
//       jingleManager.audioManager.playAudioFile(selectedJingle!, ref);
//     }
//   }

//   void _handleTap() {
//     if (selectedJingle == null) {
//       _showJinglePicker();
//     } else {
//       _playJingle();
//     }
//   }

//   void _handleLongPress() {
//     if (selectedJingle != null) {
//       _showJinglePicker();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     ButtonStyle? buttonStyle;
//     ButtonStyle normalbuttonStyle = TextButton.styleFrom(
//       foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
//       backgroundColor: Theme.of(context).colorScheme.surface,
//       // fixedSize: const Size.fromHeight(100),
//       minimumSize: const Size(0, 200),
//       textStyle: const TextStyle(fontSize: 24),
//     );
//     ButtonStyle selectedButtonStyle = normalbuttonStyle.copyWith(
//       backgroundColor: WidgetStateProperty.all<Color>(
//         Theme.of(context).colorScheme.primaryContainer,
//       ),
//       foregroundColor: WidgetStateProperty.all<Color>(
//         Theme.of(context).colorScheme.onPrimaryContainer,
//       ),
//     );

//     buttonStyle = selectedButtonStyle;

//     return Expanded(
//       child: TextButton(
//         onPressed: _handleTap,
//         onLongPress: _handleLongPress,
//         style: buttonStyle,
//         child: FittedBox(
//           fit: BoxFit.scaleDown,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               AutoSizeText(
//                 (selectedJingle?.displayName ?? widget.primaryText).replaceAll(
//                   ' - ',
//                   '\n',
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 minFontSize: 12,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
