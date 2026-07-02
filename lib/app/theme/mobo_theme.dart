import 'package:flutter/material.dart';
import 'mobo_colors.dart';

ThemeData buildMoboTheme() {
  const colors = MoboColors(
    paper: Color(0xFFFAF6EC),
    ink: Color(0xFF1B2A3D),
    bahiMaroon: Color(0xFF7A1F33),
    action: Color(0xFFB23A48),
    creditGreen: Color(0xFF2E6B4F),
    debitRed: Color(0xFFC13B2D),
    gold: Color(0xFFC79A2C),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE4DCC8),
    inkMuted: Color(0xFF5C6B7A),
  );

  final base = ThemeData.light();
  return base.copyWith(
    scaffoldBackgroundColor: colors.paper,
    appBarTheme: base.appBarTheme.copyWith(backgroundColor: colors.bahiMaroon, foregroundColor: Colors.white),
    extensions: [colors],
    textTheme: base.textTheme.apply(bodyColor: colors.ink),
    colorScheme: base.colorScheme.copyWith(primary: colors.action),
  );
}
