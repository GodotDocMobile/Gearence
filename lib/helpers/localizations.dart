import 'package:flutter/material.dart';

// hacky but works
// copied from https://stackoverflow.com/questions/57902361/flutter-app-crashes-building-the-appbar-with-multi-language-using-i18n-jetbrains

class FallbackLocalizationDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<MaterialLocalizations> load(Locale locale) async => DefaultMaterialLocalizations();
  @override
  bool shouldReload(_) => false;
}