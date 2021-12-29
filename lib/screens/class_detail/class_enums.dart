import 'dart:async';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';

import '../../components/description_text.dart';
import '../../bloc/tap_event_arg.dart';
import '../../models/class_content.dart';
import '../../models/constant.dart';

class ClassEnums extends StatefulWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;
  final Stream<TapEventArg?>? eventStream;

  ClassEnums(
      {Key? key,
      required this.clsContent,
      this.eventStream,
      required this.onLinkTap})
      : super(key: key);

  @override
  _ClassEnumsState createState() => _ClassEnumsState();
}

class _ClassEnumsState extends State<ClassEnums> {
  ItemScrollController? _scrollController;
  ItemPositionsListener? _itemPositionsListener;
  late StreamSubscription<TapEventArg?> _tapSub;

  List<String?> _enumNames = [];

  List<Widget> _builtList = [];
  List<String?> _enumValues = [];

  double propertyIndent = 50;

  @override
  void initState() {
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _enumNames = widget.clsContent.constants!
        .map((c) {
          return c.enumValue;
        })
        .toSet()
        .where((w) => w != null)
        .toList();
    _tapSub = widget.eventStream!.listen((v) {
      try {
        scrollTo(v!);
      } catch (_) {}
    });
    super.initState();
  }

  @override
  void dispose() {
    _tapSub.cancel();
    super.dispose();
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent.name == args.className &&
        args.linkType == LinkType.Enum) {
      final _targetIndex =
          _enumValues.indexWhere((w) => w == args.fieldName.split('.').last);
      if (_targetIndex != -1) {
        _scrollController!.scrollTo(
          curve: Curves.easeInOutCubic,
          index: _targetIndex,
          duration: Duration(milliseconds: 500),
        );
      }
    }
  }

  int _getPositionCount() {
    return widget.clsContent.constants!.where((element) {
      return element.enumValue != null && element.enumValue!.length > 0;
    }).length;
  }

  Widget _singleEnum(Constant clsConstant, {bool appendDivider = false}) {
    return Column(
      children: [
        ListTile(
          title: Text('${clsConstant.name}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("value  "),
                  Text(
                    clsConstant.value.toString(),
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ],
              ),
              SizedBox(height: 10),
              DescriptionText(
                className: widget.clsContent.name!,
                content: clsConstant.constantText!,
                onLinkTap: widget.onLinkTap,
              ),
            ],
          ),
        ),
        appendDivider
            ? Divider(
                color: Colors.blueGrey,
              )
            : Divider(
                indent: propertyIndent,
              ),
      ],
    );
  }

  void buildEnums() {
    _enumNames.sort();
    _enumNames.forEach((enumName) {
      List<Constant> _belongEnum =
          widget.clsContent.constants!.where((element) {
        return element.enumValue != null && element.enumValue == enumName;
      }).toList();
      _belongEnum
          .sort((a, b) => int.parse(a.value!).compareTo(int.tryParse(b.value!)??0));

      _enumValues.add(_belongEnum[0].name);
      _builtList.add(Column(children: [
        Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(children: [
            Row(children: [
              Text(
                'enum ',
                style: TextStyle(color: Colors.grey, fontSize: 20),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.6,
                child: Text(
                  enumName!,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ]),
          ]),
        ),
        _singleEnum(_belongEnum.first),
      ]));

      for (var i = 1; i < _belongEnum.length; i++) {
        _builtList.add(_singleEnum(_belongEnum[i],
            appendDivider: i == _belongEnum.length - 1));
        _enumValues.add(_belongEnum[i].name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clsContent.constants == null ||
        widget.clsContent.constants!.where((w) => w.enumValue != null).length ==
            0) {
      return Center(
        child: Text('0 enum in this class'),
      );
    }

    buildEnums();

    return ScrollablePositionedList.builder(
      // padding: EdgeInsets.all(5),
      itemCount: _getPositionCount(),
      itemScrollController: _scrollController,
      itemPositionsListener: _itemPositionsListener,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [_builtList[index]],
          ),
        );
      },
    );
  }
}
