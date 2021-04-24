// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'dart:convert';
// import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

// import 'package:godotclassreference/main.dart';
import 'package:godotclassreference/screens/class_select.dart';

//Future<void> pageBack() async {
//  return TestAsyncUtils.guard<void>(() async {
//    Finder backButton = find.byTooltip('Back');
//    if (backButton.evaluate().isEmpty) {
//      backButton = find.byType(CupertinoNavigationBarBackButton);
//    }
//
//    expectSync(backButton, findsOneWidget,
//        reason: 'One back button expected on screen');
//
//    await tap(backButton);
//  });
//}

void main() {
//  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
////    // Build our app and trigger a frame.
////    await tester.pumpWidget(MyApp());
////
////    // Verify that our counter starts at 0.
////    expect(find.text('0'), findsOneWidget);
////    expect(find.text('1'), findsNothing);
////
////    // Tap the '+' icon and trigger a frame.
////    await tester.tap(find.byIcon(Icons.add));
////    await tester.pump();
////
////    // Verify that our counter has incremented.
////    expect(find.text('0'), findsNothing);
////    expect(find.text('1'), findsOneWidget);
//
////    await tester.pumpWidget(ClassSelect());
////    finder
//
//    // test xml parsing and binding
////    File.
////    final fileExist = FileSystemEntity.typeSync('../xmls/files_3.0.json') ==
////        FileSystemEntityType.notFound;
////
////    final file = await File('../xmls/files_3.0.json').readAsString();
//
////    final jsonStr = await DefaultAssetBundle.
//
////    final fileContent = await file.readAsString();
////    final jsonStr = json.decode(fileContent);
////    jsonStr.forEach((f) async {
////      print('testing ' + f);
////      final xmlFile = File('xmlx/3.0/' + f);
////      final file = await xmlFile.readAsString();
////      final rootNode = xml.parse(file).root.lastChild;
////
////      final rootContent = ClassContent.fromJson(rootNode);
////      expect(rootContent.name, f.replaceAll('.xml', ''));
////    });
//  });

  testWidgets('Test Xml Parsing', (WidgetTester tester) async {
    Widget testWidget = MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(home: ClassSelect()),
    );

    await tester.pumpWidget(
      testWidget,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);

    expect(find.byType(ListTile), findsWidgets);

    bool endLoop = false;
    ListTile prevHead;
    int dragged = 0;
    while (!endLoop) {
      //scrolling down
      ListTile head = find
          .descendant(
              of: find.byType(ListView), matching: find.byType(ListTile))
          .evaluate()
          .first
          .widget;

      //tapping each ListTile
      final classes = find.byType(ListTile).evaluate();
      for (int i = 0; i < classes.length; i++) {
        ListTile one =
            find.byWidget(classes.elementAt(i).widget).evaluate().first.widget;
        print(one.title);
        expect(find.byWidget(classes.elementAt(i).widget), findsOneWidget);
//        print(find.byWidget(classes.elementAt(i).widget));
        await tester.tap(find.byWidget(classes.elementAt(i).widget));
//        await tester.pump();
//        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        await tester.pumpAndSettle(
            Duration(seconds: 10), EnginePhase.flushSemantics);
        expect(find.byType(CircularProgressIndicator), findsNothing);

        //tap back to class select
        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle(Duration(seconds: 10));
        expect(find.byType(TabBar), findsNothing);
      }

      await tester.drag(find.byType(ListView), Offset(0, -580));

      await tester.pumpAndSettle(); // flush the widget tree
//      classes.forEach((e) async {
//        await tester.tap(find.byKey(e.widget.key));
//        await tester.pumpAndSettle();
//        expect(find.byType(CircularProgressIndicator), findsNothing);
//      });
      print(classes.length);

      if (prevHead != null && prevHead.title == head.title) {
        endLoop = true;
      }
      prevHead = head;
//      print(dragged++);
    }
  });
}
