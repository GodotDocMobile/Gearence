import 'package:flutter/material.dart';
import 'package:godotclassreference/bloc/icon_for_non_node_bloc.dart';
import 'package:godotclassreference/components/svg_icon.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';

class ClassIcon extends StatefulWidget {
  final ClassContent classContent;
  final IconForNonNodeBloc bloc;

  const ClassIcon({Key key, this.classContent, this.bloc}) : super(key: key);

  @override
  _ClassIconState createState() => _ClassIconState();
}

class _ClassIconState extends State<ClassIcon> {
  IconForNonNodeBloc _bloc;
  bool iconForNonNode = StoredValues().iconForNonNode;

  @override
  void initState() {
    // TODO: implement initState
    _bloc = IconForNonNodeBloc();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        initialData: iconForNonNode,
        stream: widget.bloc.argStream,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data || widget.classContent.belong('Node')) {
              return SvgIcon(
                className: widget.classContent.name,
                version: StoredValues().prefs.getString('version'),
              );
            }
          }

          return SizedBox();
        });
  }
}
