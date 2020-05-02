import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassMethods extends StatefulWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;
  final Stream<TapEventArg> eventStream;

  ClassMethods(
      {Key key, this.clsContent, this.eventStream, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  _ClassMethodsState createState() => _ClassMethodsState();
}

class _ClassMethodsState extends State<ClassMethods> {
  ItemScrollController _scrollController;
  ItemPositionsListener _itemPositionsListener;
  int _scrollIndex = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    widget.eventStream.listen((v) {
      scrollTo(v);
    });
//    _itemPositionsListener.itemPositions.addListener(() {
//      if (_scrollIndex !=
//          _itemPositionsListener.itemPositions.value.first.index) {
//        _scrollIndex = _itemPositionsListener.itemPositions.value.first.index;
//
//        if (StoredValues.scrollIndexes.length > 0) {
//          StoredValues.scrollIndexes.removeLast();
//        }
//
//        StoredValues.scrollIndexes.add(_scrollIndex);
//        print(StoredValues.scrollIndexes);
////        print('scroll index: ' + _scrollIndex.toString());
//      }
////      print(_itemPositionsListener.itemPositions.value.first.index);
//    });
  }

//  @override
//  void dispose() {
//    // TODO: implement dispose
//    print('disposing');
//    super.dispose();
//  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent.name == args.className &&
        args.linkType == LinkType.Method) {
      final _targetIndex =
          widget.clsContent.methods.indexWhere((w) => w.name == args.fieldName);
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
    if (widget.clsContent.methods == null ||
        widget.clsContent.methods.length == 0) {
      return Center(
        child: Text('0 method in this class'),
      );
    }

    return ScrollablePositionedList.builder(
        itemCount: widget.clsContent.methods.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final m = widget.clsContent.methods[index];
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
                  className: widget.clsContent.name,
                  content: m.description,
                  onLinkTap: widget.onLinkTap,
                ),
              ],
            ),
          );
        });
  }
}
