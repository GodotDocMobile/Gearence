import 'dart:async';

import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/models/constant.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassEnums extends StatefulWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;
  final Stream<TapEventArg> eventStream;

  ClassEnums(
      {Key key,
      @required this.clsContent,
      this.eventStream,
      @required this.onLinkTap})
      : assert(clsContent != null),
        assert(onLinkTap != null),
        super(key: key);

  @override
  _ClassEnumsState createState() => _ClassEnumsState();
}

class _ClassEnumsState extends State<ClassEnums> {
  ItemScrollController _scrollController;
  ItemPositionsListener _itemPositionsListener;
  StreamSubscription<TapEventArg> _tapSub;

  List<String> _enumNames = List<String>();

  List<Widget> _builtList = List<Widget>();
  List<String> _enumValues = List<String>();

  @override
  void initState() {
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _enumNames = widget.clsContent.constants
        .map((c) {
          return c.enumValue;
        })
        .toSet()
        .where((w) => w != null)
        .toList();
    _tapSub = widget.eventStream.listen((v) {
      try {
        scrollTo(v);
      } catch (_) {}
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tapSub.cancel();
    super.dispose();
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent.name == args.className &&
        args.linkType == LinkType.Enum) {
      final _targetIndex =
          _enumValues.indexWhere((w) => w == args.fieldName.split('.').last);
      if (_targetIndex != -1) {
        _scrollController.scrollTo(
          curve: Curves.easeInOutCubic,
          index: _targetIndex,
          duration: Duration(milliseconds: 500),
        );
      }
    }
  }

  int _getPositionCount() {
    return widget.clsContent.constants.where((element) {
      return element.enumValue != null && element.enumValue.length > 0;
    }).length;
  }

  Widget _singleEnum(Constant clsConstant) {
    return ListTile(
      title: Text('${clsConstant.name} = ${clsConstant.value}'),
      subtitle: DescriptionText(
        className: widget.clsContent.name,
        content: clsConstant.constantText,
        onLinkTap: widget.onLinkTap,
      ),
    );
  }

  void buildEnums() {
    _enumNames.sort();
    _enumNames.forEach((enumName) {
      List<Constant> _belongEnum = widget.clsContent.constants.where((element) {
        return element.enumValue != null && element.enumValue == enumName;
      }).toList();
      _belongEnum
          .sort((a, b) => int.parse(a.value).compareTo(int.parse(b.value)));

      _enumValues.add(_belongEnum[0].name);
      _builtList.add(Column(
        children: [
          Row(children: [
            Text(
              'enum ',
              style: TextStyle(color: Colors.grey, fontSize: 20),
            ),
            Text(
              enumName,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              ':',
              style: TextStyle(fontSize: 20),
            ),
          ]),
          _singleEnum(_belongEnum.first)
        ],
      ));

      for (var i = 1; i < _belongEnum.length; i++) {
        _builtList.add(_singleEnum(_belongEnum[i]));
        _enumValues.add(_belongEnum[i].name);
      }
    });

    // return _builtList;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clsContent.constants == null ||
        widget.clsContent.constants
                .where((w) => w != null && w.enumValue != null)
                .length ==
            0) {
      return Center(
        child: Text('0 enum in this class'),
      );
    }

//    final _enums
    buildEnums();

    return ScrollablePositionedList.builder(
      padding: EdgeInsets.all(5),
      itemCount: _getPositionCount(),
      itemScrollController: _scrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, index) {
        return _builtList[index];
        // final _enumValues = widget.clsContent.constants
        //     .where((w) => w.enumValue == _enums[index])
        //     .toList();
        // _enumValues.sort((a, b) => a.value.compareTo(b.value));
        //
        // return Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   mainAxisAlignment: MainAxisAlignment.start,
        //   children: <Widget>[
        //     Row(
        //       children: <Widget>[
        //         Text(
        //           'enum ',
        //           style: TextStyle(color: Colors.grey, fontSize: 20),
        //         ),
        //         Text(
        //           _enums[index],
        //           style: TextStyle(fontSize: 20),
        //         ),
        //         Text(
        //           ':',
        //           style: TextStyle(fontSize: 20),
        //         ),
        //       ],
        //     ),
        //     Column(
        //       children: _enumValues.map((c) {
        //         return ListTile(
        //           title: Text(c.name + ' = ' + c.value),
        //           subtitle: DescriptionText(
        //             className: widget.clsContent.name,
        //             content: c.constantText,
        //             onLinkTap: widget.onLinkTap,
        //           ),
        //         );
        //       }).toList(),
        //     ),
        //     SizedBox(
        //       height: 5,
        //     )
        //   ],
        // );
      },
    );
  }
}
