import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/bloc/search_arg.dart';

import '../bloc/xml_load_bloc.dart';
import '../bloc/search_bloc.dart';
import '../bloc/tap_event_arg.dart';
import '../constants/class_db.dart';
import '../constants/stored_values.dart';
import '../models/class_content.dart';
import '../theme/themes.dart';

import 'class_detail.dart';

// TODO: refactor this file

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  final _searchBloc = SearchBloc();

  final _argList = [];

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

    _isDarkTheme = StoredValues().themeChange.isDark;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<SearchEventArg> filterResult() {
    List<SearchEventArg> _rtn = List<SearchEventArg>.from(_argList);

    if (!_searchClass) {
      _rtn.removeWhere(
          (element) => element.tapEventArg.linkType == LinkType.Class);
    }
    if (!_searchMethod) {
      _rtn.removeWhere(
          (element) => element.tapEventArg.linkType == LinkType.Method);
    }
    if (!_searchMember) {
      _rtn.removeWhere(
          (element) => element.tapEventArg.linkType == LinkType.Member);
    }
    if (!_searchSignal) {
      _rtn.removeWhere(
          (element) => element.tapEventArg.linkType == LinkType.Signal);
    }
    if (!_searchConstant) {
      _rtn.removeWhere(
          (element) => element.tapEventArg.linkType == LinkType.Constant);
    }
    if (!_searchEnum) {
      _rtn.removeWhere(
          (element) => element.tapEventArg.linkType == LinkType.Enum);
    }
    if (!_searchThemeItem) {
      _rtn.removeWhere(
          (element) => element.tapEventArg.linkType == LinkType.ThemeItem);
    }

    return _rtn;
  }

  void _onTextSubmit(String val) {
    _argList.clear();
    if (_controller.text.length > 0) {
      _doSearch(val);
    } else {}

    setState(() {
      _searching = ClassDB().getDB().last.version == null;
    });
  }

  void _xmlLoadSearch(ClassContent clsContent) {
    if (_searching && _searchingTerm.length > 0) {
      _searchSingle(clsContent);
    }

    setState(() {
      _searching = ClassDB().getDB().last.version == null;
    });
  }

  double _calculateRank(String value) {
    if (value.length == _searchingTerm.length) {
      return 0;
    }
    int before = value.indexOf(_searchingTerm);
    int after = value.length - before - _searchingTerm.length;
    return before * 1 + after * 0.5;
  }

  void _searchSingle(ClassContent _class) {
    var _classNameContains = false;
    if (_caseSensitive) {
      _classNameContains = _class.name!.contains(_searchingTerm);
    } else {
      _classNameContains = _class.name!.toLowerCase().contains(_searchingTerm);
    }

    if (_classNameContains) {
      _searchBloc.add(SearchEventArg(
          tapEventArg: TapEventArg(
              linkType: LinkType.Class, className: _class.name!, fieldName: ''),
          rank: _calculateRank(_class.name!)));
    }

    //search methods
    if (_class.methods != null && _class.methods!.length > 0) {
      _class.methods!.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          _searchBloc.add(SearchEventArg(
              tapEventArg: TapEventArg(
                  linkType: LinkType.Method,
                  className: _class.name!,
                  fieldName: element.name!),
              rank: _calculateRank(element.name!)));
        }
      });
    }

    //search signals
    if (_class.signals != null && _class.signals!.length > 0) {
      _class.signals!.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          _searchBloc.add(SearchEventArg(
              tapEventArg: TapEventArg(
                  linkType: LinkType.Signal,
                  className: _class.name!,
                  fieldName: element.name!),
              rank: _calculateRank(element.name!)));
        }
      });
    }

    //search constants & enum values
    if (_class.constants != null && _class.constants!.length > 0) {
      _class.constants!.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          if (element.enumValue != null) {
            //search enum values
            if (element.enumValue!.length > 0) {
              _searchBloc.add(
                SearchEventArg(
                    tapEventArg: TapEventArg(
                        linkType: LinkType.Enum,
                        className: _class.name!,
                        fieldName: "${element.enumValue}.${element.name}"),
                    rank: _calculateRank(element.name!)),
              );
            }
          } else {
            //search constants
            _searchBloc.add(
              SearchEventArg(
                  tapEventArg: TapEventArg(
                      linkType: LinkType.Constant,
                      className: _class.name!,
                      fieldName: element.name!),
                  rank: _calculateRank(element.name!)),
            );
          }
        }

        //search enum names,but will show enum values as well
        if (element.enumValue != null &&
            element.enumValue!.length > 0 &&
            (_caseSensitive
                ? element.enumValue!.contains(_searchingTerm)
                : element.enumValue!.toLowerCase().contains(_searchingTerm))) {
          _searchBloc.add(
            SearchEventArg(
                tapEventArg: TapEventArg(
                    linkType: LinkType.Enum,
                    className: _class.name!,
                    fieldName: "${element.enumValue}.${element.name}"),
                rank: _calculateRank(element.name!)),
          );
        }
      });
    }

    //search properties
    if (_class.members != null && _class.members!.length > 0) {
      _class.members!.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          _searchBloc.add(
            SearchEventArg(
                tapEventArg: TapEventArg(
                    linkType: LinkType.Member,
                    className: _class.name!,
                    fieldName: element.name!),
                rank: _calculateRank(element.name!)),
          );
        }
      });
    }

    //search theme items
    if (_class.themeItems != null && _class.themeItems!.length > 0) {
      _class.themeItems!.forEach((element) {
        if (_caseSensitive
            ? element.name!.contains(_searchingTerm)
            : element.name!.toLowerCase().contains(_searchingTerm)) {
          _searchBloc.add(
            SearchEventArg(
                tapEventArg: TapEventArg(
                    linkType: LinkType.ThemeItem,
                    className: _class.name!,
                    fieldName: element.name!),
                rank: _calculateRank(element.name!)),
          );
        }
      });
    }
  }

  void _doSearch(String term) async {
    if (_searchingTerm != term) {
      return;
    }

    if (!_caseSensitive) {
      term = term.toLowerCase();
    }
    _searching = true;
    ClassDB().getDB().forEach(_searchSingle);
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
    _filteredList.sort((a, b) {
      return a.rank.compareTo(b.rank);
    });

    List<Widget> _toRtnList = _filteredList.map((s) {
      final e = s.tapEventArg;
      if (e.linkType == LinkType.Class) {
        return ListTile(
          title: Text(e.linkType.toString().substring(9) + " : " + e.className),
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
        title: Text(e.linkType.toString().substring(9) + " : " + e.fieldName),
        subtitle: Text("Class:" + e.className),
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
              if (state.version?.isEmpty == true) {
              } else {
                _xmlLoadSearch(state);
              }
            }),
        BlocListener<SearchBloc, SearchEventArg>(
          bloc: _searchBloc,
          listener: (context, state) {
            setState(() {
              _argList.add(state);
            });
          },
        )
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor:
              _isDarkTheme ? darkTheme.backgroundColor : Colors.white,
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
              icon: Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
              },
            )
          ],
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48.0),
            child: ListTile(
              title: DropdownButton<String>(
                icon: Icon(Icons.list),
                value: _searchCat,
                items: _options.map((e) {
                  return DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
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
        body: ListView(
          children: _buildSearchResult(),
        ),
      ),
    );
  }
}
