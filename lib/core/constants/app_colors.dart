import 'package:flutter/material.dart';

/// Az MVK alkalmazás színpalettája a specifikáció szerint
class AppColors {
  AppColors._();

  // Elsődleges színek
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color secondaryGreen = Color(0xFF8BC34A);

  // Háttér színek
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF121212);

  // Kártya színek
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);

  // Szöveg színek
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);

  // Speciális funkciók színei
  static const Color routePlanningBlue = Color(0xFF1A237E);
  static const Color cancelledRed = Color(0xFFD32F2F);

  // Dark mode speciális színek
  static const Color darkAccent = Color(
    0xFF66BB6A,
  ); // Világosabb zöld dark módhoz
  static const Color darkSurface = Color(0xFF2A2A2A);
  static const Color darkDivider = Color(0xFF3D3D3D);

  // Gradientek
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F5F5)],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryGreen, secondaryGreen],
  );

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkAccent, secondaryGreen],
  );

  // Árnyékok
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static final List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];

  static final List<BoxShadow> floatingButtonShadow = [
    BoxShadow(
      color: primaryGreen.withOpacity(0.3),
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];

  static final List<BoxShadow> floatingButtonShadowDark = [
    BoxShadow(
      color: darkAccent.withOpacity(0.4),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // Kontextus-alapú színek (automatikus dark/light)
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? backgroundDark
        : backgroundLight;
  }

  static Color getCardColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardDark
        : cardLight;
  }

  static Color getTextPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textPrimaryDark
        : textPrimaryLight;
  }

  static Color getTextSecondaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? textSecondaryDark
        : textSecondaryLight;
  }

  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkAccent
        : primaryGreen;
  }

  static LinearGradient getBackgroundGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkBackgroundGradient
        : lightBackgroundGradient;
  }

  static LinearGradient getPrimaryGradient(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkPrimaryGradient
        : primaryGradient;
  }

  static List<BoxShadow> getCardShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? cardShadowDark
        : cardShadow;
  }

  static List<BoxShadow> getFloatingButtonShadow(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? floatingButtonShadowDark
        : floatingButtonShadow;
  }
}
