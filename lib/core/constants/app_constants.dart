/// Alkalmazás konstansok - API végpontok, időzítések és konfigurációk
class AppConstants {
  AppConstants._();

  // API végpontok
  static const String baseUrl = 'https://mobilalkalmazas.mvkzrt.hu:8443';
  static const String analyzerEndpoint = '/analyzer.php';

  // API paraméterek
  static const String apiVersion = '53';
  static const String userAgent =
      'Dalvik/2.1.0 (Linux; U; Android 15; SM-A566B Build/AP3A.240905.015.A2)';
  static const String host = 'mobilalkalmazas.mvkzrt.hu:8443';

  // Időzítések (milliszekundumban)
  static const int stopRefreshInterval = 30000; // 30 másodperc
  static const int retryDelay = 2000; // 2 másodperc
  static const int animationDuration = 300; // 300ms
  static const int splashAnimationDuration = 2000; // 2 másodperc
  static const int shimmerDuration = 1500; // 1.5 másodperc

  // UI méretek
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 24.0;
  static const double iconSize = 24.0;
  static const double fabSize = 56.0;

  // Térképezés
  static const double defaultMapZoom = 14.0;
  static const double maxMapZoom = 18.0;
  static const double minMapZoom = 10.0;

  // Offline tárolás
  static const int maxCachedStops = 50;
  static const int cacheExpirationHours = 24;

  // Támogatott nyelvek
  static const List<String> supportedLanguages = ['hu', 'en', 'de'];
  static const String defaultLanguage = 'hu';
}

/// Route nevek a navigációhoz
class RouteNames {
  RouteNames._();

  static const String splash = '/splash';
  static const String home = '/home';
  static const String timetable = '/timetable';
  static const String stops = '/stops';
  static const String stopDetails = '/stop-details';
  static const String routePlanning = '/route-planning';
  static const String favorites = '/favorites';
  static const String trafficNews = '/traffic-news';
  static const String newsDetails = '/news-details';
  static const String nearby = '/nearby';
  static const String gallery = '/gallery';
  static const String settings = '/settings';
}

/// Asset útvonalak
class AssetPaths {
  AssetPaths._();

  // Képek
  static const String mvkLogo = 'assets/images/mvk_logo.png';
  static const String busIcon = 'assets/images/bus_icon.svg';
  static const String tramIcon = 'assets/images/tram_icon.svg';

  // Lottie animációk
  static const String loadingAnimation = 'assets/lottie/loading.json';
  static const String splashAnimation = 'assets/lottie/splash.json';
  static const String emptyStateAnimation = 'assets/lottie/empty_state.json';

  // Rive animációk
  static const String vehicleMovement = 'assets/rive/vehicle_movement.riv';
  static const String menuAnimation = 'assets/rive/menu_animation.riv';
}
