import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors - Islamic Green & Gold
  static const Color primaryGreen = Color(0xFF1B4332);
  static const Color primaryGreenLight = Color(0xFF2D6A4F);
  static const Color primaryGreenDark = Color(0xFF0D3322);

  static const Color gold = Color(0xFFD4A853);
  static const Color goldLight = Color(0xFFE8C87A);
  static const Color goldDark = Color(0xFFB8943F);

  static const Color cream = Color(0xFFF5F0E6);
  static const Color creamDark = Color(0xFFE8E0D0);
  static const Color sand = Color(0xFFD4C5A9);

  // Accent Colors
  static const Color teal = Color(0xFF2A9D8F);
  static const Color navy = Color(0xFF1D3557);
  static const Color warmWhite = Color(0xFFFAF8F5);
  static const Color charcoal = Color(0xFF2C2C2C);

  // Semantic Colors
  static const Color success = Color(0xFF2D6A4F);
  static const Color warning = Color(0xFFE9C46A);
  static const Color error = Color(0xFFE63946);
  static const Color info = Color(0xFF457B9D);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: warmWhite,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        secondary: gold,
        surface: Colors.white,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: charcoal,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.cairoTextTheme().copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32, fontWeight: FontWeight.bold, color: primaryGreen,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 24, fontWeight: FontWeight.bold, color: primaryGreen,
        ),
        displaySmall: GoogleFonts.cairo(
          fontSize: 20, fontWeight: FontWeight.w600, color: charcoal,
        ),
        headlineLarge: GoogleFonts.cairo(
          fontSize: 18, fontWeight: FontWeight.w600, color: primaryGreen,
        ),
        headlineMedium: GoogleFonts.cairo(
          fontSize: 16, fontWeight: FontWeight.w600, color: charcoal,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16, fontWeight: FontWeight.normal, color: charcoal,
        ),
        bodyMedium: GoogleFonts.cairo(
          fontSize: 14, fontWeight: FontWeight.normal, color: charcoal,
        ),
        bodySmall: GoogleFonts.cairo(
          fontSize: 12, fontWeight: FontWeight.normal, color: Colors.grey,
        ),
        labelLarge: GoogleFonts.cairo(
          fontSize: 14, fontWeight: FontWeight.w600, color: primaryGreen,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData( // 👈 وتم تغييرها هنا أيضاً
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF16213E),
        shadowColor: Colors.black.withAlpha(76),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryGreen,
          side: const BorderSide(color: primaryGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(
            fontSize: 16, fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream.withAlpha(127),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: sand.withAlpha(127)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.cairo(
          fontSize: 14, color: Colors.grey,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryGreen,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 12),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: gold,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: DividerThemeData(
        color: sand.withAlpha(127),
        thickness: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreenLight,
      scaffoldBackgroundColor: const Color(0xFF1A1A2E),
      colorScheme: const ColorScheme.dark(
        primary: primaryGreenLight,
        secondary: goldLight,
        surface: Color(0xFF16213E),
        error: Color(0xFFE63946),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.cairo(
          fontSize: 32, fontWeight: FontWeight.bold, color: goldLight,
        ),
        displayMedium: GoogleFonts.cairo(
          fontSize: 24, fontWeight: FontWeight.bold, color: goldLight,
        ),
        bodyLarge: GoogleFonts.cairo(
          fontSize: 16, color: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData( // 👈 وتم تغييرها هنا أيضاً
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF16213E),
        shadowColor: Colors.black.withAlpha(76),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenLight,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F3460).withAlpha(127),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withAlpha(76)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldLight, width: 2),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF16213E),
        selectedItemColor: goldLight,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, primaryGreenLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [gold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static BoxDecoration get glassDecoration => BoxDecoration(
    color: Colors.white.withAlpha(38),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withAlpha(51)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withAlpha(12),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
