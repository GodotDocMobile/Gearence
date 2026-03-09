import 'package:flutter/material.dart';
import 'package:godotclassreference/helpers/translation_deletage.dart'; // Import your new delegate file

extension ContextExt on BuildContext {
  String translate(String key) {
    // 1. Get the localization instance from the current context
    final loc = GearenceLocalizations.of(this);
    
    // 2. If it exists, use your Isar-lookup logic. 
    // If not (e.g., during app boot), return the original key.
    if (loc != null) {
      return loc.translate(key);
    }
    
    return key;
  }
}