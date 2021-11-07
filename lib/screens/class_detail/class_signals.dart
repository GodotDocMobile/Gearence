import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../components/description_text.dart';
import '../../bloc/tap_event_arg.dart';
import '../../models/class_content.dart';
import '../../constants/class_db.dart';
import '../../constants/colors.dart';

class ClassSignals extends StatefulWidget {
  final ClassContent? clsContent;
  final Function(TapEventArg args) onLinkTap;
  final Stream<TapEventArg?>? eventStream;

  ClassSignals(
      {Key? key, this.clsContent, this.eventStream, required this.onLinkTap})
      : super(key: key);

  @override
  _ClassSignalsState createState() => _ClassSignalsState();
}

class _ClassSignalsState extends State<ClassSignals> {
  ItemScrollController? _scrollController;

  ItemPositionsListener? _itemPositionsListener;

  double propertyIndent = 50;

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    widget.eventStream!.listen((v) {
      try {
        scrollTo(v!);
      } catch (_) {}
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent!.name == args.className &&
        args.linkType == LinkType.Signal) {
      final _targetIndex = widget.clsContent!.signals!
          .indexWhere((w) => w.name == args.fieldName);
      if (_targetIndex != -1) {
        _scrollController!.scrollTo(
          curve: Curves.easeInOutCubic,
          index: _targetIndex,
          duration: Duration(milliseconds: 500),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clsContent!.signals == null ||
        widget.clsContent!.signals!.length == 0) {
      return Center(
        child: Text('0 signal in thie class'),
      );
    }

    return ScrollablePositionedList.builder(
        itemCount: widget.clsContent!.signals!.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final s = widget.clsContent!.signals![index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    s.name!,
                    style: TextStyle(
                      fontSize: 25,
//                    color: godotColor,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: s.arguments!.map((e) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  ClassDB().getDB().any(
                                          (element) => element.name == e.type)
                                      ? InkWell(
                                          child: Text(
                                            e.type!,
                                            style: TextStyle(
                                              color: godotColor,
                                            ),
                                          ),
                                          onTap: () {
                                            TapEventArg _arg = TapEventArg(
                                                className: e.type!,
                                                linkType: LinkType.Class,
                                                fieldName: '');
                                            widget.onLinkTap(_arg);
                                          },
                                        )
                                      : Text(e.type!),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    e.name!,
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                      Divider(
                        indent: propertyIndent,
                      ),
                      DescriptionText(
                        className: widget.clsContent!.name!,
                        content: s.description!,
                        onLinkTap: widget.onLinkTap,
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: Colors.blueGrey,
                )
              ],
            ),
          );
        });
  }
}
