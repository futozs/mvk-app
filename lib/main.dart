import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_themes.dart';
import 'core/services/theme_service.dart';
import 'features/home/presentation/pages/splash_screen.dart';
import 'shared/widgets/main_navigation_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Theme service inicializálása
  final themeService = ThemeService();
  await themeService.initTheme();

  runApp(MVKApp(themeService: themeService));
}

class MVKApp extends StatelessWidget {
  final ThemeService themeService;

  const MVKApp({super.key, required this.themeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: themeService,
      child: Consumer<ThemeService>(
        builder: (context, themeService, child) {
          // Dinamikus rendszer UI beállítások
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  themeService.isDarkMode ? Brightness.light : Brightness.dark,
              systemNavigationBarColor:
                  themeService.isDarkMode
                      ? const Color(0xFF121212)
                      : Colors.white,
              systemNavigationBarIconBrightness:
                  themeService.isDarkMode ? Brightness.light : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'MVK Miskolc',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeService.themeMode,
            home: const SplashScreen(),
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
