import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_themes.dart';
import 'core/services/theme_service.dart';
import 'core/services/app_state_manager.dart';
import 'features/home/presentation/pages/splash_screen.dart';
import 'shared/widgets/main_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Orientáció rögzítése - csak portré mód
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Performance optimalizációk
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // App State Manager inicializálása
  final appStateManager = AppStateManager();
  appStateManager.initialize();

  // Theme service inicializálása
  final themeService = ThemeService();
  await themeService.initTheme();

  runApp(MVKApp(themeService: themeService, appStateManager: appStateManager));
}

class MVKApp extends StatelessWidget {
  final ThemeService themeService;
  final AppStateManager appStateManager;

  const MVKApp({
    super.key,
    required this.themeService,
    required this.appStateManager,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: appStateManager),
      ],
      child: Consumer2<ThemeService, AppStateManager>(
        builder: (context, themeService, appStateManager, child) {
          return MaterialApp(
            title: 'MVK Miskolc',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeService.themeMode,
            // Intelligens routing az app state alapján
            home:
                appStateManager.shouldShowSplash
                    ? const SplashScreen()
                    : const MainNavigationWrapper(),
            // Performance optimalizációk
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler:
                      TextScaler.noScaling, // Szöveg méretezés kikapcsolása
                ),
                child: child!,
              );
            },
            routes: {
              '/home': (context) => const MainNavigationWrapper(),
              '/splash': (context) => const SplashScreen(),
            },
          );
        },
      ),
    );
  }
}
