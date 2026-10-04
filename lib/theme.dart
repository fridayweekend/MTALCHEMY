import 'package:flutter/material.dart';

const deepBlue = Color(0xFF16105B);
const royalBlue = Color(0xFF2412B8);
const softYellow = Color(0xFFFFD45A);
const purple = Color(0xFF7655B7);
const ink = Color(0xFF17152B);
const canvas = Color(0xFFFFFBF2);

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: canvas,
  colorScheme: ColorScheme.fromSeed(
    seedColor: deepBlue,
    primary: deepBlue,
    secondary: purple,
    tertiary: softYellow,
    surface: Colors.white,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: canvas,
    foregroundColor: deepBlue,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 58,
      height: 1.05,
      fontWeight: FontWeight.w800,
      color: deepBlue,
    ),
    headlineLarge: TextStyle(
      fontSize: 42,
      height: 1.12,
      fontWeight: FontWeight.w800,
      color: deepBlue,
    ),
    headlineMedium: TextStyle(
      fontSize: 30,
      height: 1.2,
      fontWeight: FontWeight.w700,
      color: deepBlue,
    ),
    titleLarge: TextStyle(
      fontSize: 21,
      fontWeight: FontWeight.w700,
      color: deepBlue,
    ),
    bodyLarge: TextStyle(fontSize: 17, height: 1.6, color: ink),
    bodyMedium: TextStyle(fontSize: 15, height: 1.55, color: ink),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
  ),
);
