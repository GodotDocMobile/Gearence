import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/argument_table.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/constants/time.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ClassAnnotations extends StatefulWidget {
  final ClassContent? clsContent;
  const ClassAnnotations({Key? key, required this.clsContent})
      : super(key: key);

  @override
  State<ClassAnnotations> createState() => _ClassAnnotationsState();
}

class _ClassAnnotationsState extends State<ClassAnnotations> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<Annotation> _annotations = [];
  Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    if (_annotations.isEmpty && widget.clsContent != null) {
      _annotations = widget.clsContent!.annotations;
      Future.delayed(Duration(milliseconds: dataPrepareDelay), () {
        if (mounted) _prepareData();
      });
    }
  }

  void _prepareData() {
    final List<String> translationKeys = [UIInfoKeys.returnKey];

    // Collect descriptions for batch translation
    for (var a in _annotations) {
      if (a.description != null && a.description!.isNotEmpty) {
        translationKeys.add(a.description!);
      }
    }
    setState(() {
      _translationCache = batchTranslate(translationKeys);
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
        args.propertyType == PropertyType.Annotation) {
      final index = _annotations.indexWhere((w) => w.name == args.fieldName);
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
    if (_annotations.isEmpty) {
      return ZeroContentHint(
        clsContent: widget.clsContent!,
        propertyType: PropertyType.Annotation,
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) => ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        if (state.className == widget.clsContent!.name &&
            state.propertyType == PropertyType.Annotation) {
          scrollTo(state);
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: _annotations.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) =>
            _buildAnnotationTile(_annotations[index]),
      ),
    );
  }

  Widget _buildAnnotationTile(Annotation m) {
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
                    Text(
                        _translationCache[UIInfoKeys.returnKey] ??
                            UIInfoKeys.returnKey,
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(width: 15),
                    Text('void', style: monoOptionalStyle(context)),
                  ],
                ),
                const Divider(),
                // Using m.params for Annotations specifically
                ArgumentTable(arguments: m.params ?? []),
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
