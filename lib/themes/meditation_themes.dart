import 'package:flutter/material.dart';

class MeditationTheme {
  final String name;
  final Color primaryAccent;
  final Color overlayColor;
  final Color cardColor;
  final Color navColor;
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final String greeting;

  const MeditationTheme({
    required this.name,
    required this.primaryAccent,
    required this.overlayColor,
    required this.cardColor,
    required this.navColor,
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.greeting,
  });
}

const List<MeditationTheme> meditationThemes = [
  MeditationTheme(
    name: 'Dawn',
    primaryAccent: Color(0xFFE8913A),
    overlayColor: Color(0x803D1F00),
    cardColor: Color(0xCC1A0D00),
    navColor: Color(0x993D1F00),
    background: Color(0xFF0E0803),
    surface: Color(0xFF1F140A),
    surfaceElevated: Color(0xFF2C1E10),
    border: Color(0xFF4A3520),
    greeting: 'Begin with warmth',
  ),
  MeditationTheme(
    name: 'Ocean',
    primaryAccent: Color(0xFF2EC4B6),
    overlayColor: Color(0x80002A2A),
    cardColor: Color(0xCC001A1A),
    navColor: Color(0x99002A2A),
    background: Color(0xFF041010),
    surface: Color(0xFF0A1F1F),
    surfaceElevated: Color(0xFF103030),
    border: Color(0xFF1E4A4A),
    greeting: 'Flow with calm',
  ),
  MeditationTheme(
    name: 'Forest',
    primaryAccent: Color(0xFF4CAF50),
    overlayColor: Color(0x800A1F0A),
    cardColor: Color(0xCC061206),
    navColor: Color(0x990A1F0A),
    background: Color(0xFF060F06),
    surface: Color(0xFF0E1E0E),
    surfaceElevated: Color(0xFF163016),
    border: Color(0xFF2B4A2B),
    greeting: 'Ground in nature',
  ),
  MeditationTheme(
    name: 'Cosmos',
    primaryAccent: Color(0xFF7C4DFF),
    overlayColor: Color(0x800D0033),
    cardColor: Color(0xCC06001A),
    navColor: Color(0x990D0033),
    background: Color(0xFF090610),
    surface: Color(0xFF150F26),
    surfaceElevated: Color(0xFF201A38),
    border: Color(0xFF352A55),
    greeting: 'Expand awareness',
  ),
  MeditationTheme(
    name: 'Lotus',
    primaryAccent: Color(0xFFEC407A),
    overlayColor: Color(0x80330018),
    cardColor: Color(0xCC1A000D),
    navColor: Color(0x99330018),
    background: Color(0xFF12040A),
    surface: Color(0xFF220A14),
    surfaceElevated: Color(0xFF330F1F),
    border: Color(0xFF551A33),
    greeting: 'Open the heart',
  ),
  MeditationTheme(
    name: 'Midnight',
    primaryAccent: Color(0xFF90A4AE),
    overlayColor: Color(0x800A0A14),
    cardColor: Color(0xCC050508),
    navColor: Color(0x990A0A14),
    background: Color(0xFF0A0A14),
    surface: Color(0xFF14141F),
    surfaceElevated: Color(0xFF1E1E2E),
    border: Color(0xFF38384D),
    greeting: 'Rest in stillness',
  ),
];
