import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:isar_plus/isar_plus.dart';

class ClassRepository {
  // 1. Changed to a List for faster ordered iteration (like the Class List)
  static final List<ClassContent> _classList = [];
  // 2. Kept the Map for O(1) lookups (like Links/Detail pages)
  static final Map<String, ClassContent> _cache = {};

  static bool _isInitialized = false;
  static bool get isInitialized => _isInitialized;

  static Future<void> init(Isar isar) async {
    if (_isInitialized) return;

    // Use findAllAsync to prevent blocking the splash/init screen
    final data = await isar.classContents.where().sortByName().findAllAsync();

    for (var c in data) {
      _classList.add(c);
      _cache[c.name!] = c;
    }
    _isInitialized = true;
  }

  /// Prepares the repository for a version switch or re-initialization.
  /// Clears in-memory lists and cache to free up memory.
  static void clear() {
    _classList.clear();
    _cache.clear();
    _isInitialized = false;
  }

  /// O(1) lookup for ClassDetail and Links
  static ClassContent? getClass(String name) => _cache[name];

  /// The full, sorted list for the main UI
  static List<ClassContent> getClassList() => _classList;

  /// High-speed in-memory filtering for your ClassList toggle switches
  static List<ClassContent> getFiltered(List<int> enabledTypeIndices) {
    return _classList.where((c) {
      // enum.index is an int, so this is a very fast bitwise/integer comparison
      return enabledTypeIndices.contains(c.nodeType.index);
    }).toList();
  }

  static bool class_exists(String name) => _cache.containsKey(name);

  static List<TapEventArg> deepSearch(
      String query, List<PropertyType> activeFilters) {
    if (query.isEmpty) return [];

    final term = query.toLowerCase();
    final List<TapEventArg> results = [];

    for (var cls in _classList) {
      final className = cls.name!;
      final classNameLower = className.toLowerCase();

      // 1. Search Class Name
      if (activeFilters.contains(PropertyType.Class) &&
          classNameLower.contains(term)) {
        results.add(TapEventArg(
            fieldName: className,
            propertyType: PropertyType.Class,
            className: className));
      }

      // 2. Search Methods
      if (activeFilters.contains(PropertyType.Method)) {
        for (var m in cls.methods) {
          if (m.name!.toLowerCase().contains(term)) {
            results.add(TapEventArg(
                fieldName: m.name!,
                propertyType: PropertyType.Method,
                className: className));
          }
        }
      }

      // 3. Search Signals
      if (activeFilters.contains(PropertyType.Signal)) {
        for (var s in cls.signals) {
          if (s.name!.toLowerCase().contains(term)) {
            results.add(TapEventArg(
                fieldName: s.name!,
                propertyType: PropertyType.Signal,
                className: className));
          }
        }
      }

      // 4. Search Constants & Enums
      if (cls.constants.isNotEmpty) {
        final searchConstants = activeFilters.contains(PropertyType.Constant);
        final searchEnums = activeFilters.contains(PropertyType.Enum);

        if (searchConstants || searchEnums) {
          // Track unique enum names seen in this class to avoid duplicates
          final seenEnums = <String>{};

          for (var c in cls.constants) {
            final cNameLower = c.name!.toLowerCase();
            final enumName = c.enumValue;

            // Case A: Search Enum Names (Like 'Mode' in 'ProcessMode')
            if (searchEnums && enumName != null) {
              final enumLower = enumName.toLowerCase();
              if (enumLower.contains(term) && !seenEnums.contains(enumName)) {
                seenEnums.add(enumName);
                results.add(TapEventArg(
                    propertyType: PropertyType.Enum,
                    className: className,
                    // Using your specific navigation format: "EnumName:.FirstValue"
                    fieldName: "$enumName:.${c.name}"));
              }

              // Case B: Search Enum Values (The specific constants inside the enum)
              if (cNameLower.contains(term)) {
                results.add(TapEventArg(
                    propertyType: PropertyType.Enum,
                    className: className,
                    fieldName: "$enumName.${c.name}"));
              }
            }
            // Case C: Search standalone Constants
            else if (searchConstants && cNameLower.contains(term)) {
              results.add(TapEventArg(
                  fieldName: c.name!,
                  propertyType: PropertyType.Constant,
                  className: className));
            }
          }
        }
      }

      // 5. Search Properties (Members)
      if (activeFilters.contains(PropertyType.Property)) {
        for (var p in cls.members) {
          if (p.name!.toLowerCase().contains(term)) {
            results.add(TapEventArg(
                fieldName: p.name!,
                propertyType: PropertyType.Property,
                className: className));
          }
        }
      }

      // 6. Search Theme Items
      if (activeFilters.contains(PropertyType.ThemeItem)) {
        for (var t in cls.themeItems) {
          if (t.name!.toLowerCase().contains(term)) {
            results.add(TapEventArg(
                fieldName: t.name!,
                propertyType: PropertyType.ThemeItem,
                className: className));
          }
        }
      }
    }

    return results;
  }
}
