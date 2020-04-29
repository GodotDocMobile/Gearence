import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassMembers extends StatefulWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;
  final Stream<TapEventArg> eventStream;

  ClassMembers(
      {Key key, this.clsContent, this.eventStream, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  _ClassMembersState createState() => _ClassMembersState();
}

class _ClassMembersState extends State<ClassMembers> {
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
        args.linkType == LinkType.Member) {
      final _targetIndex =
          widget.clsContent.members.indexWhere((w) => w.name == args.fieldName);
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
    if (widget.clsContent.members == null ||
        widget.clsContent.members.length == 0) {
      return Center(
        child: Text('0 memeber in this class'),
      );
    }

    return ScrollablePositionedList.builder(
        itemCount: widget.clsContent.members.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final m = widget.clsContent.members[index];
          return Column(
            children: <Widget>[
              ListTile(
                leading: Text(m.type),
                title: Text(
                  m.name,
                  style: TextStyle(fontSize: 25, color: godotColor),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    m.setter == null || m.setter.length == 0
                        ? SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'setter',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  m.setter + "(value)",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                    m.getter == null || m.getter.length == 0
                        ? SizedBox()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'getter',
                                style: TextStyle(color: Colors.grey),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Text(
                                  m.getter + "()",
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                    DescriptionText(
                      className: widget.clsContent.name,
                      content: m.memberText,
                      onLinkTap: widget.onLinkTap,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          );
        });
  }
}
