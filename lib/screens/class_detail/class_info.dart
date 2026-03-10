import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/keys.dart';
import 'package:godotclassreference/constants/time.dart';
import 'package:godotclassreference/helpers/trim_translate.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/theme/default.dart';
import 'package:isar_plus/isar_plus.dart';

class ClassInfo extends StatefulWidget {
  final ClassContent? clsContent;

  ClassInfo({Key? key, this.clsContent}) : super(key: key);

  @override
  State<ClassInfo> createState() => _ClassInfoState();
}

class _ClassInfoState extends State<ClassInfo> {
  Map<String, String> translationCache = {};

  String childClasses = '';

  @override
  void initState() {
    super.initState();
    childClasses = GetIt.I<Isar>(instanceName: MetadataKeys.docsIsarKey)
        .classContents
        .where()
        .inheritsEqualTo(widget.clsContent!.name)
        .findAll()
        .map((c) => '[' + c.name! + ']')
        .toList()
        .join(' , ');
    Future.delayed(Duration(milliseconds: dataPrepareDelay), () {
      if (mounted) _prepareData();
    });
  }

  void _prepareData() {
    setState(() {
      translationCache = batchTranslate([
        UIInfoKeys.inherits,
        UIInfoKeys.inheritedBy,
        UIInfoKeys.briefDescription,
        widget.clsContent!.briefDescription ?? "",
        UIInfoKeys.version,
        UIInfoKeys.category,
        UIInfoKeys.description,
        widget.clsContent!.description ?? "",
        UIInfoKeys.demos,
        UIInfoKeys.tutorials
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        //inherit chain
        ExcludeSemantics(
          child: Text(
            translationCache[UIInfoKeys.inherits] ?? UIInfoKeys.inherits,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        DescriptionText(
          className: widget.clsContent!.name!,
          content: widget.clsContent!.inheritChain == null
              ? ''
              : widget.clsContent!.inheritChain!,
          descriptionUsedBy: DescriptionUsedBy.Inherits,
          // onLinkTap: onLinkTap,
        ),
        SizedBox(
          height: 10,
        ),

        //child classes
        ExcludeSemantics(
          child: Text(
            translationCache[UIInfoKeys.inheritedBy] ?? UIInfoKeys.inheritedBy,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        DescriptionText(
          className: widget.clsContent!.name!,
          content: childClasses,
          descriptionUsedBy: DescriptionUsedBy.ChildClasses,
          // onLinkTap: onLinkTap,
        ),
        SizedBox(
          height: 10,
        ),

        //brief_description
        ExcludeSemantics(
          child: Text(
            // 'Brief Description:',
            translationCache[UIInfoKeys.briefDescription] ??
                UIInfoKeys.briefDescription,
            style: TextStyle(color: Colors.grey),
          ),
        ),
        DescriptionText(
          className: widget.clsContent!.name!,
          content: translationCache[widget.clsContent!.briefDescription] ??
              widget.clsContent!.briefDescription!,
          descriptionUsedBy: DescriptionUsedBy.BriefDescription,
          // onLinkTap: onLinkTap,
        ),
        SizedBox(
          height: 10,
        ),

        //version
        (widget.clsContent!.version == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // 'Version:',
                    translationCache[UIInfoKeys.version] ?? UIInfoKeys.version,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 0, 0),
                      child: Text(widget.clsContent!.version!)),
                ],
              )),
        SizedBox(
          height: 10,
        ),

        //category
        (widget.clsContent!.category == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    // 'Category:',
                    translationCache[UIInfoKeys.category] ??
                        UIInfoKeys.category,
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 0, 0),
                      child: Text(widget.clsContent!.category!)),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )),

        //description
        ExcludeSemantics(
          child: Text(
            '${translationCache[UIInfoKeys.description] ?? UIInfoKeys.description}:',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        DescriptionText(
          className: widget.clsContent!.name!,
          content: translationCache[widget.clsContent!.description!] ??
              widget.clsContent!.description!,
          descriptionUsedBy: DescriptionUsedBy.Description,
          // onLinkTap: onLinkTap,
        ),

        //tutorials
        widget.clsContent!.demos != null && widget.clsContent!.demos!.length > 0
            ? Column(
                children: [
                  Text(
                    // 'Demos:',
                    translationCache[UIInfoKeys.demos] ?? UIInfoKeys.demos,
                    style: fieldNames,
                  ),
                  Text(widget.clsContent!.demos!)
                ],
              )
            : Container(),
        SizedBox(
          height: 10,
        ),

        //demos
        widget.clsContent!.demos != null && widget.clsContent!.demos!.length > 0
            ? Column(
                children: [
                  Text(translationCache[UIInfoKeys.tutorials] ??
                      UIInfoKeys.tutorials),
                  Text(widget.clsContent!.tutorials!)
                ],
              )
            : Container(),
      ],
    );
  }
}
