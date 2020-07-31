import 'dart:async';
//import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:godotclassreference/bloc/search_bloc.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/constants/class_list.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:xml/xml.dart' as xml;

import 'class_detail.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  final _searchBloc = SearchBloc();

  final _argList = List<TapEventArg>();

  final _options = [
    'All',
    'Classes Only',
    'Methods Only',
    'Members Only',
    'Signals Only',
    'Constants Only',
    'Theme Items Only'
  ];
  bool _caseSensitive = false;
  String _searchCat = 'All';

  bool _searching = false;
  String _searchingTerm = '';

  bool _searchClass = true;
  bool _searchMethod = true;
  bool _searchConstant = true;
  bool _searchMember = true;
  bool _searchSignal = true;
  bool _searchThemeItem = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _searchBloc.dispose();
  }

  void _onTextSubmit(String val) {
    if (_controller.text.length > 0) {
//      print(_controller.text);
      _argList.clear();
      val = val.toLowerCase().replaceAll(' ', '');
      _searchingTerm = val;
      _doSearch(val);
    }
  }

  void _doSearch(String term) async {
    if (_searchingTerm != term || term.length <= 1) {
      return;
    }

    if (!_caseSensitive) {
      term = term.toLowerCase();
    }

    for (int i = 0; i < ClassDB().getDB().length; i++) {
//      if (_searchingTerm != term) {
//        return;
//      }

      final _class = ClassDB().getDB()[i];

//      print(_class.name);
      var _classNameContains = false;
      if (_caseSensitive) {
        _classNameContains = _class.name.contains(term);
      } else {
        _classNameContains = _class.name.toLowerCase().contains(term);
      }

      if (_searchClass && _classNameContains) {
        _searchBloc.argSink.add(TapEventArg(
            linkType: LinkType.Class, className: _class.name, fieldName: ''));
      }

      //search methods
      if (_searchMethod &&
          _class.methods != null &&
          _class.methods.length > 0) {
        _class.methods.forEach((element) {
          if (_caseSensitive
              ? element.name.contains(term)
              : element.name.toLowerCase().contains(term)) {
            _searchBloc.argSink.add(TapEventArg(
                linkType: LinkType.Method,
                className: _class.name,
                fieldName: element.name));
          }
        });
      }

      //search signals
      if (_searchSignal &&
          _class.signals != null &&
          _class.signals.length > 0) {
        _class.signals.forEach((element) {
          if (_caseSensitive
              ? element.name.contains(term)
              : element.name.toLowerCase().contains(term)) {
            _searchBloc.argSink.add(TapEventArg(
                linkType: LinkType.Signal,
                className: _class.name,
                fieldName: element.name));
          }
        });
      }

      //search constants
      if (_searchConstant &&
          _class.constants != null &&
          _class.constants.length > 0) {
        _class.constants.forEach((element) {
          if (_caseSensitive
              ? element.name.contains(term)
              : element.name.toLowerCase().contains(term)) {
            _searchBloc.argSink.add(TapEventArg(
                linkType: LinkType.Constant,
                className: _class.name,
                fieldName: element.name));
          }
        });
      }

      //search properties
      if (_searchMember &&
          _class.members != null &&
          _class.members.length > 0) {
        _class.members.forEach((element) {
          if (_caseSensitive
              ? element.name.contains(term)
              : element.name.toLowerCase().contains(term)) {
            _searchBloc.argSink.add(TapEventArg(
                linkType: LinkType.Member,
                className: _class.name,
                fieldName: element.name));
          }
        });
      }

      //search theme items
      if (_searchThemeItem &&
          _class.themeItems != null &&
          _class.themeItems.length > 0) {
        _class.themeItems.forEach((element) {
          if (_caseSensitive
              ? element.name.contains(term)
              : element.name.toLowerCase().contains(term)) {
            _searchBloc.argSink.add(TapEventArg(
                linkType: LinkType.ThemeItem,
                className: _class.name,
                fieldName: element.name));
          }
        });
      }

//      Timer _timer = new Timer.periodic(Duration(seconds: 1), (timer) {});
      while (i == ClassDB().getDB().length - 1 && !ClassDB().loaded) {
//        continue;
      }
    }
//    print('done searching');
//    if(_searchBloc == null)
  }

  List<Widget> _buildSearchResult() {
    List<Widget> _toRtnList = _argList.toSet().toList().map((e) {
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
//      return ListTile(
//        title: Text(e.className),
//        subtitle: Text(e.linkType.toString().replaceAll('LinkType.', '') +
//            ':' +
//            e.fieldName),
//      );
    }).toList();

    if (_searching) {
      _toRtnList.add(Center(
        child: CircularProgressIndicator(),
      ));
    }
    return _toRtnList;
  }

  @override
  Widget build(BuildContext context) {
    _searchBloc.argStream.listen((event) {
      setState(() {
        _argList.add(event);
      });
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
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
//            leading: Icon(Icons.filter_list),
//            leading: IconButton(
//              icon: Icon(
//                Icons.format_size,
//              ),
//              color: _caseSensitive ? Colors.blue : Colors.grey,
//              onPressed: () {
//                setState(() {
//                  _caseSensitive = !_caseSensitive;
//                });
//                _onTextSubmit(_controller.text);
//              },
//            ),
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
                final _idx = _options.indexOf(v);
                _searchClass = _idx < 2;
                _searchMethod = _idx == 0 || _idx == 2;
                _searchMember = _idx == 0 || _idx == 3;
                _searchSignal = _idx == 0 || _idx == 4;
                _searchConstant = _idx == 0 || _idx == 5;
                _searchThemeItem = _idx == 0 || _idx == 6;
                _onTextSubmit(_controller.text);
                setState(() {
                  _searchCat = v;
                });
              },
            ),
          ),
        ),
      ),

//      body: StreamBuilder<TapEventArg>(
//        stream: _searchBloc.argStream,
//        builder: (BuildContext context, AsyncSnapshot<TapEventArg> snapshot) {
//          _argList.add(snapshot.data);
//          print('search result:' + _argList.length.toString());
//
//          return ListView(
//            children: _buildSearchResult(),
//          );
//        },
//      ),
      body: ListView(
        children: _buildSearchResult(),
      ),
    );
  }
}
