import 'package:flutter/material.dart';

import 'bloc/tap_event_bloc.dart';
import 'constants/stored_values.dart';
import 'theme/themes.dart';
import 'screens/class_select.dart';

void main() => runApp(GCRApp());

class GCRApp extends StatefulWidget {
  @override
  _GCRAppState createState() => _GCRAppState();
}

class _GCRAppState extends State<GCRApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    TapEventBloc().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: StoredValues().readValue(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (!StoredValues().themeChange.isListened()) {
            StoredValues().themeChange.addListener(() {
              setState(() {});
            });
          }

          return MaterialApp(
            //hide debug banner
            debugShowCheckedModeBanner: false,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: StoredValues().themeChange.currentTheme(),
            home: ClassSelect(),
            builder: (BuildContext context, Widget child) {
              return child;
            },
          );
        } else {
          return Container(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
