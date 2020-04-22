import 'package:flutter/material.dart';
import 'package:godotclassreference/components/drawer.dart';
import 'package:godotclassreference/constants/stored_values.dart';

import 'screens/class_select.dart';

import 'constants/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    StoredValues().readValue();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: godotColor,
      ),
      home: ClassSelect(),
    );
  }
}
