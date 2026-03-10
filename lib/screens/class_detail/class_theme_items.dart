import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/link_text.dart';
// import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';

class ClassThemeItems extends StatefulWidget {
  final ClassContent? clsContent;

  ClassThemeItems({Key? key, this.clsContent}) : super(key: key);

  @override
  _ClassThemeItemsState createState() => _ClassThemeItemsState();
}

class _ClassThemeItemsState extends State<ClassThemeItems> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<ThemeItem> _themeItems = [];
  Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    if (_themeItems.isEmpty && widget.clsContent != null) {
      _prepareData();
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (blocs.tapEventBloc.state.fieldName.isNotEmpty) {
        try {
          scrollTo(blocs.tapEventBloc.state);
        } catch (_) {}
        blocs.tapEventBloc.reached();
      }
    });
  }

  void _prepareData() {
    final items = widget.clsContent!.themeItems;
    final List<String> translationKeys = [];

    // 1. Collect descriptions for batch translation
    for (var t in items) {
      if (t.description != null && t.description!.isNotEmpty) {
        translationKeys.add(t.description!);
      }
    }

    // 2. Batch fetch and assign
    _themeItems = items;
    _translationCache = batchTranslate(translationKeys);
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent?.name == args.className &&
        args.propertyType == PropertyType.ThemeItem) {
      final index = _themeItems.indexWhere((w) => w.name == args.fieldName);
      if (index != -1) {
        _scrollController.scrollTo(
          curve: Curves.easeInOutCubic,
          index: index,
          duration: const Duration(milliseconds: 500),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_themeItems.isEmpty) {
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
          scrollTo(state);
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: _themeItems.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) =>
            _buildThemeItemTile(_themeItems[index]),
      ),
    );
  }

  Widget _buildThemeItemTile(ThemeItem t) {
    return Column(
      children: [
        ListTile(
          title: Text(
            t.name ?? '',
            style: monoOptionalStyle(context),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("type"),
                  const SizedBox(width: 10),
                  LinkText(text: t.type ?? ''),
                ],
              ),
              const SizedBox(height: 10.0),

              // Only render DescriptionText if a description exists
              if (t.description != null && t.description!.isNotEmpty)
                DescriptionText(
                  className: widget.clsContent!.name!,
                  content: _translationCache[t.description] ?? t.description!,
                ),
            ],
          ),
        ),
        const Divider(color: Colors.blueGrey),
      ],
    );
  }
}
