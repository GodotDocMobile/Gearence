class MetadataKeys {
  // settings keys
  static const String isDarkMode = 'dark_mode';
  static const String translation = 'translation';
  static const String version = 'version';
  static const String monoSpaceFont = 'mono_space_Font';
  static const String fontSize = 'font_size';
  static const String storageSaver = 'storage_saver';

  static const String versionPrefix = 'doc_ver_'; // Used for dynamic keys
  // Helper for dynamic version keys
  static String getDocVersionKey(String version) =>
      "$versionPrefix${version.replaceAll('.', '_')}";

  // get_it keys
  static const String preferenceIsarKey = 'prefs_db';
  static const String docsIsarKey = 'docs_db';
}

final godotVersions = [
  "2.0",
  "2.1",
  "3.0",
  "3.1",
  "3.2",
  "3.3",
  "3.4",
  "3.5",
  "3.6",
  "4.0",
  "4.1",
  "4.2",
  "4.3",
  "4.4",
  "4.5",
  "4.6",
];
