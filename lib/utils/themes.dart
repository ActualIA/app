//coverage:ignore-file
// there's nothing to test _per se_, so we choose to exclude this file from
// tests, and from coverage.
// @qtztz, 02.05.24

import 'package:flutter/material.dart';

const double UNIT_PADDING = 16.0;
const Color THEME_PRIMARY = Color(0xFF5EDCE4);
const Color THEME_GREY = Color(0xFFCDCDDC);

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
    colorScheme: ColorScheme.fromSeed(seedColor: THEME_PRIMARY));
