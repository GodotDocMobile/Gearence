import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'package:godotclassreference/theme/themes.dart';
import 'package:godotclassreference/components/link_text.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/components/zero_content_hint.dart';

class ClassMembers extends StatefulWidget {
  final ClassContent? clsContent;

  ClassMembers({
    Key? key,
    this.clsContent,
  }) : super(key: key);

  @override
  _ClassMembersState createState() => _ClassMembersState();
}

class _ClassMembersState extends State<ClassMembers> {
  ItemScrollController? _scrollController;
  ItemPositionsListener? _itemPositionsListener;

  bool _isDarkMode = storedValues.isDarkTheme;

  double propertyIndent = 50;

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
        args.propertyType == PropertyType.Member) {
      final _targetIndex = widget.clsContent!.members!
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
    if (widget.clsContent!.members == null ||
        widget.clsContent!.members!.length == 0) {
      return ZeroContentHint(
        clsContent: widget.clsContent!,
        propertyType: PropertyType.Member,
      );
    }

    return BlocListener<TapEventBloc, TapEventArg>(
      bloc: blocs.tapEventBloc,
      listenWhen: (previous, current) => ModalRoute.of(context)!.isCurrent,
      listener: (context, state) {
        if (state.className == widget.clsContent!.name &&
            state.propertyType == PropertyType.Member) {
          try {
            scrollTo(blocs.tapEventBloc.state);
          } catch (_) {}
          blocs.tapEventBloc.reached();
        }
      },
      child: ScrollablePositionedList.builder(
          itemCount: widget.clsContent!.members!.length,
          itemScrollController: _scrollController,
          itemPositionsListener: _itemPositionsListener,
          itemBuilder: (context, index) {
            final m = widget.clsContent!.members![index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Text(
                        m.name!,
                        style: monoOptionalStyle(
                          context,
                          baseStyle: TextStyle(
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: [
                            Text(
                              'type',
                              style: TextStyle(color: Colors.grey),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            LinkText(
                              text: m.type!,
                              // onLinkTap: widget.onLinkTap,
                            )
                          ],
                        ),
                        Divider(
                          indent: propertyIndent,
                        ),
                        m.setter == null || m.setter!.length == 0
                            ? SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'setter',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Text(
                                      m.setter! + "(value)",
                                      style: monoOptionalStyle(
                                        context,
                                        baseStyle: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    indent: propertyIndent,
                                  ),
                                ],
                              ),
                        m.getter == null || m.getter!.length == 0
                            ? SizedBox()
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'getter',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
                                    child: Text(
                                      m.getter! + "()",
                                      style: monoOptionalStyle(
                                        context,
                                        baseStyle: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.white
                                                : Colors.black),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    indent: propertyIndent,
                                  ),
                                ],
                              ),
                        DescriptionText(
                          className: widget.clsContent!.name!,
                          content: m.memberText!,
                          // onLinkTap: widget.onLinkTap,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: Colors.blueGrey,
                  )
                ],
              ),
            );
          }),
    );
  }
}
