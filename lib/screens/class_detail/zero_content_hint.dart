import 'package:flutter/material.dart';
import 'package:godotclassreference/bloc/tap_event_arg.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/constants/stored_values.dart';
import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/theme/themes.dart';

class ZeroContentHint extends StatelessWidget {
  final ClassContent clsContent;

  const ZeroContentHint({Key? key, required this.clsContent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("0 constant in this class"),
        if (clsContent.inherits != null && clsContent.inherits!.isNotEmpty)
          RichText(
              text: TextSpan(
            children: [
              TextSpan(text: 'maybe check on parent class: '),
              WidgetSpan(
                child: InkWell(
                    child: ExcludeSemantics(
                      child: Text(
                        clsContent.inherits!,
                        style: monoOptionalStyle(context,
                            baseStyle: TextStyle(color: godotColor)),
                      ),
                    ),
                    onTap: () {
                      TapEventArg args = TapEventArg(
                        propertyType: PropertyType.Class,
                        className: clsContent.inherits!,
                        fieldName: '',
                      );
                      // this.onLinkTap(args);
                      storedValues.tapEventBloc.add(args);
                    }),
              )
            ],
          ))
      ],
    );
  }
}
