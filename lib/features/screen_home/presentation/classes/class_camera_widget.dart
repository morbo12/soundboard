// import 'dart:async';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:camera_platform_interface/camera_platform_interface.dart';

// class FloatingCameraWindow extends StatefulWidget {
//   const FloatingCameraWindow({Key? key}) : super(key: key);

//   @override
//   _FloatingCameraWindowState createState() => _FloatingCameraWindowState();
// }

// class _FloatingCameraWindowState extends State<FloatingCameraWindow> {
//   // CameraController? _controller;
//   bool _isInitialized = false;
//   Offset _position = Offset(20, 20);
//   Timer? _timer;
//   String _recognizedText = '';
//   late CameraController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await CameraPlatform.instance.availableCameras();
//     if (cameras.isNotEmpty) {
//       _controller = CameraController(cameras[0], ResolutionPreset.medium);
//       try {
//         await _controller.initialize();
//         setState(() {
//           _isInitialized = true;
//         });
//         // _startImageProcessing();
//       } catch (e) {
//         print('Error initializing camera: $e');
//       }
//     } else {
//       print('No cameras available');
//     }
//   }

//   // void _startImageProcessing() {
//   //   _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
//   //     print("Processing image...");
//   //     _processImage();
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {
//     if (!_isInitialized) {
//       return Container(
//         color: Colors.black,
//         child: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Positioned(
//       left: _position.dx,
//       top: _position.dy,
//       child: Draggable(
//         feedback: _buildCameraPreview(),
//         childWhenDragging: Container(),
//         onDragEnd: (details) {
//           setState(() {
//             _position = details.offset;
//           });
//         },
//         child: Column(
//           children: [
//             _buildCameraPreview(),
//             Container(
//               width: 200,
//               padding: EdgeInsets.all(8),
//               color: Colors.black.withValues(alpha: 0.7),
//               child: Text(
//                 'Recognized: $_recognizedText',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCameraPreview() {
//     return Container(
//       width: 200,
//       height: 150,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.white, width: 2),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(6),
//         child: Transform.scale(
//           scaleX: -1, // This will mirror the image horizontally
//           child: CameraPreview(_controller),
//         ),
//       ),
//     );
//   }
// }
