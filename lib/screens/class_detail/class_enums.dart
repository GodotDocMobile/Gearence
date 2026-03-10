import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/constants/time.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';

import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';

// 1. Helper class to represent a flat row in the ListView
enum EnumItemType { header, member }

class EnumDisplayItem {
  final EnumItemType type;
  final String? enumName; // For headers
  final Constant? constant; // For members
  final bool isLastInGroup; // For drawing correct dividers

  EnumDisplayItem.header(this.enumName)
      : type = EnumItemType.header,
        constant = null,
        isLastInGroup = false;
  EnumDisplayItem.member(this.constant, {this.isLastInGroup = false})
      : type = EnumItemType.member,
        enumName = null;
}

class ClassEnums extends StatefulWidget {
  final ClassContent clsContent;

  ClassEnums({Key? key, required this.clsContent}) : super(key: key);

  @override
  _ClassEnumsState createState() => _ClassEnumsState();
}

class _ClassEnumsState extends State<ClassEnums> {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<EnumDisplayItem> _displayItems = [];
  Map<String, String> _translationCache = {};

  @override
  void initState() {
    super.initState();
    // 2. Perform all grouping, sorting, and Isar Plus translation in one pass
    Future.delayed(Duration(milliseconds: dataPrepareDelay), () {
      if (mounted) _prepareData();
    });
  }

  void _prepareData() {
    final Map<String, List<Constant>> groups = {};
    final List<EnumDisplayItem> flattened = [];
    final List<String> translationKeys = [];
    // Grouping
    for (var c in widget.clsContent.constants) {
      final enumName = c.enumValue;
      if (enumName != null && enumName.isNotEmpty) {
        groups.putIfAbsent(enumName, () => []).add(c);

        // Cache Isar Plus Translation
        if (c.constantText != null) {
          translationKeys.add(c.constantText!);
        }
      }
    }

    // Sorting Enum Names
    final sortedEnumNames = groups.keys.toList()..sort();

    // Flattening for the Builder
    for (var enumName in sortedEnumNames) {
      final members = groups[enumName]!;
      members.sort((a, b) =>
          int.parse(a.value ?? "0").compareTo(int.parse(b.value ?? "0")));

      flattened.add(EnumDisplayItem.header(enumName));

      for (int i = 0; i < members.length; i++) {
        flattened.add(EnumDisplayItem.member(members[i],
            isLastInGroup: i == members.length - 1));
      }
    }

    setState(() {
      _displayItems = flattened;
    });
    setState(() {
      _translationCache = batchTranslate(translationKeys);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (blocs.tapEventBloc.state.fieldName.isNotEmpty) {
        scrollTo(blocs.tapEventBloc.state);
        blocs.tapEventBloc.reached();
      }
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent.name == args.className &&
        args.propertyType == PropertyType.Enum) {
      final targetFieldName = args.fieldName.split('.').last;

      // 3. Finding index is now a simple list search
      final index = _displayItems.indexWhere((item) =>
          item.type == EnumItemType.member &&
          item.constant?.name == targetFieldName);

      if (index != -1) {
        _scrollController.scrollTo(
          curve: Curves.easeInOutCubic,
          index: index,
          duration: Duration(milliseconds: 500),
        );
      }
    }
  }

  Widget _buildHeader(String name) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Row(children: [
        Text('enum ', style: TextStyle(color: Colors.grey, fontSize: 20)),
        Expanded(
          child: Text(
            name,
            style:
                monoOptionalStyle(context, baseStyle: TextStyle(fontSize: 20)),
          ),
        ),
      ]),
    );
  }

  Widget _buildMember(Constant clsConstant, {bool appendDivider = false}) {
    return Column(
      children: [
        ListTile(
          title:
              Text(clsConstant.name ?? '', style: monoOptionalStyle(context)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("value  "),
                  Text(
                    clsConstant.value.toString(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              SizedBox(height: 10),
              DescriptionText(
                className: widget.clsContent.name!,
                content: _translationCache[clsConstant.constantText] ??
                    clsConstant.constantText ??
                    '',
              ),
            ],
          ),
        ),
        Divider(
          indent: appendDivider ? 0 : 50,
          color: appendDivider ? Colors.blueGrey : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_displayItems.isEmpty) {
      return ZeroContentHint(
        clsContent: widget.clsContent,
        propertyType: PropertyType.Enum,
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) => ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        if (state.className == widget.clsContent.name &&
            state.propertyType == PropertyType.Enum) {
          scrollTo(state);
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: _displayItems.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) {
          final item = _displayItems[index];
          if (item.type == EnumItemType.header) {
            return _buildHeader(item.enumName!);
          } else {
            return _buildMember(item.constant!,
                appendDivider: item.isLastInGroup);
          }
        },
      ),
    );
  }
}
