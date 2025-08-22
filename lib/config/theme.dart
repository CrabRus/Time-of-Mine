import 'package:flutter/material.dart';

const Color kPrimaryPurple = Color(0xFF7E3FF2);
const Color kAccentPurple = Color(0xFFE040FB);
const Color kDarkPurple = Color.fromARGB(255, 85, 42, 165);

ThemeData lightTheme = ThemeData(
  canvasColor: Colors.grey.shade300,
  dividerColor: Colors.transparent,
  iconTheme: IconThemeData(color: Colors.black54),
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  primaryColor: kPrimaryPurple,
  textTheme: const TextTheme(
    bodySmall: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    titleMedium: TextStyle(
      color: Color.fromARGB(255, 0, 0, 0),
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardColor: Color.fromARGB(255, 245, 245, 245),
  colorScheme: const ColorScheme.light(
    primary: kPrimaryPurple,
    secondary: kAccentPurple,
  ),
);

ThemeData darkTheme = ThemeData(
  canvasColor: Colors.grey,
  dividerColor: Colors.transparent,
  iconTheme: IconThemeData(color: Colors.grey),
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color.fromARGB(255, 20, 20, 20),
  primaryColor: kPrimaryPurple,
  primaryColorDark: kDarkPurple,
  textTheme: const TextTheme(
    bodySmall: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleMedium: TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  cardColor: Color.fromARGB(255, 32, 32, 32),
  colorScheme: const ColorScheme.dark(
    primary: kPrimaryPurple,
    secondary: kDarkPurple,
  ),
);
