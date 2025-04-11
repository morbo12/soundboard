// import 'package:flutter/material.dart';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'package:gap/gap.dart';
// import 'package:soundboard/constants/default_constants.dart';
// import 'package:soundboard/properties.dart';

// class SerialPortSettings extends StatefulWidget {
//   const SerialPortSettings({super.key});

//   @override
//   State<SerialPortSettings> createState() => _SerialPortSettingsState();
// }

// class _SerialPortSettingsState extends State<SerialPortSettings> {
//   List<String> availablePorts = [];
//   List<int> baudRates = [9600, 19200, 38400, 57600, 115200];
//   List<int> dataBits = [5, 6, 7, 8];
//   List<int> stopBits = [1, 2];
//   List<String> parityOptions = ['None', 'Odd', 'Even', 'Mark', 'Space'];

//   @override
//   void initState() {
//     super.initState();
//     _refreshPortList();
//   }

//   void _refreshPortList() {
//     setState(() {
//       availablePorts = SerialPort.availablePorts;
//     });
//   }

//   int _getParityValue(String parity) {
//     switch (parity) {
//       case 'None':
//         return 0;
//       case 'Odd':
//         return 1;
//       case 'Even':
//         return 2;
//       case 'Mark':
//         return 3;
//       case 'Space':
//         return 4;
//       default:
//         return 0;
//     }
//   }

//   String _getParityString(int parity) {
//     switch (parity) {
//       case 0:
//         return 'None';
//       case 1:
//         return 'Odd';
//       case 2:
//         return 'Even';
//       case 3:
//         return 'Mark';
//       case 4:
//         return 'Space';
//       default:
//         return 'None';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Port Selection Card
//         Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Serial Port',
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.refresh),
//                       onPressed: _refreshPortList,
//                       tooltip: 'Refresh Port List',
//                     ),
//                   ],
//                 ),
//                 const Gap(8),
//                 Container(
//                   width: double.infinity,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Theme.of(context).dividerColor),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: DropdownButtonHideUnderline(
//                     child: DropdownButton<String>(
//                       value:
//                           availablePorts.contains(SettingsBox().serialPortName)
//                               ? SettingsBox().serialPortName
//                               : null,
//                       hint: const Text('Select Port'),
//                       isExpanded: true,
//                       icon: const Icon(Icons.arrow_drop_down),
//                       onChanged: (String? newValue) {
//                         if (newValue != null) {
//                           SettingsBox().serialPortName = newValue;
//                           setState(() {});
//                         }
//                       },
//                       items:
//                           availablePorts.map<DropdownMenuItem<String>>((
//                             String value,
//                           ) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                     ),
//                   ),
//                 ),
//                 const Gap(10),
//                 // Auto Connect option
//                 SwitchListTile(
//                   title: const Text('Auto Connect on Startup'),
//                   subtitle: const Text(
//                     'Automatically connect when the app starts',
//                   ),
//                   value: SettingsBox().serialAutoConnect,
//                   contentPadding: EdgeInsets.zero,
//                   onChanged: (value) {
//                     SettingsBox().serialAutoConnect = value;
//                     setState(() {});
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),

//         // Connection Settings Card
//         Card(
//           elevation: 2,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Connection Settings',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const Gap(16),

//                 // Baud Rate
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Baud Rate:',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Theme.of(context).dividerColor,
//                         ),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<int>(
//                           value: SettingsBox().serialBaudRate,
//                           onChanged: (int? newValue) {
//                             if (newValue != null) {
//                               SettingsBox().serialBaudRate = newValue;
//                               setState(() {});
//                             }
//                           },
//                           items:
//                               baudRates.map<DropdownMenuItem<int>>((int value) {
//                                 return DropdownMenuItem<int>(
//                                   value: value,
//                                   child: Text(value.toString()),
//                                 );
//                               }).toList(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const Gap(12),

//                 // Data Bits
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Data Bits:',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Theme.of(context).dividerColor,
//                         ),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<int>(
//                           value: SettingsBox().serialDataBits,
//                           onChanged: (int? newValue) {
//                             if (newValue != null) {
//                               SettingsBox().serialDataBits = newValue;
//                               setState(() {});
//                             }
//                           },
//                           items:
//                               dataBits.map<DropdownMenuItem<int>>((int value) {
//                                 return DropdownMenuItem<int>(
//                                   value: value,
//                                   child: Text(value.toString()),
//                                 );
//                               }).toList(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const Gap(12),

//                 // Stop Bits
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Stop Bits:',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Theme.of(context).dividerColor,
//                         ),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<int>(
//                           value: SettingsBox().serialStopBits,
//                           onChanged: (int? newValue) {
//                             if (newValue != null) {
//                               SettingsBox().serialStopBits = newValue;
//                               setState(() {});
//                             }
//                           },
//                           items:
//                               stopBits.map<DropdownMenuItem<int>>((int value) {
//                                 return DropdownMenuItem<int>(
//                                   value: value,
//                                   child: Text(value.toString()),
//                                 );
//                               }).toList(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const Gap(12),

//                 // Parity
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       'Parity:',
//                       style: Theme.of(context).textTheme.bodyLarge,
//                     ),
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 4,
//                       ),
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: Theme.of(context).dividerColor,
//                         ),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _getParityString(SettingsBox().serialParity),
//                           onChanged: (String? newValue) {
//                             if (newValue != null) {
//                               SettingsBox().serialParity = _getParityValue(
//                                 newValue,
//                               );
//                               setState(() {});
//                             }
//                           },
//                           items:
//                               parityOptions.map<DropdownMenuItem<String>>((
//                                 String value,
//                               ) {
//                                 return DropdownMenuItem<String>(
//                                   value: value,
//                                   child: Text(value),
//                                 );
//                               }).toList(),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
