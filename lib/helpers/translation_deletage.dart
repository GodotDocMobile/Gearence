import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:isar_plus/isar_plus.dart';

class GearenceLocalizations {
  final Locale locale;

  GearenceLocalizations(this.locale);

  static GearenceLocalizations? of(BuildContext context) {
    return Localizations.of<GearenceLocalizations>(
        context, GearenceLocalizations);
  }

  String translate(String? msgid) {
    if (msgid == null || msgid.isEmpty || locale.languageCode == 'en') {
      return msgid ?? '';
    }

    // 1. Try to get Isar from GetIt safely
    if (!GetIt.I.isRegistered<Isar>(instanceName: MetadataKeys.docsIsarKey)) {
      return msgid; // Fallback to English if DB isn't ready yet
    }

    final isar = GetIt.I<Isar>(instanceName: MetadataKeys.docsIsarKey);

    // 2. Perform the lookup
    final entry = isar.translations.where().msgidEqualTo(msgid).findFirst();

    if (entry == null || entry.translations == null) return msgid;

    final lookupKey = _getLookupKey(locale);
    final localized = entry.translations!.firstWhere(
      (t) => t.locale == lookupKey,
      orElse: () => LocaleString()..value = msgid,
    );

    return localized.value ?? msgid;
  }

  String _getLookupKey(Locale l) {
    if (l.scriptCode != null) return "${l.languageCode}_${l.scriptCode}";
    if (l.countryCode != null && l.countryCode!.isNotEmpty) {
      return "${l.languageCode}_${l.countryCode}";
    }
    return l.languageCode;
  }
}

class GearenceLocalizationsDelegate
    extends LocalizationsDelegate<GearenceLocalizations> {
  const GearenceLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true; // Support any locale Godot supports

  @override
  Future<GearenceLocalizations> load(Locale locale) async {
    return GearenceLocalizations(locale);
  }

  @override
  bool shouldReload(GearenceLocalizationsDelegate old) => false;
}
