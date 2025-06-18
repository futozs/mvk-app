import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/themes/app_themes.dart';
import 'core/services/theme_service.dart';
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
          return MaterialApp(
            title: 'MVK Miskolc',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeService.themeMode,
            home: const SplashScreen(),
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
