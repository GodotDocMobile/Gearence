import 'package:flutter/material.dart';

import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/isar/manager/class_repository.dart';
import 'package:godotclassreference/theme/themes.dart';

import 'class_detail.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final controller = TextEditingController();

  final _options = [
    'All',
    'Classes Only',
    'Methods Only',
    'Members Only',
    'Signals Only',
    'Constants Only',
    'Enums Only',
    'Theme Items Only'
  ];
  String? _searchCat = 'All';

  late bool _isDarkTheme;

  // Inside _SearchScreenState
  List<TapEventArg> _searchResults = [];
  bool isSearching = false;

// Helper to map UI categories to PropertyTypes
  List<PropertyType> _getActiveFilters() {
    if (_searchCat == 'All') return PropertyType.values;
    return switch (_searchCat) {
      'Classes Only' => [PropertyType.Class],
      'Methods Only' => [PropertyType.Method],
      'Members Only' => [PropertyType.Property],
      'Signals Only' => [PropertyType.Signal],
      'Constants Only' => [PropertyType.Constant],
      'Enums Only' => [PropertyType.Enum],
      'Theme Items Only' => [PropertyType.ThemeItem],
      _ => PropertyType.values,
    };
  }

  @override
  void initState() {
    super.initState();

    controller.addListener(() {
      _performSearch(controller.text);
    });
  }

  void _performSearch(String text) {
    if (text.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    // This loop through ~2000 classes and their members takes ~2-5ms in Dart.
    // No 'await' needed!
    final activeFilters = _getActiveFilters();
    final results = ClassRepository.deepSearch(text, activeFilters);

    // Sort using your existing _compareResults logic (adapted for SearchableItem POJO)
    results.sort((a, b) => _compareResults(a, b, text));

    setState(() {
      _searchResults = results;
    });
  }

  int _compareResults(TapEventArg a, TapEventArg b, String term) {
    final aLower = a.fieldName.toLowerCase();
    final bLower = b.fieldName.toLowerCase();
    final query = term.toLowerCase();

    // 1. Exact match priority
    if (aLower == query && bLower != query) return -1;
    if (bLower == query && aLower != query) return 1;

    // 2. StartsWith priority (Prefix matching)
    final aStarts = aLower.startsWith(query);
    final bStarts = bLower.startsWith(query);
    if (aStarts && !bStarts) return -1;
    if (bStarts && !aStarts) return 1;

    // 3. Position of match (The earlier the match, the better)
    int aPos = aLower.indexOf(query);
    int bPos = bLower.indexOf(query);
    if (aPos != bPos) return aPos.compareTo(bPos);

    // 4. Length priority (Shorter strings are more likely what the user wants)
    if (a.fieldName.length != b.fieldName.length) {
      return a.fieldName.length.compareTo(b.fieldName.length);
    }

    // 5. Alphabetical fallback
    return aLower.compareTo(bLower);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    _isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            _isDarkTheme ? darkTheme.colorScheme.surface : Colors.white,
        iconTheme: IconThemeData(
            color: _isDarkTheme ? darkTheme.iconTheme.color : Colors.black),
        title: TextField(
          autofocus: true,
          controller: controller,
          decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter a search term',
              hintStyle: TextStyle(color: Colors.white54)),
          // onSubmitted: _onTextSubmit,
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Clear search term',
            icon: Icon(Icons.clear),
            onPressed: () {
              controller.clear();
            },
          )
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.0),
          child: ListTile(
            title: Semantics(
              onTapHint: 'Change search fields',
              child: DropdownButton<String>(
                icon: Icon(Icons.list),
                value: _searchCat,
                items: _options.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Semantics(
                      child: Text(e),
                      onTapHint: 'Set search fields to $e',
                    ),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _searchCat = v;
                  });
                  _performSearch(controller.text);
                },
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        // Use builder for performance
        itemCount: _searchResults.length,
        itemExtent: 70.0, // Fixed height is king for Snapdragon
        itemBuilder: (context, index) {
          final item = _searchResults[index];
          return _buildSearchTile(item);
        },
      ),
    );
  }

  Widget _buildSearchTile(TapEventArg item) {
    final isClass = item.propertyType == PropertyType.Class;
    return ListTile(
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: "${item.propertyType!.name}: ",
                style: TextStyle(
                    color: _isDarkTheme ? Colors.white60 : Colors.black54)),
            TextSpan(
                text: item.fieldName,
                style: monoOptionalStyle(context,
                    baseStyle: TextStyle(
                        color: _isDarkTheme ? Colors.white : Colors.black))),
          ],
        ),
      ),
      subtitle: isClass ? null : Text("Class: ${item.className}"),
      onTap: () {
        print(item.toString());
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetail(
                className: item.className,
                args: item,
              ),
            ));
      },
    );
  }
}
