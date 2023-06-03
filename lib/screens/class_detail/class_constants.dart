import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/models/constant.dart';
import 'package:godotclassreference/bloc/blocs.dart';

class ClassConstants extends StatefulWidget {
  final ClassContent? clsContent;

  ClassConstants({Key? key, this.clsContent}) : super(key: key);

  @override
  _ClassConstantsState createState() => _ClassConstantsState();
}

class _ClassConstantsState extends State<ClassConstants> {
  ItemScrollController? _scrollController;
  ItemPositionsListener? _itemPositionsListener;

  List<Constant> _onlyConstants = [];

  double propertyIndent = 50;

  @override
  void initState() {
    super.initState();
    _scrollController = ItemScrollController();
    _itemPositionsListener = ItemPositionsListener.create();
    _onlyConstants =
        widget.clsContent!.constants.where((w) => w.enumValue == null).toList();
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
        args.propertyType == PropertyType.Constant) {
      final _targetIndex =
          _onlyConstants.indexWhere((w) => w.name == args.fieldName);
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
    if (widget.clsContent!.constants.where((w) => w.enumValue == null).length ==
        0) {
      return ZeroContentHint(
        clsContent: widget.clsContent!,
        propertyType: PropertyType.Constant,
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) => ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        if (state.className == widget.clsContent!.name &&
            state.propertyType == PropertyType.Constant) {
          try {
            scrollTo(blocs.tapEventBloc.state);
          } catch (_) {}
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
          itemCount: _onlyConstants.length,
          itemScrollController: _scrollController,
          itemPositionsListener: _itemPositionsListener,
          itemBuilder: (context, index) {
            final c = _onlyConstants[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(children: [
                ListTile(
                  title: Container(
                    width: MediaQuery.of(context).size.width * 0.88,
                    child: Text(
                      c.name!,
                      style: monoOptionalStyle(context),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("value  "),
                          Text(
                            c.value.toString(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      Divider(
                        indent: propertyIndent,
                      ),
                      DescriptionText(
                        className: widget.clsContent!.name!,
                        content: c.constantText!,
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
