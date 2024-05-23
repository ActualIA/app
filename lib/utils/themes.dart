//coverage:ignore-file
// there's nothing to test _per se_, so we choose to exclude this file from
// tests, and from coverage.
// @qtztz, 02.05.24

// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:flutter/material.dart';

const double UNIT_PADDING = 16.0;
const double ICON_NAV_SIZE = 40;
const Color THEME_PRIMARY = Color(0xFF5EDCE4);
const Color THEME_GREY = Color(0xFFCDCDDC);
const Color THEME_LIGHTGRAY = Color(0xFFf2f5f5);
const Color THEME_WHITE = Color(0xFFFFFFFF);
const Color THEME_BUTTON = Color.fromARGB(255, 68, 159, 166);
const Color THEME_ERROR_TEXT = Color.fromARGB(255, 163, 0, 0);
const Color THEME_ERROR_BACKGROUND = Color.fromARGB(255, 255, 204, 204);

ThemeData ACTUALIA_THEME = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    textTheme: const TextTheme(
      // SERIF TITLES
      titleLarge: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 32.0,
          height: 0.9,
          leadingDistribution: TextLeadingDistribution.even,
          fontWeight: FontWeight.w400),
      titleMedium: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 24.0,
          height: 0.9,
          leadingDistribution: TextLeadingDistribution.even,
          fontWeight: FontWeight.w400),
      titleSmall: TextStyle(
          fontFamily: "EB Garamond",
          fontSize: 14.0,
          height: 1.4,
          fontWeight: FontWeight.w300),
      // MONOSPACED BODIES
      displayLarge: TextStyle(
          fontFamily: "Fira Code", fontSize: 32.0, fontWeight: FontWeight.w700),
      displayMedium: TextStyle(
          fontFamily: "Fira Code", fontSize: 24.0, fontWeight: FontWeight.w500),
      displaySmall: TextStyle(
          fontFamily: "Fira Code",
          fontSize: 14.0,
          height: 1.4,
          fontWeight: FontWeight.w300),
    ),
    colorScheme: ColorScheme.fromSeed(
        seedColor: THEME_PRIMARY, error: THEME_ERROR_TEXT));
