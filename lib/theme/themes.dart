import 'package:flutter/material.dart';

import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/constants/stored_values.dart';

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
      .copyWith(fontSize: 14 + storedValues.fontSize * TEXT_STYLE_FACTOR);
}

MediaQueryData scaledMediaQueryData(BuildContext context) {
  return MediaQuery.of(context)
      .copyWith(textScaleFactor: 1 + storedValues.fontSize * TEXT_SCALE_FACTOR);
}

TextStyle nonScaleTextStyle(BuildContext context) {
  return DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
}

MediaQueryData nonScaledMediaQueryData(BuildContext context) {
  return MediaQuery.of(context).copyWith(textScaleFactor: 1);
}

TextStyle? monoOptionalStyle(BuildContext context, {TextStyle? baseStyle}) {
  if (storedValues.isMonospaced) {
    if (baseStyle != null) {
      return baseStyle.copyWith(fontFamily: 'JetbrainsMono');
    }
    return TextStyle(fontFamily: 'JetbrainsMono');
  }
  return baseStyle ?? null;
}
