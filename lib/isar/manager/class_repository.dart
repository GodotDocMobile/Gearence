import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:isar_plus/isar_plus.dart';

class ClassDB {
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

  static List<ClassContent> search(String query, List<int> enabledTypeIndices) {
    final lowercaseQuery = query.toLowerCase();

    return _classList.where((c) {
      // 1. Quick Category Filter (Integer check)
      if (!enabledTypeIndices.contains(c.nodeType.index)) return false;

      // 2. Text Search
      if (query.isEmpty) return true;
      return c.name!.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
