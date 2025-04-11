// import 'package:flutter/material.dart';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'package:gap/gap.dart';
// import 'package:soundboard/constants/default_constants.dart';
// import 'package:soundboard/properties.dart';

// class SerialPortSettingsTabbed extends StatefulWidget {
//   const SerialPortSettingsTabbed({super.key});

//   @override
//   State<SerialPortSettingsTabbed> createState() =>
//       _SerialPortSettingsTabbedState();
// }

// class _SerialPortSettingsTabbedState extends State<SerialPortSettingsTabbed>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   List<String> availablePorts = [];
//   List<int> baudRates = [9600, 19200, 38400, 57600, 115200];
//   List<int> dataBits = [5, 6, 7, 8];
//   List<int> stopBits = [1, 2];
//   List<String> parityOptions = ['None', 'Odd', 'Even', 'Mark', 'Space'];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _refreshPortList();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
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
//         // Tab bar
//         Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.surfaceVariant,
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: TabBar(
//             controller: _tabController,
//             tabs: const [
//               Tab(text: 'Port Selection'),
//               Tab(text: 'Connection Settings'),
//             ],
//             labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
//             dividerColor: Colors.transparent,
//             indicator: BoxDecoration(
//               borderRadius: BorderRadius.circular(8),
//               color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
//             ),
//           ),
//         ),

//         const Gap(16),

//         // Tab content
//         SizedBox(
//           height: 260, // Fixed height for content area
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               // Port Selection Tab
//               Card(
//                 elevation: 1,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Available Ports',
//                             style: Theme.of(context).textTheme.titleMedium
//                                 ?.copyWith(fontWeight: FontWeight.bold),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.refresh),
//                             onPressed: _refreshPortList,
//                             tooltip: 'Refresh Port List',
//                           ),
//                         ],
//                       ),

//                       const Gap(16),

//                       if (availablePorts.isEmpty)
//                         Center(
//                           child: Column(
//                             children: [
//                               Icon(
//                                 Icons.warning_amber_rounded,
//                                 color: Theme.of(context).colorScheme.error,
//                                 size: 48,
//                               ),
//                               const Gap(8),
//                               Text(
//                                 'No serial ports detected',
//                                 style: Theme.of(context).textTheme.bodyLarge,
//                               ),
//                               const Gap(4),
//                               Text(
//                                 'Connect your Deej device and press refresh',
//                                 style: Theme.of(context).textTheme.bodySmall,
//                               ),
//                             ],
//                           ),
//                         )
//                       else
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: availablePorts.length,
//                             itemBuilder: (context, index) {
//                               final port = availablePorts[index];
//                               final isSelected =
//                                   port == SettingsBox().serialPortName;

//                               return ListTile(
//                                 title: Text(port),
//                                 selected: isSelected,
//                                 selectedTileColor:
//                                     Theme.of(
//                                       context,
//                                     ).colorScheme.primaryContainer,
//                                 leading: Icon(
//                                   Icons.usb,
//                                   color:
//                                       isSelected
//                                           ? Theme.of(
//                                             context,
//                                           ).colorScheme.primary
//                                           : Theme.of(
//                                             context,
//                                           ).colorScheme.onSurfaceVariant,
//                                 ),
//                                 onTap: () {
//                                   SettingsBox().serialPortName = port;
//                                   setState(() {});
//                                 },
//                               );
//                             },
//                           ),
//                         ),

//                       const Gap(8),

//                       SwitchListTile(
//                         title: const Text('Auto Connect on Startup'),
//                         value: SettingsBox().serialAutoConnect,
//                         contentPadding: EdgeInsets.zero,
//                         onChanged: (value) {
//                           SettingsBox().serialAutoConnect = value;
//                           setState(() {});
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               // Connection Settings Tab
//               Card(
//                 elevation: 1,
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Text(
//                         'Serial Connection Parameters',
//                         style: Theme.of(context).textTheme.titleMedium
//                             ?.copyWith(fontWeight: FontWeight.bold),
//                         textAlign: TextAlign.center,
//                       ),

//                       const Gap(24),

//                       // Baud Rate Setting
//                       _buildSettingTile(
//                         icon: Icons.speed,
//                         title: 'Baud Rate',
//                         value: SettingsBox().serialBaudRate.toString(),
//                         onTap: () {
//                           _showNumberPicker(
//                             title: 'Select Baud Rate',
//                             options: baudRates,
//                             selectedValue: SettingsBox().serialBaudRate,
//                             onSelect: (value) {
//                               SettingsBox().serialBaudRate = value;
//                               setState(() {});
//                             },
//                           );
//                         },
//                       ),

//                       const Divider(),

//                       // Data Bits Setting
//                       _buildSettingTile(
//                         icon: Icons.data_array,
//                         title: 'Data Bits',
//                         value: SettingsBox().serialDataBits.toString(),
//                         onTap: () {
//                           _showNumberPicker(
//                             title: 'Select Data Bits',
//                             options: dataBits,
//                             selectedValue: SettingsBox().serialDataBits,
//                             onSelect: (value) {
//                               SettingsBox().serialDataBits = value;
//                               setState(() {});
//                             },
//                           );
//                         },
//                       ),

//                       const Divider(),

//                       // Stop Bits Setting
//                       _buildSettingTile(
//                         icon: Icons.stop_circle,
//                         title: 'Stop Bits',
//                         value: SettingsBox().serialStopBits.toString(),
//                         onTap: () {
//                           _showNumberPicker(
//                             title: 'Select Stop Bits',
//                             options: stopBits,
//                             selectedValue: SettingsBox().serialStopBits,
//                             onSelect: (value) {
//                               SettingsBox().serialStopBits = value;
//                               setState(() {});
//                             },
//                           );
//                         },
//                       ),

//                       const Divider(),

//                       // Parity Setting
//                       _buildSettingTile(
//                         icon: Icons.grid_3x3,
//                         title: 'Parity',
//                         value: _getParityString(SettingsBox().serialParity),
//                         onTap: () {
//                           _showStringPicker(
//                             title: 'Select Parity',
//                             options: parityOptions,
//                             selectedValue: _getParityString(
//                               SettingsBox().serialParity,
//                             ),
//                             onSelect: (value) {
//                               SettingsBox().serialParity = _getParityValue(
//                                 value,
//                               );
//                               setState(() {});
//                             },
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildSettingTile({
//     required IconData icon,
//     required String title,
//     required String value,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       trailing: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             value,
//             style: TextStyle(
//               color: Theme.of(context).colorScheme.primary,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const Icon(Icons.arrow_forward_ios, size: 16),
//         ],
//       ),
//       contentPadding: EdgeInsets.zero,
//       onTap: onTap,
//     );
//   }

//   void _showNumberPicker({
//     required String title,
//     required List<int> options,
//     required int selectedValue,
//     required Function(int) onSelect,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(title, style: Theme.of(context).textTheme.titleLarge),
//             ),
//             const Divider(),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: options.length,
//                 itemBuilder: (context, index) {
//                   final value = options[index];
//                   final isSelected = value == selectedValue;

//                   return ListTile(
//                     title: Text(value.toString()),
//                     selected: isSelected,
//                     selectedTileColor:
//                         Theme.of(context).colorScheme.primaryContainer,
//                     trailing: isSelected ? const Icon(Icons.check) : null,
//                     onTap: () {
//                       onSelect(value);
//                       Navigator.pop(context);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showStringPicker({
//     required String title,
//     required List<String> options,
//     required String selectedValue,
//     required Function(String) onSelect,
//   }) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Text(title, style: Theme.of(context).textTheme.titleLarge),
//             ),
//             const Divider(),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: options.length,
//                 itemBuilder: (context, index) {
//                   final value = options[index];
//                   final isSelected = value == selectedValue;

//                   return ListTile(
//                     title: Text(value),
//                     selected: isSelected,
//                     selectedTileColor:
//                         Theme.of(context).colorScheme.primaryContainer,
//                     trailing: isSelected ? const Icon(Icons.check) : null,
//                     onTap: () {
//                       onSelect(value);
//                       Navigator.pop(context);
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
