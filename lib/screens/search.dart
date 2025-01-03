import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:godotclassreference/bloc/xml_load_bloc.dart';
import 'package:godotclassreference/bloc/search_bloc.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/theme/themes.dart';

import 'class_detail.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  final _searchBloc = SearchBloc();

  final List<TapEventArg> _argList = [];

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
  bool _caseSensitive = false;
  String? _searchCat = 'All';

  bool _searching = false;
  String _searchingTerm = '';

  bool _searchClass = true;
  bool _searchMethod = true;
  bool _searchConstant = true;
  bool _searchMember = true;
  bool _searchSignal = true;
  bool _searchThemeItem = true;
  bool _searchEnum = true;

  late bool _isDarkTheme;

  @override
  void initState() {
    super.initState();

    _controller.addListener(() async {
      var _lower = _controller.text.toLowerCase().replaceAll(' ', '');
      if (_searchingTerm != _lower) {
        _searchingTerm = _lower;
        _onTextSubmit(_lower);
      }
    });

    _isDarkTheme = storedValues.isDarkTheme;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<TapEventArg> filterResult() {
    List<TapEventArg> _rtn = List<TapEventArg>.from(_argList);

    if (!_searchClass) {
      _rtn.removeWhere((element) => element.propertyType == PropertyType.Class);
    }
    if (!_searchMethod) {
      _rtn.removeWhere(
          (element) => element.propertyType == PropertyType.Method);
    }
    if (!_searchMember) {
      _rtn.removeWhere(
          (element) => element.propertyType == PropertyType.Property);
    }
    if (!_searchSignal) {
      _rtn.removeWhere(
          (element) => element.propertyType == PropertyType.Signal);
    }
    if (!_searchConstant) {
      _rtn.removeWhere(
          (element) => element.propertyType == PropertyType.Constant);
    }
    if (!_searchEnum) {
      _rtn.removeWhere((element) => element.propertyType == PropertyType.Enum);
    }
    if (!_searchThemeItem) {
      _rtn.removeWhere(
          (element) => element.propertyType == PropertyType.ThemeItem);
    }

    return _rtn;
  }

  void _onTextSubmit(String val) {
    _argList.clear();
    if (_controller.text.length > 0) {
      if (_searchingTerm != val) {
        return;
      }

      if (!_caseSensitive) {
        val = val.toLowerCase();
      }
      _searching = true;
      ClassDB().getDB().forEach(_searchSingle);
    }

    setState(() {
      _searching = ClassDB().getDB().last.version == null;
    });
  }

  void _searchSingle(ClassContent _class) {
    var _classNameContains = false;
    if (_caseSensitive) {
      _classNameContains = _class.name!.contains(_searchingTerm);
    } else {
      _classNameContains = _class.name!.toLowerCase().contains(_searchingTerm);
    }

    if (_classNameContains) {
      _searchBloc.add(
        TapEventArg(
            propertyType: PropertyType.Class,
            className: _class.name!,
            fieldName: ''),
      );
    }

    //search methods
    if (_class.methods.length > 0) {
      _class.methods.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          _searchBloc.add(
            TapEventArg(
                propertyType: PropertyType.Method,
                className: _class.name!,
                fieldName: element.name!),
          );
        }
      });
    }

    //search signals
    if (_class.signals.length > 0) {
      _class.signals.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          _searchBloc.add(
            TapEventArg(
                propertyType: PropertyType.Signal,
                className: _class.name!,
                fieldName: element.name!),
          );
        }
      });
    }

    //search constants & enum values
    if (_class.constants.length > 0) {
      final containEnumNames = _class.constants
          .where((element) =>
              element.enumValue != null &&
              element.enumValue!.toLowerCase().contains(_searchingTerm))
          .map((e) => e.enumValue)
          .toSet() // this act like distinct
          .toList();

      containEnumNames.forEach((enumName) {
        // we will find the smallest value of each enumName
        final firstValue = _class.constants
            .where((element) => element.enumValue == enumName)
            .first;

        _searchBloc.add(
          TapEventArg(
              propertyType: PropertyType.Enum,
              className: _class.name!,
              // we ill ignore characters after ":", including ":", but we need those to navigate
              fieldName: "$enumName:.${firstValue.name}"),
        );
      });

      _class.constants.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          if (element.enumValue != null) {
            //search enum values
            if (element.enumValue!.length > 0) {
              _searchBloc.add(
                TapEventArg(
                    propertyType: PropertyType.Enum,
                    className: _class.name!,
                    fieldName: "${element.enumValue}.${element.name}"),
              );
            }
          } else {
            //search constants
            _searchBloc.add(
              TapEventArg(
                  propertyType: PropertyType.Constant,
                  className: _class.name!,
                  fieldName: element.name!),
            );
          }
        }
      });
    }

    //search properties
    if (_class.members.length > 0) {
      _class.members.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          _searchBloc.add(
            TapEventArg(
                propertyType: PropertyType.Property,
                className: _class.name!,
                fieldName: element.name!),
          );
        }
      });
    }

    //search theme items
    if (_class.themeItems.length > 0) {
      _class.themeItems.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          _searchBloc.add(
            TapEventArg(
                propertyType: PropertyType.ThemeItem,
                className: _class.name!,
                fieldName: element.name!),
          );
        }
      });
    }
  }

  int matchedCompare(TapEventArg a, TapEventArg b) {
    String aValue = "";
    String bValue = "";
    if (a.propertyType == PropertyType.Class) {
      aValue = a.className;
    } else {
      aValue = a.fieldName;
    }

    if (b.propertyType == PropertyType.Class) {
      bValue = b.className;
    } else {
      bValue = b.fieldName;
    }

    // we will not check characters after ":"
    // eg. NodeType:.NODE_NONE, we will ignore [:.NODE_NONE]
    if (aValue.contains(':')) {
      aValue = aValue.substring(0, aValue.indexOf(':'));
    } else if (aValue.contains('.') && !aValue.contains('/')) {
      final pos = aValue.indexOf('.');
      aValue = aValue.substring(pos).padLeft(pos, 'z');
    }

    if (bValue.contains(':')) {
      bValue = bValue.substring(0, bValue.indexOf(':'));
    } else if (bValue.contains('.') && !aValue.contains('/')) {
      final pos = bValue.indexOf('.');
      bValue = bValue.substring(pos).padLeft(pos, 'z');
    }

    aValue = aValue.toLowerCase();
    bValue = bValue.toLowerCase();

    int posCmp = aValue
        .toLowerCase()
        .indexOf(_searchingTerm)
        .compareTo(bValue.toLowerCase().indexOf(_searchingTerm));
    if (posCmp != 0) {
      return posCmp;
    }

    int beforeCmp = aValue
        .substring(0, aValue.indexOf(_searchingTerm))
        .compareTo(bValue.substring(0, bValue.indexOf(_searchingTerm)));

    if (beforeCmp != 0) {
      return beforeCmp;
    }

    int ifAfterCmp = aValue
        .substring(aValue.indexOf(_searchingTerm))
        .length
        .compareTo(bValue.substring(bValue.indexOf(_searchingTerm)).length);
    if (ifAfterCmp != 0) {
      return ifAfterCmp;
    }

    int afterCmp = aValue
        .substring(aValue.indexOf(_searchingTerm))
        .compareTo(bValue.substring(bValue.indexOf(_searchingTerm)));

    return afterCmp;
  }

  List<Widget> _buildSearchResult() {
    _argList.remove(null);
    if (_argList.length == 0) {
      List<Widget> _rtn = [
        ListTile(
          title: Text('No Result'),
        )
      ];
      return _rtn;
    }

    final _filteredList = filterResult();
    _filteredList.sort(matchedCompare);

    List<Widget> _toRtnList = _filteredList.map((e) {
      final resultTypeName = e.propertyType.toString().substring(13);
      if (e.propertyType == PropertyType.Class) {
        return ListTile(
          title: Semantics(
            onTapHint: 'Navigate to this item',
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: resultTypeName + ": ",
                  style: TextStyle(
                      color: storedValues.isDarkTheme
                          ? Colors.white60
                          : Colors.black54),
                ),
                TextSpan(
                  text: e.className,
                  style: monoOptionalStyle(context,
                      baseStyle: TextStyle(
                          color: storedValues.isDarkTheme
                              ? Colors.white
                              : Colors.black)),
                )
              ]), textScaler: TextScaler.linear(1.1),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassDetail(
                  className: e.className,
                  args: e,
                ),
              ),
            );
          },
        );
      }
      return ListTile(
        title: RichText(
          text: TextSpan(children: [
            TextSpan(
              text: resultTypeName + ": ",
              style: TextStyle(
                  color: storedValues.isDarkTheme
                      ? Colors.white60
                      : Colors.black54),
            ),
            TextSpan(
              text: e.fieldName.substring(
                  0,
                  e.fieldName.indexOf(":") < 0
                      ? e.fieldName.length
                      : e.fieldName.indexOf(":")),
              style: monoOptionalStyle(context,
                  baseStyle: TextStyle(
                      color: storedValues.isDarkTheme
                          ? Colors.white
                          : Colors.black)),
            )
          ]), textScaler: TextScaler.linear(1.1),
        ),
        subtitle: RichText(
          text: TextSpan(
            children: [
              TextSpan(text: "Class:"),
              TextSpan(text: e.className, style: monoOptionalStyle(context))
            ],
            style: TextStyle(
                color:
                    storedValues.isDarkTheme ? Colors.white38 : Colors.black38),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ClassDetail(
                className: e.className,
                args: e,
              ),
            ),
          );
        },
      );
    }).toList();

    if (_searching) {
      _toRtnList.add(ListTile(
        title: Center(
          child: CircularProgressIndicator(),
        ),
      ));
    }
    return _toRtnList;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<XMLLoadBloc, ClassContent>(
            bloc: ClassDB().loadBloc,
            listener: (context, state) {
              if (state.version != null &&
                  _searching &&
                  _searchingTerm.length > 0) {
                _searchSingle(state);
              }
              setState(() {
                _searching = ClassDB().getDB().last.version == null;
              });
            }),
        BlocListener<SearchBloc, TapEventArg>(
          bloc: _searchBloc,
          listener: (context, state) {
            if (!_argList.any((element) =>
                element.className == state.className &&
                element.fieldName == state.fieldName &&
                element.propertyType == state.propertyType)) {
              setState(() {
                _argList.add(state);
              });
            }
          },
        )
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              _isDarkTheme ? darkTheme.colorScheme.surface : Colors.white,
          iconTheme: IconThemeData(
              color: _isDarkTheme ? darkTheme.iconTheme.color : Colors.black),
          title: TextField(
            autofocus: true,
            controller: _controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter a search term',
                hintStyle: TextStyle(color: Colors.white54)),
            onSubmitted: _onTextSubmit,
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'Clear search term',
              icon: Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
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
                    final _idx = _options.indexOf(v!);
                    _searchClass = _idx < 2;
                    _searchMethod = _idx == 0 || _idx == 2;
                    _searchMember = _idx == 0 || _idx == 3;
                    _searchSignal = _idx == 0 || _idx == 4;
                    _searchConstant = _idx == 0 || _idx == 5;
                    _searchEnum = _idx == 0 || _idx == 6;
                    _searchThemeItem = _idx == 0 || _idx == 7;
                    setState(() {
                      _searchCat = v;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        body: ListView(
          children: _buildSearchResult(),
        ),
      ),
    );
  }
}
