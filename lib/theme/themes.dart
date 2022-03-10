import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';
import '../constants/stored_values.dart';

ThemeData darkTheme = ThemeData(
  primarySwatch: godotColor as MaterialColor?,
  brightness: Brightness.dark,
);

ThemeData lightTheme = ThemeData(
  primarySwatch: godotColor as MaterialColor?,
);

const TEXT_SCALE_FACTOR = 0.1;
const TEXT_STYLE_FACTOR = 2.5;

TextStyle scaledTextStyle(BuildContext context) {
  return DefaultTextStyle.of(context)
      .style
      .copyWith(fontSize: 14 + StoredValues().fontSize! * TEXT_STYLE_FACTOR);
}

MediaQueryData scaledMediaQueryData(BuildContext context) {
  return MediaQuery.of(context).copyWith(
      textScaleFactor: 1 + StoredValues().fontSize! * TEXT_SCALE_FACTOR);
}

TextStyle nonScaleTextStyle(BuildContext context) {
  return DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
}

MediaQueryData nonScaledMediaQueryData(BuildContext context) {
  return MediaQuery.of(context).copyWith(textScaleFactor: 1);
}
