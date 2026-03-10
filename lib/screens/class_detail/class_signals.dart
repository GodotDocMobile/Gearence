import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/link_text.dart';
import 'package:godotclassreference/components/description_text.dart';
// import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';

class ClassSignals extends StatefulWidget {
  final ClassContent? clsContent;

  ClassSignals({Key? key, this.clsContent}) : super(key: key);

  @override
  _ClassSignalsState createState() => _ClassSignalsState();
}

class _ClassSignalsState extends State<ClassSignals>
    with AutomaticKeepAliveClientMixin {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<Signal> _signals = [];
  Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    if (_signals.isEmpty && widget.clsContent != null) {
      _signals = widget.clsContent!.signals;
      if (mounted) _prepareData();
    }
  }

  void _prepareData() async {
    if (widget.clsContent!.signals.isEmpty) return;

    final List<String> translationKeys = [];

    // Collect signal descriptions for batch translation
    for (var s in _signals) {
      if (s.description != null && s.description!.isNotEmpty) {
        translationKeys.add(s.description!);
      }
    }

    final translateResult =
        await Future.microtask(() => batchTranslate(translationKeys));
    setState(() {
      _translationCache = translateResult;
    });
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
    if (widget.clsContent?.name == args.className &&
        args.propertyType == PropertyType.Signal) {
      final index = _signals.indexWhere((w) => w.name == args.fieldName);
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
    super.build(context);
    if (_signals.isEmpty) {
      return ZeroContentHint(
        clsContent: widget.clsContent!,
        propertyType: PropertyType.Signal,
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) => ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        if (state.className == widget.clsContent!.name &&
            state.propertyType == PropertyType.Signal) {
          scrollTo(state);
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: _signals.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) => _buildSignalTile(_signals[index]),
      ),
    );
  }

  Widget _buildSignalTile(Signal s) {
    const double propertyIndent = 50;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              s.name ?? '',
              style: monoOptionalStyle(context,
                  baseStyle: const TextStyle(fontSize: 25)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Arguments List
                if (s.arguments != null && s.arguments!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: s.arguments!
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2.0),
                                child: Row(
                                  children: [
                                    LinkText(text: e.type ?? ''),
                                    const SizedBox(width: 10),
                                    Text(e.name ?? '',
                                        style: const TextStyle(fontSize: 15)),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                const Divider(indent: propertyIndent),
                DescriptionText(
                  className: widget.clsContent!.name!,
                  content:
                      _translationCache[s.description] ?? s.description ?? '',
                ),
              ],
            ),
          ),
          const Divider(color: Colors.blueGrey),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
