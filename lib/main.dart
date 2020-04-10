import 'package:flutter/material.dart';
import 'package:godotclassreference/components/drawer.dart';

import 'constants/colors.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: godotColor,
      ),
      home: Scaffold(
        drawer: GCRDrawer(),
        appBar: AppBar(
          actions: <Widget>[
            FlatButton(
              child: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          ],
          title: Text('Flutter Demo'),
        ),
        body: Center(
          child: Text('Flutter Demo Home Page'),
        ),
      ),
    );
  }
}
