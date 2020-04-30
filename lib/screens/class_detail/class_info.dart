import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:godotclassreference/components/description_text.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/theme/default.dart';

class ClassInfo extends StatelessWidget {
  final ClassContent clsContent;
  final Function(TapEventArg args) onLinkTap;

  ClassInfo({Key key, this.clsContent, @required this.onLinkTap})
      : assert(onLinkTap != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    //brief_description
    //description
    //version
    //category
    //tutorials
    //demos
    return ListView(
      padding: EdgeInsets.all(6),
      children: <Widget>[
        //brief_description
        Text(
          'Brief Description:',
          style: TextStyle(color: Colors.grey),
        ),
        DescriptionText(
          className: clsContent.name,
          content: clsContent.briefDescription,
          onLinkTap: onLinkTap,
        ),
        SizedBox(
          height: 10,
        ),

        //version
        (clsContent.version == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Version:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 0, 0),
                      child: Text(clsContent.version)),
                ],
              )),
        SizedBox(
          height: 10,
        ),

        //category
        (clsContent.category == null
            ? SizedBox()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Category:',
                    style: TextStyle(color: Colors.grey),
                  ),
                  Padding(
                      padding: EdgeInsets.fromLTRB(10, 4, 0, 0),
                      child: Text(clsContent.category)),
                  SizedBox(
                    height: 10,
                  ),
                ],
              )),

        //description
//        Text('Description:', style: fieldNames),
        DescriptionText(
          className: clsContent.name,
          content: clsContent.description,
          onLinkTap: onLinkTap,
        ),
//        Text(clsContent.description),
        //tutorials
        clsContent.demos != null && clsContent.demos.length > 0
            ? Column(
                children: <Widget>[
                  Text(
                    'Demos:',
                    style: fieldNames,
                  ),
                  Text(clsContent.demos)
                ],
              )
            : Container(),
        SizedBox(
          height: 10,
        ),

        //demos
        clsContent.demos != null && clsContent.demos.length > 0
            ? Column(
                children: <Widget>[
                  Text('Tutorials:'),
                  Text(clsContent.tutorials)
                ],
              )
            : Container(),
      ],
    );
  }
}
