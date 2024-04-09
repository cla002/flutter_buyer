import 'package:flutter/material.dart';

class GlobalStyles {
  // Define colors (Property)
  static Color green = Colors.green.shade400;
  static Color textColor = Colors.grey.shade700;

  //Get the screen size (Method)
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  //Calculate and Adjusted the sizes based on the screen size (Method)
  static double imageSize(BuildContext context) => screenWidth(context) * 0.7;
  static double titleFontSize(BuildContext context) =>
      screenWidth(context) * 0.05;
  static double inputFontSize(BuildContext context) =>
      screenWidth(context) * 0.04;
  static double buttonHeight(BuildContext context) =>
      screenHeight(context) * 0.07;
  static double buttonFontSize(BuildContext context) =>
      screenWidth(context) * 0.05;
}
