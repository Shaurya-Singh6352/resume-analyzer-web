import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette: a cool paper background, deep petrol for actions, and a
/// highlighter yellow used only to mark things worth attention.
class AppColors {
  static const bg = Color(0xFFF4F6F8);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF5B6472);
  static const line = Color(0xFFDDE2E9);
  static const track = Color(0xFFE6EAF0);
  static const petrol = Color(0xFF0F4C5C);
  static const marker = Color(0xFFFFCB47);
  static const good = Color(0xFF1F9D6B);
  static const warn = Color(0xFFC98A00);
  static const bad = Color(0xFFD64545);
}

/// Green, amber or red depending on how much of the maximum was earned.
Color scoreColor(double fraction) {
  if (fraction >= 0.8) return AppColors.good;
  if (fraction >= 0.6) return AppColors.warn;
  return AppColors.bad;
}

/// Fraunces (serif) for headings and the big score, Figtree for everything else.
class AppText {
  static TextStyle display(double size) => GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: FontWeight.w600,
    height: 1.15,
    color: AppColors.ink,
  );

  static TextStyle body({
    double size = 16,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
  }) =>
      GoogleFonts.figtree(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: 1.45,
      );

  static TextStyle muted({double size = 15}) =>
      body(size: size, color: AppColors.muted);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.petrol),
  );

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: GoogleFonts.figtreeTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.petrol,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.figtree(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.petrol,
        textStyle: GoogleFonts.figtree(fontWeight: FontWeight.w600),
      ),
    ),
  );
}