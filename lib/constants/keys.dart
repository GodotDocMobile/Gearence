abstract class MetadataKeys {
  MetadataKeys._();
  // settings keys
  static const String isDarkMode = 'dark_mode';
  static const String translation = 'translation';
  static const String version = 'version';
  static const String monoSpaceFont = 'mono_space_Font';
  static const String fontSize = 'font_size';
  static const String storageSaver = 'storage_saver';
  static const String enabledNodeFilters = 'enabled_node_filters';

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

abstract class UIInfoKeys {
  UIInfoKeys._();

  static const String inherits = "Inherits:";
  static const String inheritedBy = 'Inherited By:';
  static const String briefDescription = 'Brief Description:';
  static const String version = 'Version:';
  static const String category = 'Category:';
  static const String description = 'Description';
  static const String demos = 'Demos:';
  static const String tutorials = 'Tutorials:';

  // tabs
  static const String info = "Info";
  static const String enumerations = "Enumerations";
  static const String constants = "Constants";
  static const String properties = "Properties";
  static const String methods = 'Methods';
  static const String signals = 'Signals';
  static const String themeProperties = "Theme Properties";
  static const String annotations = 'Annotations';

  // for batch translations
  static const String returnKey = 'return';
  static const String setterKey = 'Setter';
  static const String getterKey = 'Getter';
}
