import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Material Design 3 témák az MVK alkalmazáshoz
class AppThemes {
  AppThemes._();

  /// Világos téma
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Színpaletta
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryGreen,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.primaryGreen,
        secondary: AppColors.secondaryGreen,
        surface: AppColors.backgroundLight,
        error: AppColors.cancelledRed,
      ),

      // AppBar téma
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.primaryGreen,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryGreen,
        ),
      ),

      // Kártya téma
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        shadowColor: Colors.black.withOpacity(0.1),
      ),

      // Floating Action Button téma
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Elevated Button téma
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: AppColors.primaryGreen.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button téma
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Input Decoration téma
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Bottom Navigation Bar téma
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip téma
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondaryGreen.withOpacity(0.1),
        selectedColor: AppColors.primaryGreen,
        labelStyle: const TextStyle(color: AppColors.primaryGreen),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// Sötét téma
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Színpaletta
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkAccent,
        brightness: Brightness.dark,
      ).copyWith(
        primary: AppColors.darkAccent,
        secondary: AppColors.secondaryGreen,
        surface: AppColors.cardDark,
        background: AppColors.backgroundDark,
        error: AppColors.cancelledRed,
        onSurface: AppColors.textPrimaryDark,
        onBackground: AppColors.textPrimaryDark,
        onPrimary: AppColors.backgroundDark,
      ),

      // Scaffold háttér
      scaffoldBackgroundColor: AppColors.backgroundDark,

      // AppBar téma
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.darkAccent,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.darkAccent,
        ),
      ),

      // Kártya téma
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.cardDark,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Floating Action Button téma
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkAccent,
        foregroundColor: AppColors.backgroundDark,
        elevation: 6,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Elevated Button téma
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkAccent,
          foregroundColor: AppColors.backgroundDark,
          elevation: 3,
          shadowColor: AppColors.darkAccent.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button téma
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),

      // Input Decoration téma
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkDivider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.darkAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),

      // Bottom Navigation Bar téma
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardDark,
        selectedItemColor: AppColors.darkAccent,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip téma
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkAccent.withOpacity(0.2),
        selectedColor: AppColors.darkAccent,
        labelStyle: TextStyle(color: AppColors.darkAccent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Divider téma
      dividerTheme: DividerThemeData(
        color: AppColors.darkDivider,
        thickness: 1,
      ),

      // Icon téma
      iconTheme: IconThemeData(color: AppColors.textPrimaryDark),

      // Text téma
      textTheme: TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimaryDark),
        displayMedium: TextStyle(color: AppColors.textPrimaryDark),
        displaySmall: TextStyle(color: AppColors.textPrimaryDark),
        headlineLarge: TextStyle(color: AppColors.textPrimaryDark),
        headlineMedium: TextStyle(color: AppColors.textPrimaryDark),
        headlineSmall: TextStyle(color: AppColors.textPrimaryDark),
        titleLarge: TextStyle(color: AppColors.textPrimaryDark),
        titleMedium: TextStyle(color: AppColors.textPrimaryDark),
        titleSmall: TextStyle(color: AppColors.textPrimaryDark),
        bodyLarge: TextStyle(color: AppColors.textPrimaryDark),
        bodyMedium: TextStyle(color: AppColors.textPrimaryDark),
        bodySmall: TextStyle(color: AppColors.textSecondaryDark),
        labelLarge: TextStyle(color: AppColors.textPrimaryDark),
        labelMedium: TextStyle(color: AppColors.textSecondaryDark),
        labelSmall: TextStyle(color: AppColors.textSecondaryDark),
      ),

      // List Tile téma
      listTileTheme: ListTileThemeData(
        textColor: AppColors.textPrimaryDark,
        iconColor: AppColors.textSecondaryDark,
      ),

      // Switch téma
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.darkAccent;
          }
          return AppColors.textSecondaryDark;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.darkAccent.withOpacity(0.5);
          }
          return AppColors.darkDivider;
        }),
      ),
    );
  }
}
