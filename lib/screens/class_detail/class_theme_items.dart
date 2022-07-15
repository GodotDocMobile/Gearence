import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/link_text.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';

class ClassThemeItems extends StatefulWidget {
  final ClassContent? clsContent;

  ClassThemeItems({
    Key? key,
    this.clsContent,
  }) : super(key: key);

  @override
  _ClassThemeItemsState createState() => _ClassThemeItemsState();
}

class _ClassThemeItemsState extends State<ClassThemeItems> {
  ItemScrollController? _scrollController;
  ItemPositionsListener? _itemPositionsListener;

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
        args.propertyType == PropertyType.ThemeItem) {
      final _targetIndex = widget.clsContent!.themeItems!
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
    if (widget.clsContent!.themeItems == null ||
        widget.clsContent!.themeItems!.length == 0) {
      return ZeroContentHint(
        clsContent: widget.clsContent!,
        propertyType: PropertyType.ThemeItem,
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) => ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        if (state.className == widget.clsContent!.name &&
            state.propertyType == PropertyType.ThemeItem) {
          try {
            scrollTo(blocs.tapEventBloc.state);
          } catch (_) {}
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: widget.clsContent!.themeItems!.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final t = widget.clsContent!.themeItems![index];
          return Column(children: [
            ListTile(
              title: Text(
                t.name!,
                style: monoOptionalStyle(context),
              ),
              subtitle: Row(
                children: [
                  Text("type"),
                  SizedBox(
                    width: 10,
                  ),
                  LinkText(
                    text: t.type!,
                    // onLinkTap: widget.onLinkTap,
                  )
                ],
              ),
            ),
            Divider(color: Colors.blueGrey)
          ]);
        },
      ),
    );
  }
}
