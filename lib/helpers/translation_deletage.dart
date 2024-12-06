import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gettext/flutter_gettext/gettext_localizations.dart';
import 'package:godotclassreference/constants/stored_values.dart';

/// LocalizationsDelegate for GettextLocalizations
class GearenceGettextLocalizationsDelegate extends LocalizationsDelegate<GettextLocalizations> {
  GearenceGettextLocalizationsDelegate({this.defaultLanguage = 'en'});

  final String defaultLanguage;

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<GettextLocalizations> load(Locale locale) async {
    var poContent = '';
    try {
      poContent = await rootBundle.loadString('translations/${storedValues.version}/${locale.languageCode}_${locale.countryCode}.po');
    } catch (e) {
      try {
        poContent = await rootBundle.loadString('translations/${storedValues.version}/${locale.languageCode}.po');
      } catch (e) {
        try {
          poContent = await rootBundle.loadString('translations/${storedValues.version}/$defaultLanguage.po');
        } catch (e) {
          // Ignore error, default strings will be used.
        }
      }
    }

    /// If no PO file was found, use default strings.
    if (poContent == '') {
      poContent = 'msgid ""\nmsgstr ""\n"Language: $defaultLanguage\\n"\n';
    }

    return GettextLocalizations.fromPO(poContent);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<GettextLocalizations> old) => true;
}
