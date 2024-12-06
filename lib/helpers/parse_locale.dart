import 'package:flutter/material.dart';

Locale parseLocale(String origin) {
  if (origin.contains('_')) {
    final splited = origin.split('_');
    return Locale(splited.first, splited.last);
  } else {
    return Locale(origin);
  }
}
