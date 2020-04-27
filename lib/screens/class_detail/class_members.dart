import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassMembers extends StatelessWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  ClassMembers({Key key, this.clsContent, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.members == null || clsContent.members.length == 0) {
      return Center(
        child: Text('0 memeber in this class'),
      );
    }

    return ScrollablePositionedList.builder(
        itemCount: clsContent.members.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final m = clsContent.members[index];
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
                      className: clsContent.name,
                      content: m.memberText,
                      onLinkTap: onLinkTap,
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
