import 'package:flutter/material.dart';
import 'package:godotclassreference/bloc/theme_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../components/description_text.dart';
import '../../constants/class_db.dart';
import '../../constants/colors.dart';
import '../../bloc/tap_event_arg.dart';
import '../../constants/stored_values.dart';
import '../../models/class_content.dart';

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

  bool _isDarkMode;

  double propertyIndent = 50;

  @override
  void initState() {
    super.initState();
    _isDarkMode = StoredValues().themeChange.isDark;
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    widget.eventStream.listen((v) {
      try {
        scrollTo(v);
      } catch (_) {}
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
        child: Text('0 member in this class'),
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
                title: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Text(
                    m.name,
                    style: TextStyle(
                      fontSize: 25,
//                    color: godotColor,
                    ),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(
                          'type',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        ClassDB()
                                .getDB()
                                .any((element) => element.name == m.type)
                            ? InkWell(
                                child: Text(
                                  m.type,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: godotColor,
                                  ),
                                ),
                                onTap: () {
                                  TapEventArg _arg = TapEventArg(
                                      className: m.type,
                                      linkType: LinkType.Class,
                                      fieldName: '');
                                  widget.onLinkTap(_arg);
                                },
                              )
                            : Text(
                                m.type,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                      ],
                    ),
                    Divider(
                      indent: propertyIndent,
                    ),
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
                                  style: TextStyle(
                                      color: _isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                              Divider(
                                indent: propertyIndent,
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
                                  style: TextStyle(
                                      color: _isDarkMode
                                          ? Colors.white
                                          : Colors.black),
                                ),
                              ),
                              Divider(
                                indent: propertyIndent,
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
              Divider(
                color: Colors.blueGrey,
              )
            ],
          );
        });
  }
}
