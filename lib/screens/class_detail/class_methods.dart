import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/components/argument_table.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/link_text.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';

class ClassMethods extends StatefulWidget {
  final ClassContent? clsContent;

  ClassMethods({Key? key, this.clsContent}) : super(key: key);

  @override
  _ClassMethodsState createState() => _ClassMethodsState();
}

class _ClassMethodsState extends State<ClassMethods> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<Method> _methods = [];
  Map<String, String> _translationCache = {};

  // Static label cache
  late String _returnLabel;

  @override
  void initState() {
    super.initState();

    if (_methods.isEmpty && widget.clsContent != null) {
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) _prepareData();
      });
    }
  }

  final returnKey = 'return';
  void _prepareData() {
    final methods = widget.clsContent!.methods;
    final List<String> translationKeys = [returnKey]; // Add 'return' to batch

    for (var m in methods) {
      if (m.description != null) {
        translationKeys.add(m.description!);
      }
      // If arguments have descriptions, you'd add them here too
    }

    setState(() {
      _methods = methods;
      _translationCache = batchTranslate(translationKeys);
      _returnLabel = _translationCache[returnKey] ?? returnKey;
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
        args.propertyType == PropertyType.Method) {
      final index = _methods.indexWhere((w) => w.name == args.fieldName);
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
    if (_methods.isEmpty) {
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
          scrollTo(state);
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: _methods.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) => _buildMethodTile(_methods[index]),
      ),
    );
  }

  Widget _buildMethodTile(Method m) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              m.name ?? '',
              softWrap: true,
              style: monoOptionalStyle(context,
                  baseStyle: const TextStyle(fontSize: 25)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_returnLabel,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: m.returnValue?.type == null
                          ? Text('void', style: monoOptionalStyle(context))
                          : LinkText(text: m.returnValue!.type!),
                    ),
                  ],
                ),
                const Divider(),
                ArgumentTable(arguments: m.arguments ?? []),
                DescriptionText(
                  className: widget.clsContent!.name!,
                  content:
                      _translationCache[m.description] ?? m.description ?? '',
                ),
              ],
            ),
          ),
          const Divider(color: Colors.blueGrey)
        ],
      ),
    );
  }
}
