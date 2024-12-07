// import 'dart:io';
// import 'dart:async';

// import 'package:archive/archive_io.dart';
// import 'package:filepicker_windows/filepicker_windows.dart';
// // import 'package:file_picker/file_picker.dart';
// import 'package:filesystem_picker/filesystem_picker.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_material_pickers/flutter_material_pickers.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:soundboard/common_widgets/button.dart';

// class UploadButton extends StatefulWidget {
//   const UploadButton({super.key, required type});

//   @override
//   UploadButtonState createState() => UploadButtonState();
// }

// class UploadButtonState extends State<UploadButton> {
//   File? file;
//   final ValueNotifier<String?> selectedPath = ValueNotifier(null);

//   Future<void> _unzipFile({required String? file}) async {
//     final appSupportDir = await getApplicationCacheDirectory();

//     if (kDebugMode) {
//       print("Extracting files to $appSupportDir");
//     }
//     try {
//       await extractFileToDisk(file!, appSupportDir.path);
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }

//   Future<void> _pickFile(BuildContext context) async {
//     selectedPath.value = null;

//     if (context.mounted) {
//       // final path = OpenFilePicker()
//       //   ..filterSpecification = {
//       //     'Zip Files (*.zip)': '*.zip',
//       //     'All Files': '*.*'
//       //   }
//       //   ..defaultExtension = 'zip';
//       // final result = path.getFile();
//       showMaterialFilePicker(
//         context: context,
//         fileType: FileType.custom,
//         allowedExtensions: ['zip'],
//         onChanged: (value) {
//           selectedPath.value = value.name;
//           print("VALUE: ${value.name}");
//         },
//       );
//       if (kDebugMode) {
//         print(selectedPath.value);
//       }
//       // selectedPath.value = result?.path;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Button(
//           noLines: 1,
//           isSelected: true,
//           onTap: () {
//             Permission.storage.request().isGranted.then((isGranted) {
//               if (isGranted) {
//                 // Invoke the file picker UI function
//                 showMaterialFilePicker(
//                   context: context,
//                   fileType: FileType.custom,
//                   allowedExtensions: ['zip'],
//                   onChanged: (value) {
//                     // Check if mounted is needed here, depends on what showMaterialFilePicker does
//                     if (!mounted) return;
//                     selectedPath.value = value.path;
//                     if (kDebugMode) {
//                       print("VALUE: ${value.path}");
//                     }
//                     _unzipFile(file: selectedPath.value);
//                   },
//                 );
//               } else {
//                 // Permissions not granted, handle accordingly
//                 if (kDebugMode) {
//                   print("Storage permission was denied.");
//                 }
//               }
//             }).catchError((error) {
//               // Handle any errors thrown during the permission request
//               if (kDebugMode) {
//                 print("An error occurred while requesting permissions: $error");
//               }
//             });
//           },

//           // onTap: () async {
//           //   final filePath = (await FilesystemPicker.open(
//           //     title: "Pick zip file",
//           //     context: context,
//           //     fsType: FilesystemType.file,
//           //     allowedExtensions: ["zip"],
//           //     requestPermission: () async =>
//           //         await Permission.storage.request().isGranted,
//           //   ))
//           //       ?.files
//           //       .first;
//           //   if (kDebugMode) {
//           //     print('FILE DOWNLOADED TO PATH: "${filePath?.path}"');
//           //   }
//           //   if (filePath != null) {
//           //     _unzipFile(file: filePath);
//           //   }
//           // },
//           secondaryText: 'N/A',
//           primaryText: "Upload Jingles",
//         ),
//       ],
//     );
//   }
// }
