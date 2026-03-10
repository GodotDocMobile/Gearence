import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/link_text.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';

class ClassMembers extends StatefulWidget {
  final ClassContent? clsContent;

  ClassMembers({Key? key, this.clsContent}) : super(key: key);

  @override
  _ClassMembersState createState() => _ClassMembersState();
}

class _ClassMembersState extends State<ClassMembers>
    with AutomaticKeepAliveClientMixin {
  final ItemScrollController _scrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  List<Member> _members = [];
  Map<String, String> _translationCache = {};

  // Reusable strings to avoid redundant context.translate calls
  String _setterLabel = UIInfoKeys.setterKey;
  String _getterLabel = UIInfoKeys.getterKey;

  @override
  void initState() {
    super.initState();
    _members = widget.clsContent!.members;
    if (mounted) _prepareData();
  }

  void _prepareData() async {
    if (widget.clsContent!.members.isEmpty) return;

    final List<String> translationKeys = [
      UIInfoKeys.setterKey,
      UIInfoKeys.getterKey
    ];

    // 1. Collect all keys for batch translation
    for (var m in _members) {
      if (m.memberText != null) {
        translationKeys.add(m.memberText!);
      }
    }

    final translateResult =
        await Future.microtask(() => batchTranslate(translationKeys));
    setState(() {
      _translationCache = translateResult;
      // Cache static labels
      _setterLabel =
          _translationCache[UIInfoKeys.setterKey] ?? UIInfoKeys.setterKey;
      _getterLabel =
          _translationCache[UIInfoKeys.getterKey] ?? UIInfoKeys.getterKey;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (blocs.tapEventBloc.state.fieldName.isNotEmpty) {
        scrollTo(blocs.tapEventBloc.state);
        blocs.tapEventBloc.reached();
      }
    });
  }

  void scrollTo(TapEventArg args) {
    if (widget.clsContent?.name == args.className &&
        args.propertyType == PropertyType.Property) {
      final index = _members.indexWhere((w) => w.name == args.fieldName);
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
    if (_members.isEmpty) {
      return ZeroContentHint(
        clsContent: widget.clsContent!,
        propertyType: PropertyType.Property,
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) => ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        if (state.className == widget.clsContent!.name &&
            state.propertyType == PropertyType.Property) {
          scrollTo(state);
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
        itemCount: _members.length,
        itemScrollController: _scrollController,
        itemPositionsListener: _itemPositionsListener,
        itemBuilder: (context, index) => _buildMemberTile(_members[index]),
      ),
    );
  }

  Widget _buildMemberTile(Member m) {
    // final theme = Theme.of(context);
    const double propertyIndent = 50;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ListTile(
            title: Text(
              m.name ?? '',
              style: monoOptionalStyle(context,
                  baseStyle: const TextStyle(fontSize: 25)),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('type', style: TextStyle(color: Colors.grey)),
                    const SizedBox(width: 10),
                    LinkText(text: m.type ?? ''),
                  ],
                ),
                const Divider(indent: propertyIndent),

                // Setter Section
                if (m.setter != null && m.setter!.isNotEmpty) ...[
                  Text(_setterLabel,
                      style: const TextStyle(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "${m.setter!}(value)",
                      style: monoOptionalStyle(context),
                    ),
                  ),
                  const Divider(indent: propertyIndent),
                ],

                // Getter Section
                if (m.getter != null && m.getter!.isNotEmpty) ...[
                  Text(_getterLabel,
                      style: const TextStyle(color: Colors.grey)),
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      "${m.getter!}()",
                      style: monoOptionalStyle(context),
                    ),
                  ),
                  const Divider(indent: propertyIndent),
                ],

                DescriptionText(
                  className: widget.clsContent!.name!,
                  content:
                      _translationCache[m.memberText] ?? m.memberText ?? '',
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
