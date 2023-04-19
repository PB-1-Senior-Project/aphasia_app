import 'package:flutter/material.dart';
import 'dart:async';


StreamController<ThemeData> currentTheme = StreamController ();

ThemeData lightTheme = ThemeData.light (useMaterial3: true).copyWith(

);
ThemeData darkTheme = ThemeData.dark (useMaterial3: true);

TextStyle? current = wordTheme.textTheme.bodyMedium;

ThemeData wordTheme = ThemeData.light(useMaterial3: true).copyWith(
  textTheme: ThemeData.light(useMaterial3: true).textTheme.copyWith(
    bodyLarge: const TextStyle(
      fontSize: 20,
    ), 
    bodyMedium: const TextStyle(
      fontSize: 16,
    ),
    bodySmall: const TextStyle(
      fontSize: 12,
    )
  ),
);
