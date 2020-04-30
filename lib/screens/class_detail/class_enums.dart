import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
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

  List<String> _enums = List<String>();

  @override
  void initState() {
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _enums = widget.clsContent.constants
        .map((c) {
          return c.enumValue;
        })
        .toSet()
        .where((w) => w != null)
        .toList();
    super.initState();
    widget.eventStream.listen((v) {
      scrollTo(v);
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent.name == args.className &&
        args.linkType == LinkType.Enum) {
      final _targetIndex = _enums.indexWhere((w) => w == args.fieldName);
      if (_targetIndex != -1) {
        _scrollController.scrollTo(
          curve: Curves.easeInOutCubic,
          index: _targetIndex,
          duration: Duration(milliseconds: 500),
        );
      }
    }
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

    return ScrollablePositionedList.builder(
      padding: EdgeInsets.all(5),
      itemCount: _enums.length,
      itemScrollController: _scrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, index) {
        final _enumValues = widget.clsContent.constants
            .where((w) => w.enumValue == _enums[index])
            .toList();
        _enumValues.sort((a, b) => a.value.compareTo(b.value));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text(
                  'enum ',
                  style: TextStyle(color: Colors.grey, fontSize: 20),
                ),
                Text(
                  _enums[index],
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  ':',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
            Column(
              children: _enumValues.map((c) {
                return ListTile(
                  title: Text(c.name + ' = ' + c.value),
                  subtitle: DescriptionText(
                    className: widget.clsContent.name,
                    content: c.constantText,
                    onLinkTap: widget.onLinkTap,
                  ),
                );
              }).toList(),
            ),
            SizedBox(
              height: 5,
            )
          ],
        );
      },
    );
  }
}
