import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppTheme {
  static var latoBold = "Lato_Bold";
  static var latoLight = "Lato_Light";
  static var latoRegular = "Lato_Regular";

  static var primaryColor = Color(0XFF8077F5);
  static var staffPrimaryColor = Color(0XFF6459CC);

  static var secondaryColor = Color(0xFFF2F1FE);
  static var backgroundColor = Color(0xFF020015);
  static var greyColor = Color(0XFFF5F5F5);
  static var primaryLiteColor = Color(0xFF1B1A2C);

  static var remainingColor = Color(0xFF015FAA);
  static var occupiedColor = Color(0XFF7F02AB);
  static var handoverColor = Color(0XFF38AB02);

  static var redColor = Color(0XFFEC001B);

  static var guestColor = Color(0xFF1A9687);
  static var frequentColor = Color(0xFF0360B2);
  static var frequentBackgroundColor = Color(0xFFE6EFF7);

  static var darkgreyColor = Color(0XFF959398);
  static var resolvedStatusColor = Color(0XFFB3C9EA);
  static var takeButtonColor = Color(0xFFFAB36C);
  static var resolvedButtonColor = Color(0xFF5075D0);
}

String convertDateTimeFormat(DateTime inputDate) {
  String formattedDate = DateFormat('dd MMMM, y').format(inputDate);

  String formattedTime = DateFormat('hh:mm a').format(inputDate);

  return '$formattedDate $formattedTime';
}

String convertDateFormat(DateTime inputDate) {
  String formattedDate = DateFormat('dd MMMM, y').format(inputDate);

  return formattedDate;
}

String convertTimeFormat(DateTime inputDate) {
  String formattedTime = DateFormat('hh:mm a').format(inputDate);

  return formattedTime;
}
