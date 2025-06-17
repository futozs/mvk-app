import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Közös animációs effektusok és konfigurációk - ULTRA MODERN & SMOOTH!
class AppAnimations {
  AppAnimations._();

  // Alapvető időzítések - ULTRA SMOOTH & CINEMATIC!
  static const Duration ultraFast = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 550);
  static const Duration extraSlow = Duration(milliseconds: 750);
  static const Duration cinematic = Duration(milliseconds: 1000);
  static const Duration splash = Duration(milliseconds: 2500);

  // Ultra smooth easing görbék - mint Apple iOS-ben!
  static const Curve defaultCurve = Curves.easeOutQuart;
  static const Curve bounceIn = Curves.elasticOut;
  static const Curve elasticOut = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeInOutCubic;
  static const Curve ultraSmoothCurve = Curves.easeOutExpo;
  static const Curve cinematicCurve = Curves.easeInOutQuint;
  static const Curve springCurve = Curves.easeOutBack;
  static const Curve fluidCurve = Curves.easeInOutCirc;

  // Új ultra smooth animációk
  /// Filmszerű kártya belépő animáció mikrointerakciókkal
  static List<Effect> get modernCardEnterAnimation => [
    FadeEffect(duration: slow, curve: ultraSmoothCurve, begin: 0, end: 1),
    SlideEffect(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
      duration: slow,
      curve: springCurve,
    ),
    ScaleEffect(
      begin: const Offset(0.85, 0.85),
      end: const Offset(1.0, 1.0),
      duration: slow,
      curve: elasticOut,
    ),
    const ShimmerEffect(
      duration: Duration(milliseconds: 1200),
      delay: Duration(milliseconds: 200),
    ),
  ];

  /// Gyors hozzáférés gombok szekvenciális animációja
  static List<Effect> quickAccessAnimation(int index) => [
    FadeEffect(
      duration: slow,
      delay: Duration(milliseconds: index * 100 + 150),
      curve: ultraSmoothCurve,
    ),
    SlideEffect(
      begin: Offset(index.isEven ? -0.5 : 0.5, 0.3),
      end: Offset.zero,
      duration: slow,
      delay: Duration(milliseconds: index * 100 + 150),
      curve: springCurve,
    ),
    ScaleEffect(
      begin: const Offset(0.7, 0.7),
      end: const Offset(1.0, 1.0),
      duration: slow,
      delay: Duration(milliseconds: index * 100 + 150),
      curve: elasticOut,
    ),
    ShimmerEffect(
      duration: const Duration(milliseconds: 1000),
      delay: Duration(milliseconds: index * 100 + 300),
    ),
  ];

  /// Köszöntő szekció animáció időszak alapján
  static List<Effect> get greetingAnimation => [
    const FadeEffect(duration: extraSlow, curve: cinematicCurve),
    const SlideEffect(
      begin: Offset(-0.8, 0),
      end: Offset.zero,
      duration: extraSlow,
      curve: springCurve,
    ),
    const ScaleEffect(
      begin: Offset(0.9, 0.9),
      end: Offset(1.0, 1.0),
      duration: extraSlow,
      curve: elasticOut,
    ),
  ];

  /// Időjárás widget animáció
  static List<Effect> get weatherAnimation => [
    const ScaleEffect(
      begin: Offset(0.3, 0.3),
      end: Offset(1.0, 1.0),
      duration: extraSlow,
      curve: Curves.easeOutBack,
    ),
    const FadeEffect(duration: slow, curve: ultraSmoothCurve),
    const ShimmerEffect(
      duration: Duration(milliseconds: 1500),
      delay: Duration(milliseconds: 500),
    ),
  ];

  /// Ultra smooth kártya belépő animáció
  static List<Effect> get cardEnterAnimation => [
    const FadeEffect(duration: slow, curve: ultraSmoothCurve),
    const SlideEffect(
      begin: Offset(0, 0.5),
      duration: slow,
      curve: ultraSmoothCurve,
    ),
    const ScaleEffect(
      begin: Offset(0.7, 0.7),
      duration: slow,
      curve: ultraSmoothCurve,
    ),
  ];

  /// Szuper smooth lista elem animáció késleltetéssel
  static List<Effect> listItemAnimation(int index) => [
    FadeEffect(
      duration: slow,
      delay: Duration(milliseconds: index * 80),
      curve: ultraSmoothCurve,
    ),
    SlideEffect(
      begin: const Offset(0, 0.4),
      duration: slow,
      delay: Duration(milliseconds: index * 80),
      curve: ultraSmoothCurve,
    ),
    ScaleEffect(
      begin: const Offset(0.8, 0.8),
      duration: slow,
      delay: Duration(milliseconds: index * 80),
      curve: ultraSmoothCurve,
    ),
  ];

  /// Ultra smooth splash screen logo animáció
  static List<Effect> get splashLogoAnimation => [
    const ScaleEffect(
      begin: Offset(0.3, 0.3),
      duration: Duration(milliseconds: 2000),
      curve: Curves.easeOutBack,
    ),
    const FadeEffect(
      duration: Duration(milliseconds: 1500),
      curve: Curves.easeOutQuart,
    ),
    const ShimmerEffect(
      duration: Duration(milliseconds: 2500),
      delay: Duration(milliseconds: 800),
    ),
  ];

  /// Szuper smooth lebegő gomb animáció
  static List<Effect> get fabAnimation => [
    const ScaleEffect(
      begin: Offset(0, 0),
      duration: extraSlow,
      curve: Curves.easeOutBack,
    ),
    const FadeEffect(duration: slow, curve: ultraSmoothCurve),
  ];

  /// Ultra smooth menü megnyitás animáció
  static List<Effect> get menuOpenAnimation => [
    const SlideEffect(
      begin: Offset(-1, 0),
      duration: slow,
      curve: ultraSmoothCurve,
    ),
    const FadeEffect(duration: slow, curve: ultraSmoothCurve),
    const ScaleEffect(
      begin: Offset(0.9, 0.9),
      duration: slow,
      curve: ultraSmoothCurve,
    ),
  ];

  /// Hiba üzenet animáció
  static List<Effect> get errorAnimation => [
    const SlideEffect(
      begin: Offset(0, -1),
      duration: normal,
      curve: defaultCurve,
    ),
    const ShakeEffect(duration: Duration(milliseconds: 600), delay: normal),
  ];

  /// Siker animáció
  static List<Effect> get successAnimation => [
    const ScaleEffect(begin: Offset(0, 0), duration: normal, curve: elasticOut),
    const FadeEffect(duration: fast),
  ];

  /// Betöltő animáció
  static List<Effect> get loadingAnimation => [
    const ScaleEffect(
      begin: Offset(0.8, 0.8),
      end: Offset(1.2, 1.2),
      duration: Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    ),
  ];

  /// Kedvenc hozzáadás animáció
  static List<Effect> get favoriteAnimation => [
    const ScaleEffect(
      begin: Offset(1, 1),
      end: Offset(1.3, 1.3),
      duration: Duration(milliseconds: 150),
      curve: Curves.easeOut,
    ),
    const ScaleEffect(
      begin: Offset(1.3, 1.3),
      end: Offset(1, 1),
      duration: Duration(milliseconds: 150),
      curve: Curves.easeIn,
      delay: Duration(milliseconds: 150),
    ),
  ];

  /// Ultra modern szolgáltatás kártya animáció
  static List<Effect> serviceCardAnimation(int index) => [
    FadeEffect(
      duration: slow,
      delay: Duration(milliseconds: index * 120 + 200),
      curve: ultraSmoothCurve,
    ),
    SlideEffect(
      begin: Offset(index.isEven ? -0.6 : 0.6, 0.4),
      end: Offset.zero,
      duration: slow,
      delay: Duration(milliseconds: index * 120 + 200),
      curve: springCurve,
    ),
    ScaleEffect(
      begin: const Offset(0.75, 0.75),
      end: const Offset(1.0, 1.0),
      duration: slow,
      delay: Duration(milliseconds: index * 120 + 200),
      curve: elasticOut,
    ),
    ShimmerEffect(
      duration: const Duration(milliseconds: 1500),
      delay: Duration(milliseconds: index * 120 + 400),
    ),
  ];

  /// App bar ultra smooth animáció
  static List<Effect> get appBarAnimation => [
    const FadeEffect(
      duration: slow,
      delay: Duration(milliseconds: 300),
      curve: ultraSmoothCurve,
    ),
    const SlideEffect(
      begin: Offset(0, -0.5),
      end: Offset.zero,
      duration: slow,
      delay: Duration(milliseconds: 300),
      curve: springCurve,
    ),
    const ScaleEffect(
      begin: Offset(0.9, 0.9),
      end: Offset(1.0, 1.0),
      duration: slow,
      delay: Duration(milliseconds: 300),
      curve: elasticOut,
    ),
  ];

  /// Szekció címek animációja
  static List<Effect> get sectionTitleAnimation => [
    const FadeEffect(duration: normal, curve: ultraSmoothCurve),
    const SlideEffect(
      begin: Offset(-0.3, 0),
      end: Offset.zero,
      duration: normal,
      curve: smoothCurve,
    ),
    const ScaleEffect(
      begin: Offset(0.95, 0.95),
      end: Offset(1.0, 1.0),
      duration: normal,
      curve: elasticOut,
    ),
  ];

  /// News ticker ultra smooth animáció
  static List<Effect> get newsTickerAnimation => [
    const FadeEffect(
      duration: slow,
      delay: Duration(milliseconds: 600),
      curve: ultraSmoothCurve,
    ),
    const SlideEffect(
      begin: Offset(0, 0.5),
      end: Offset.zero,
      duration: slow,
      delay: Duration(milliseconds: 600),
      curve: springCurve,
    ),
    const ShimmerEffect(
      duration: Duration(milliseconds: 2000),
      delay: Duration(milliseconds: 800),
    ),
  ];

  /// Refresh indicator smooth animáció
  static List<Effect> get refreshAnimation => [
    const ScaleEffect(
      begin: Offset(0.8, 0.8),
      end: Offset(1.0, 1.0),
      duration: normal,
      curve: elasticOut,
    ),
    const FadeEffect(duration: fast, curve: ultraSmoothCurve),
  ];

  /// Lebegő gomb ultra smooth animáció
  static List<Effect> get floatingButtonAnimation => [
    const ScaleEffect(
      begin: Offset(0, 0),
      end: Offset(1.0, 1.0),
      duration: extraSlow,
      curve: Curves.easeOutBack,
    ),
    const FadeEffect(duration: slow, curve: ultraSmoothCurve),
    const ShimmerEffect(
      duration: Duration(milliseconds: 1000),
      delay: Duration(milliseconds: 500),
    ),
  ];

  /// Mikrointerakció - gomb nyomás
  static List<Effect> get buttonPressAnimation => [
    const ScaleEffect(
      begin: Offset(1.0, 1.0),
      end: Offset(0.95, 0.95),
      duration: ultraFast,
      curve: Curves.easeInOut,
    ),
  ];

  /// Mikrointerakció - hover effect
  static List<Effect> get hoverAnimation => [
    const ScaleEffect(
      begin: Offset(1.0, 1.0),
      end: Offset(1.05, 1.05),
      duration: fast,
      curve: smoothCurve,
    ),
    const ShimmerEffect(duration: Duration(milliseconds: 800)),
  ];
}

/// Oldal átmenet animációk
class PageTransitions {
  PageTransitions._();

  /// Ultra smooth csúsztatás balról
  static PageRouteBuilder slideFromLeft(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppAnimations.ultraSmoothCurve,
            ),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: AppAnimations.slow,
    );
  }

  /// Ultra smooth csúsztatás jobbról
  static PageRouteBuilder slideFromRight(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, _, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppAnimations.ultraSmoothCurve,
            ),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: AppAnimations.slow,
    );
  }

  /// Ultra smooth növekedő átmenet
  static PageRouteBuilder scaleTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, _, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.7, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppAnimations.ultraSmoothCurve,
            ),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: AppAnimations.slow,
    );
  }

  /// Ultra smooth fade átmenet
  static PageRouteBuilder fadeTransition(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, _) => page,
      transitionsBuilder: (context, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: AppAnimations.ultraSmoothCurve,
          ),
          child: child,
        );
      },
      transitionDuration: AppAnimations.normal,
    );
  }
}
