import 'package:flutter/material.dart';

import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/constants/class_db.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/theme/default.dart';

class ClassInfo extends StatelessWidget {
  final ClassContent? clsContent;

  ClassInfo({Key? key, this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _childClasses = ClassDB()
        .getDB()
        .where((element) => element.inherits == clsContent!.name)
        .map((e) => ' [' + e.name! + '] ')
        .toList()
        .toString();

    return ListView(
      padding: EdgeInsets.all(10),
      children: [
        //inherit chain
        ExcludeSemantics(
          child: Text(
            'Inherits:',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        DescriptionText(
          className: clsContent!.name!,
          content:
              clsContent!.inheritChain == null ? '' : clsContent!.inheritChain!,
          descriptionUsedBy: DescriptionUsedBy.Inherits,
          // onLinkTap: onLinkTap,
        ),
        SizedBox(
          height: 10,
        ),

        //child classes
        ExcludeSemantics(
          child: Text(
            'Child Classes:',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        DescriptionText(
          className: clsContent!.name!,
          content: _childClasses.substring(1, _childClasses.length - 1),
          descriptionUsedBy: DescriptionUsedBy.ChildClasses,
          // onLinkTap: onLinkTap,
        ),
        SizedBox(
          height: 10,
        ),

        //brief_description
        ExcludeSemantics(
          child: Text(
            'Brief Description:',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        DescriptionText(
          className: clsContent!.name!,
          content: clsContent!.briefDescription!,
          descriptionUsedBy: DescriptionUsedBy.BriefDescription,
          // onLinkTap: onLinkTap,
        ),
        SizedBox(
          height: 10,
        ),

        //version
        (clsContent!.version == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Version:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 0, 0),
                      child: Text(clsContent!.version!)),
                ],
              )),
        SizedBox(
          height: 10,
        ),

        //category
        (clsContent!.category == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Category:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 0, 0),
                      child: Text(clsContent!.category!)),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )),

        //description
        DescriptionText(
          className: clsContent!.name!,
          content: clsContent!.description!,
          descriptionUsedBy: DescriptionUsedBy.Description,
          // onLinkTap: onLinkTap,
        ),

        //tutorials
        clsContent!.demos != null && clsContent!.demos!.length > 0
            ? Column(
                children: [
                  Text(
                    'Demos:',
                    style: fieldNames,
                  ),
                  Text(clsContent!.demos!)
                ],
              )
            : Container(),
        SizedBox(
          height: 10,
        ),

        //demos
        clsContent!.demos != null && clsContent!.demos!.length > 0
            ? Column(
                children: [Text('Tutorials:'), Text(clsContent!.tutorials!)],
              )
            : Container(),
      ],
    );
  }
}
