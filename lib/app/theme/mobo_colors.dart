import 'package:flutter/material.dart';

class MoboColors extends ThemeExtension<MoboColors> {
  final Color paper;
  final Color ink;
  final Color bahiMaroon;
  final Color action;
  final Color creditGreen;
  final Color debitRed;
  final Color gold;
  final Color surface;
  final Color border;
  final Color inkMuted;

  const MoboColors({
    required this.paper,
    required this.ink,
    required this.bahiMaroon,
    required this.action,
    required this.creditGreen,
    required this.debitRed,
    required this.gold,
    required this.surface,
    required this.border,
    required this.inkMuted,
  });

  @override
  ThemeExtension<MoboColors> copyWith({
    Color? paper,
    Color? ink,
    Color? bahiMaroon,
    Color? action,
    Color? creditGreen,
    Color? debitRed,
    Color? gold,
    Color? surface,
    Color? border,
    Color? inkMuted,
  }) {
    return MoboColors(
      paper: paper ?? this.paper,
      ink: ink ?? this.ink,
      bahiMaroon: bahiMaroon ?? this.bahiMaroon,
      action: action ?? this.action,
      creditGreen: creditGreen ?? this.creditGreen,
      debitRed: debitRed ?? this.debitRed,
      gold: gold ?? this.gold,
      surface: surface ?? this.surface,
      border: border ?? this.border,
      inkMuted: inkMuted ?? this.inkMuted,
    );
  }

  @override
  ThemeExtension<MoboColors> lerp(ThemeExtension<MoboColors>? other, double t) {
    if (other is! MoboColors) return this;
    return MoboColors(
      paper: Color.lerp(paper, other.paper, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      bahiMaroon: Color.lerp(bahiMaroon, other.bahiMaroon, t)!,
      action: Color.lerp(action, other.action, t)!,
      creditGreen: Color.lerp(creditGreen, other.creditGreen, t)!,
      debitRed: Color.lerp(debitRed, other.debitRed, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      border: Color.lerp(border, other.border, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
    );
  }
}
