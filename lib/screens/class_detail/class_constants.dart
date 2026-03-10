import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/bloc/blocs.dart';

class ClassConstants extends StatefulWidget {
  final ClassContent? clsContent;

  ClassConstants({Key? key, this.clsContent}) : super(key: key);

  @override
  _ClassConstantsState createState() => _ClassConstantsState();
}

class _ClassConstantsState extends State<ClassConstants>
    with AutomaticKeepAliveClientMixin {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<Constant> _onlyConstants = [];
  Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    _onlyConstants = widget.clsContent!.constants
        .where((w) => w.enumValue == null || w.enumValue!.isEmpty)
        .toList();
    _prepareData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (blocs.tapEventBloc.state.fieldName.isNotEmpty) {
        scrollTo(blocs.tapEventBloc.state);
        blocs.tapEventBloc.reached();
      }
    });
  }

  void _prepareData() async {
    if (widget.clsContent!.constants.isEmpty) return;

    // 2. Batch collect translation keys
    final List<String> translationKeys = [];
    for (var c in _onlyConstants) {
      if (c.constantText != null) {
        translationKeys.add(c.constantText!);
      }
    }

    final translateResult =
        await Future.microtask(() => batchTranslate(translationKeys));
    setState(() {
      _translationCache = translateResult;
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent?.name == args.className &&
        args.propertyType == PropertyType.Constant) {
      final targetIndex =
          _onlyConstants.indexWhere((w) => w.name == args.fieldName);
      if (targetIndex != -1) {
        _scrollController.scrollTo(
          curve: Curves.easeInOutCubic,
          index: targetIndex,
          duration: const Duration(milliseconds: 500),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Check against our prepared list instead of re-filtering in build
    if (_onlyConstants.isEmpty) {
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
          scrollTo(state);
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: _onlyConstants.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final c = _onlyConstants[index];
          return _buildConstantTile(c);
        },
      ),
    );
  }

  Widget _buildConstantTile(Constant c) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              c.name ?? '',
              style: monoOptionalStyle(context),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("value  "),
                    Text(
                      c.value.toString(),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
                const Divider(indent: 50),
                DescriptionText(
                  className: widget.clsContent!.name!,
                  // Use the cache! O(1) RAM lookup.
                  content:
                      _translationCache[c.constantText] ?? c.constantText ?? '',
                ),
              ],
            ),
          ),
          const Divider(color: Colors.blueGrey)
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
