import 'package:flutter/material.dart';

String apiKey = "AIzaSyDcPsH1JzCRfGLGNkqDHfvEAZaNavGmTHQ";

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  cardColor: Colors.grey.shade100,
  colorScheme: ColorScheme.light(
    primary: Colors.deepPurple.shade100,
    secondary: Colors.deepPurple.shade100,
    tertiary: Colors.grey.shade300,
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  cardColor: Colors.grey.shade900,
  colorScheme: ColorScheme.dark(
    primary: Colors.deepPurple.shade200,
    secondary: Colors.deepPurple.shade500,
    tertiary: Colors.grey.shade800,
  ),
);
