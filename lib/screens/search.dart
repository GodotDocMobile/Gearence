import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
// import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:isar_plus/isar_plus.dart';

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
  List<SearchableItem> _searchResults = [];
  bool _isSearching = false;

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

  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    controller.addListener(() async {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 150), () {
        _performSearch(controller.text);
      });
    });

    _isDarkTheme = storedValues.isDarkTheme;
  }

  void _performSearch(String text) async {
    if (text.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() => _isSearching = true);

    final term = text.toLowerCase();
    final isar = GetIt.I<Isar>(instanceName: MetadataKeys.docsIsarKey);
    final activeFilters = _getActiveFilters();

    // 1. Get high-priority matches (Starts With)
    // .where() starts the query. nameLowerStartsWith() uses the index.
    // Then we chain .anyOf() directly.
    final results = await isar.searchableItems
        .where()
        .nameLowerStartsWith(term)
        .and()
        .anyOf(activeFilters, (q, PropertyType type) => q.typeEqualTo(type))
        .findAll();

    // 2. Fallback for "Contains" matches
    // if (results.length < 20) {
      // For 'Contains', we can't use the 'StartsWith' index.
      // So we just call .where() and immediately filter.
      final extra = await isar.searchableItems
          .where()
          .nameLowerContains(term)
          .and()
          .anyOf(activeFilters, (q, PropertyType type) => q.typeEqualTo(type))
          .and()
          .not()
          .nameLowerStartsWith(term)
          .findAll();

      results.addAll(extra);
    // }

    results.sort((a, b) => _compareResults(a, b, text));

    final uniqueResults = <String, SearchableItem>{};
    for (var item in results) {
      // Use a composite key of Name + Type to keep unique items
      final key = "${item.name}_${item.type}";
      if (!uniqueResults.containsKey(key)) {
        uniqueResults[key] = item;
      }
    }

    if (mounted) {
      setState(() {
        _searchResults = uniqueResults.values.toList();
        _isSearching = false;
      });
    }
  }

  int _compareResults(SearchableItem a, SearchableItem b, String term) {
    final aLower = a.name.toLowerCase();
    final bLower = b.name.toLowerCase();
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
    if (a.name.length != b.name.length) {
      return a.name.length.compareTo(b.name.length);
    }

    // 5. Alphabetical fallback
    return aLower.compareTo(bLower);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Widget> _buildSearchResult() {
    if (_searchResults.isEmpty) {
      return [const ListTile(title: Text('No Result'))];
    }

    return _searchResults.map((item) {
      final typeName = item.type.name;
      final isClass = item.type == PropertyType.Class;

      return ListTile(
        // leading: Icon(_getIconForType(item.type), size: 18), // Optional: add icons
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$typeName: ",
                style: TextStyle(
                    color: _isDarkTheme ? Colors.white60 : Colors.black54),
              ),
              TextSpan(
                text: item.name,
                style: monoOptionalStyle(context,
                    baseStyle: TextStyle(
                        color: _isDarkTheme ? Colors.white : Colors.black)),
              ),
            ],
          ),
        ),
        subtitle: isClass ? null : Text("Class: ${item.className}"),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetail(
                className: item.className,
                // Convert searchable item back to your navigation arg if needed
                args: TapEventArg(
                  propertyType: item.type,
                  className: item.className,
                  fieldName: isClass ? '' : item.name,
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
      body: ListView(
        children: _buildSearchResult(),
      ),
    );
  }
}
