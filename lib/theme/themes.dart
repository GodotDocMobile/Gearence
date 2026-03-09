import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/isar/manager/settings_repository.dart';

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
  final fontSizeRecord = GetIt.I<SettingsRepository>().getFontSize();
  return DefaultTextStyle.of(context)
      .style
      .copyWith(fontSize: 14 + fontSizeRecord.intValue! * TEXT_STYLE_FACTOR);
}

MediaQueryData scaledMediaQueryData(BuildContext context) {
  final fontSizeRecord = GetIt.I<SettingsRepository>().getFontSize();
  return MediaQuery.of(context).copyWith(
      textScaler:
          TextScaler.linear(1 + fontSizeRecord.intValue! * TEXT_SCALE_FACTOR));
}

TextStyle nonScaleTextStyle(BuildContext context) {
  return DefaultTextStyle.of(context).style.copyWith(fontSize: 14);
}

MediaQueryData nonScaledMediaQueryData(BuildContext context) {
  return MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1));
}

TextStyle? monoOptionalStyle(BuildContext context, {TextStyle? baseStyle}) {
  final fontSizeRecord = GetIt.I<SettingsRepository>().getMonospace();
  if (fontSizeRecord.boolValue == true) {
    if (baseStyle != null) {
      return baseStyle.copyWith(fontFamily: 'JetbrainsMono');
    }
    return TextStyle(fontFamily: 'JetbrainsMono');
  }
  return baseStyle ?? null;
}
