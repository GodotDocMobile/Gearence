import 'package:flutter/material.dart';
import 'package:godotclassreference/bloc/search_bloc.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _searchBloc = SearchBloc();

  final _argList = List<TapEventArg>();

  bool _searching = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchBloc.dispose();
    super.dispose();
  }

  void _onTextSubmit(String val) {
    if (_controller.text.length > 0) {
      print(_controller.text);
    }
  }

  List<Widget> _buildSearchResult() {
    List<Widget> _toRtnList = _argList.map((e) {
      return ListTile(
        title: Text(''),
      );
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
      ),
      body: StreamBuilder<TapEventArg>(
        stream: _searchBloc.argStream,
        builder: (BuildContext context, AsyncSnapshot<TapEventArg> snapshot) {
          return ListView(
            children: _buildSearchResult(),
          );
        },
      ),
    );
  }
}
