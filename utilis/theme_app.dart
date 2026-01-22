import 'package:flutter/material.dart';

const Color primaryPurple = Color(0xFF7B61FF);
const Color lightPurple = Color(0xFFEAE6FF);

const Color backgroundGrey = Color(0xFFF5F6FA);
const Color cardWhite = Colors.white;

const Color textDark = Color(0xFF1E1E2C);
const Color textGrey = Color(0xFF6B7280);

ThemeData educationTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: backgroundGrey,

    colorScheme: const ColorScheme.light(
      primary: primaryPurple,
      secondary: lightPurple,
      surface: cardWhite,
      onPrimary: Colors.white,
      onSurface: textDark,
    ),

    // ================= APP BAR =================
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF7B61FF),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      iconTheme: IconThemeData(color: textDark),
    ),

    // ================= TEXTE =================
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.bold,
        color: textDark,
      ),
      headlineMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textDark,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: textDark,
      ),
      bodyMedium: TextStyle(fontSize: 15, color: textGrey, height: 1.6),
    ),

    // ================= CARDS =================
    cardTheme: CardThemeData(
      color: cardWhite,
      elevation: 3,
      shadowColor: primaryPurple.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),

    // ================= BOUTONS =================
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryPurple,
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
    ),

    // ================= TEXTFIELDS =================
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardWhite,
      hintStyle: const TextStyle(color: textGrey),
      labelStyle: const TextStyle(color: textGrey),
      prefixIconColor: primaryPurple,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryPurple, width: 1.5),
      ),
    ),

    // ================= ICONES =================
    iconTheme: const IconThemeData(color: primaryPurple),

    // ================= BOTTOM NAV =================
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primaryPurple,
      unselectedItemColor: textGrey,
      showUnselectedLabels: true,
      elevation: 8,
    ),

    // ================= FAB =================
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryPurple,
      foregroundColor: Colors.white,
    ),
  );
}
