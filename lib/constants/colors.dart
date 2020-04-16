import 'dart:ui';

import 'package:flutter/material.dart';

/*
#6589b0
#b065af
#b08c65
#65b067
*/

/*
rgb(101, 137, 176)
rgb(176, 101, 175)
rgb(176, 140, 101)
rgb(101, 176, 103)
*/

final Map<int, Color> godotThemeColorMap = {
  50: Color.fromRGBO(101, 137, 189, .1),
  100: Color.fromRGBO(101, 137, 189, .2),
  200: Color.fromRGBO(101, 137, 189, .3),
  300: Color.fromRGBO(101, 137, 189, .4),
  400: Color.fromRGBO(101, 137, 189, .5),
  500: Color.fromRGBO(101, 137, 189, .6),
  600: Color.fromRGBO(101, 137, 189, .7),
  700: Color.fromRGBO(101, 137, 189, .8),
  800: Color.fromRGBO(101, 137, 189, .9),
  900: Color.fromRGBO(101, 137, 189, 1),
};

final Color godotColor = MaterialColor(0xFF6589BD, godotThemeColorMap);
