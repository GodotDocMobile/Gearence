// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:godotclassreference/main.dart';

import 'package:xml/xml.dart' as xml;

import 'package:godotclassreference/models/class_content.dart';
import 'package:godotclassreference/screens/class_select.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//    // Build our app and trigger a frame.
//    await tester.pumpWidget(MyApp());
//
//    // Verify that our counter starts at 0.
//    expect(find.text('0'), findsOneWidget);
//    expect(find.text('1'), findsNothing);
//
//    // Tap the '+' icon and trigger a frame.
//    await tester.tap(find.byIcon(Icons.add));
//    await tester.pump();
//
//    // Verify that our counter has incremented.
//    expect(find.text('0'), findsNothing);
//    expect(find.text('1'), findsOneWidget);

//    await tester.pumpWidget(ClassSelect());
//    finder

    // test xml parsing and binding
//    File.
//    final fileExist = FileSystemEntity.typeSync('../xmls/files_3.0.json') ==
//        FileSystemEntityType.notFound;
//
//    final file = await File('../xmls/files_3.0.json').readAsString();

//    final jsonStr = await DefaultAssetBundle.

//    final fileContent = await file.readAsString();
//    final jsonStr = json.decode(fileContent);
//    jsonStr.forEach((f) async {
//      print('testing ' + f);
//      final xmlFile = File('xmlx/3.0/' + f);
//      final file = await xmlFile.readAsString();
//      final rootNode = xml.parse(file).root.lastChild;
//
//      final rootContent = ClassContent.fromJson(rootNode);
//      expect(rootContent.name, f.replaceAll('.xml', ''));
//    });
  });
}
