import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/colors.dart';
import '../constants/stored_values.dart';
import '../bloc/blocs.dart';

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

TextStyle? monoOptionalStyle(BuildContext context, {TextStyle? baseStyle}) {
  if (Provider.of<MonospaceFontBloc?>(context)?.monospaced ==
              true || // this is for main screen
          storedValues.monospaced.monospaced // this is for class detail screen
      ) {
    if (baseStyle != null) {
      return baseStyle.copyWith(fontFamily: 'JetbrainsMono');
    }
    return TextStyle(fontFamily: 'JetbrainsMono');
  }
  return baseStyle ?? null;
}
