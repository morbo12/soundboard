// import 'package:flutter/widgets.dart';
// import 'package:soundboard/constants/default_constants.dart';

// class ScreenSizeUtil {
//   static double getWidth(BuildContext context,
//       {double maxWidth = double.infinity}) {
//     double screenWidth = MediaQuery.of(context).size.width;
//     return maxWidth != double.infinity
//         ? (screenWidth > maxWidth ? maxWidth : screenWidth)
//         : screenWidth;
//   }
// }

// class ContainerWidthCalculator {
//   static double calculateContainerWidth(BuildContext context) {
//     double screenWidth = ScreenSizeUtil.getWidth(context);
//     double calculatedWidth = screenWidth -
//         DefaultConstants().soundboardSize -
//         DefaultConstants().homeScreenDividerSize;

//     // Ensure minimum size of 250
//     double containerWidth = calculatedWidth > 250.0 ? calculatedWidth : 250.0;

//     // If the calculated width is greater than 500, set containerWidth to 40% of the calculated value
//     if (calculatedWidth > 500.0) {
//       containerWidth = 0.4 * calculatedWidth;
//     }

//     return containerWidth;
//   }
// }
