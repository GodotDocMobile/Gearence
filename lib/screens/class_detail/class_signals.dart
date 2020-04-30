import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassSignals extends StatefulWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;
  final Stream<TapEventArg> eventStream;

  ClassSignals(
      {Key key, this.clsContent, this.eventStream, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  _ClassSignalsState createState() => _ClassSignalsState();
}

class _ClassSignalsState extends State<ClassSignals> {
  ItemScrollController _scrollController;

  ItemPositionsListener _itemPositionsListener;

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    widget.eventStream.listen((v) {
      scrollTo(v);
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent.name == args.className &&
        args.linkType == LinkType.Signal) {
      final _targetIndex =
          widget.clsContent.signals.indexWhere((w) => w.name == args.fieldName);
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
    if (widget.clsContent.signals == null ||
        widget.clsContent.signals.length == 0) {
      return Center(
        child: Text('0 signal in thie class'),
      );
    }

    return ScrollablePositionedList.builder(
        itemCount: widget.clsContent.signals.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final s = widget.clsContent.signals[index];
          return ListTile(
            title: Text(
              s.name +
                  s.arguments.map((a) {
                    return a.type + " " + a.name;
                  }).toString(),
            ),
            subtitle: DescriptionText(
              className: widget.clsContent.name,
              content: s.description,
              onLinkTap: widget.onLinkTap,
            ),
          );
        });
  }
}
