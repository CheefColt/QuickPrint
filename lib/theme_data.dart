// lib/theme_data.dart
import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Color(0xFF121212), // Pure Dark Gray
  scaffoldBackgroundColor: Color(0xFF121212), // Pure Dark Gray
  cardColor: Color(0xFF1E1E1E), // Dark Charcoal
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFE0E0E0)), // Off-White
    bodyMedium: TextStyle(color: Color(0xFFBDBDBD)), // Light Gray
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Color(0xFF121212), // Pure Dark Gray
    titleTextStyle: TextStyle(color: Color(0xFFE0E0E0), fontSize: 20, fontWeight: FontWeight.bold),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF00BCD4), // Vibrant Cyan
  ),
  dividerColor: Color(0xFF2E2E2E), // Subtle dark lines
);