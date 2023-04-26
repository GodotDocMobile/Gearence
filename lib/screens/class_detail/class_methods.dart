import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/components/argument_table.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/link_text.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';

class ClassMethods extends StatefulWidget {
  final ClassContent? clsContent;

  ClassMethods({
    Key? key,
    this.clsContent,
  }) : super(key: key);

  @override
  _ClassMethodsState createState() => _ClassMethodsState();
}

class _ClassMethodsState extends State<ClassMethods> {
  ItemScrollController? _scrollController;
  ItemPositionsListener? _itemPositionsListener;

  double propertyIndent = 50;

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (blocs.tapEventBloc.state.fieldName.isNotEmpty) {
        try {
          scrollTo(blocs.tapEventBloc.state);
        } catch (_) {}
        blocs.tapEventBloc.reached();
      }
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent!.name == args.className &&
        args.propertyType == PropertyType.Method) {
      final _targetIndex = widget.clsContent!.methods
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
    if (widget.clsContent!.methods.length == 0) {
      return ZeroContentHint(
        clsContent: widget.clsContent!,
        propertyType: PropertyType.Method,
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) => ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        if (state.className == widget.clsContent!.name &&
            state.propertyType == PropertyType.Method) {
          try {
            scrollTo(blocs.tapEventBloc.state);
          } catch (_) {}
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
          itemCount: widget.clsContent!.methods.length,
          itemScrollController: _scrollController,
          itemPositionsListener: _itemPositionsListener,
          itemBuilder: (context, index) {
            final m = widget.clsContent!.methods[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                ListTile(
                  title: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: Text(
                      m.name!,
                      softWrap: true,
                      style: monoOptionalStyle(
                        context,
                        baseStyle: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(
                          'return',
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: m.returnValue == null
                              ? Text(
                                  'void',
                                  style: monoOptionalStyle(context),
                                )
                              : LinkText(
                                  text: m.returnValue!.type!,
                                  // onLinkTap: widget.onLinkTap,
                                ),
                        ),
                      ]),
                      Divider(),
                      ArgumentTable(arguments: m.arguments!),
                      DescriptionText(
                        className: widget.clsContent!.name!,
                        content: m.description!,
                        // onLinkTap: widget.onLinkTap,
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.blueGrey)
              ]),
            );
          }),
    );
  }
}
