import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/constants/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassMethods extends StatelessWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;

  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  ClassMethods({Key key, this.clsContent, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    if (clsContent.methods == null || clsContent.methods.length == 0) {
      return Center(
        child: Text('0 method in this class'),
      );
    }

    final _toRtn = ScrollablePositionedList.builder(
        itemCount: clsContent.methods.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final m = clsContent.methods[index];
          return ListTile(
            leading: Text(
              m.returnValue == null ? 'void' : m.returnValue.type,
            ),
            title: Text(
              m.name,
              softWrap: true,
              style: TextStyle(fontSize: 25, color: godotColor),
            ),
            subtitle: Column(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    (m.arguments != null && m.arguments.length > 0
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'arguments:',
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: m.arguments.map((a) {
                                        return Text(
                                          a.type,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: m.arguments.map((a) {
                                        return Text(
                                          a.name,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: m.arguments.map((a) {
                                        return a.defaultValue == null
                                            ? Text('')
                                            : Row(
                                                children: <Widget>[
                                                  Text(
                                                    ' = ',
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                  Text(
                                                    a.defaultValue,
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  )
                                                ],
                                              );
                                      }).toList(),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        : SizedBox()),
                    Row(
                      children: <Widget>[
                        m.qualifiers == null
                            ? SizedBox()
                            : Row(
                                children: <Widget>[
                                  Text(
                                    'qualifiers ',
                                  ),
                                  Text(
                                    m.qualifiers,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ],
                ),
                DescriptionText(
                  className: clsContent.name,
                  content: m.description,
                  onLinkTap: onLinkTap,
                ),
              ],
            ),
          );
        });

    return _toRtn;
  }
}
