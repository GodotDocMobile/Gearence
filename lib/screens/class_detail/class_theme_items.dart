import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../bloc/tap_event_bloc.dart';
import '../../components/link_text.dart';
import '../../bloc/tap_event_arg.dart';
import '../../constants/stored_values.dart';
import '../../models/class_content.dart';

class ClassThemeItems extends StatefulWidget {
  final ClassContent? clsContent;
  final Function(TapEventArg args) onLinkTap;

  // final Stream<TapEventArg?>? eventStream;

  ClassThemeItems({
    Key? key,
    this.clsContent,
    // this.eventStream,
    required this.onLinkTap,
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
    // widget.eventStream!.listen((v) {
    //   try {
    //     scrollTo(v!);
    //   } catch (_) {}
    // });
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (storedValues.tapEventBloc.state.fieldName.isNotEmpty) {
        try {
          scrollTo(storedValues.tapEventBloc.state);
        } catch (_) {}
        storedValues.tapEventBloc.reached();
      }
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent!.name == args.className &&
        args.linkType == LinkType.ThemeItem) {
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
      return Center(
        child: Text('0 theme item in this class'),
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: storedValues.tapEventBloc,
      listener: (context, state) {
        if (state.className == widget.clsContent!.name &&
            state.linkType == LinkType.ThemeItem) {
          try {
            scrollTo(storedValues.tapEventBloc.state);
          } catch (_) {}
          storedValues.tapEventBloc.reached();
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
              title: Text(t.name!),
              subtitle: Row(
                children: [
                  Text("type"),
                  SizedBox(
                    width: 10,
                  ),
                  LinkText(text: t.type!, onLinkTap: widget.onLinkTap)
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
