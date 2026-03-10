import 'package:flutter/material.dart';
import 'package:godotclassreference/bloc/blocs.dart';
import 'package:godotclassreference/constants/colors.dart';
import 'package:godotclassreference/isar/schema/class_content.dart';
import 'package:godotclassreference/theme/themes.dart';

class ZeroContentHint extends StatelessWidget {
  final ClassContent clsContent;
  final PropertyType propertyType;

  // 1. Use a const constructor for zero-cost rebuilds
  const ZeroContentHint(
      {super.key, required this.clsContent, required this.propertyType});

  @override
  Widget build(BuildContext context) {
    // 2. Derive styles from context so the widget stays 'const' ready
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hintStyle =
        TextStyle(color: isDark ? Colors.white70 : Colors.black54);
    final typeName = propertyType.name.toLowerCase();

    return Center(
      // 3. Ensure it's centered in the TabView
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: hintStyle.color, size: 40),
          const SizedBox(height: 10),
          Text("0 $typeName in this class", style: hintStyle),
          if (clsContent.inherits != null &&
              clsContent.inherits!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text("Search in parent class:",
                style: hintStyle.copyWith(fontSize: 12)),
            const SizedBox(height: 8),

            // 4. Combined Action Button: More 'touch-friendly' for TV sticks
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                blocs.tapEventBloc.add(
                  TapEventArg(
                    className: clsContent.inherits!,
                    propertyType: propertyType,
                    fieldName: '',
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    Text(
                      clsContent.inherits!,
                      style: monoOptionalStyle(context,
                          baseStyle: TextStyle(
                              color: godotColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text("Go to ${clsContent.inherits!}'s $typeName →",
                        style: TextStyle(
                            color: godotColor.withValues(alpha: 0.7),
                            fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
