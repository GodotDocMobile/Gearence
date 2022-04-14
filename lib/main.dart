import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/bloc/blocs.dart';
import '/constants/stored_values.dart';
import '/theme/themes.dart';
import '/screens/class_select.dart';

void main() async {
  runApp(GCRApp());
}

class GCRApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: StoredValues().readValue(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ChangeNotifierProvider<ThemeChange>(
            create: (context) {
              return StoredValues().themeChange;
            },
            builder: (context, widget) {
              return MaterialApp(
                //hide debug banner
                debugShowCheckedModeBanner: false,
                theme: lightTheme,
                darkTheme: darkTheme,
                themeMode: Provider.of<ThemeChange>(context).isDark
                    ? ThemeMode.dark
                    : ThemeMode.light,
                home: ChangeNotifierProvider<MonospaceFontBloc>(
                  create: (context) {
                    return storedValues.monospaced;
                  },
                  builder: (context, widget) {
                    return ClassSelect();
                  },
                ),
              );
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
