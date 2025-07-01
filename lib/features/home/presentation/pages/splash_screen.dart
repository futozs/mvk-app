import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/app_cache_service.dart';
import '../../../../core/services/app_state_manager.dart';
import '../../../../shared/widgets/main_navigation_wrapper.dart';
import 'dart:math' as math;

// Floating particle data class
class FloatingParticle {
  Offset position;
  double size;
  Color color;
  double speed;
  double direction;
  double opacity;

  FloatingParticle({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
    required this.direction,
    required this.opacity,
  });
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _backgroundController;
  late AnimationController _particlesController;
  late AnimationController _progressController;

  // Floating particles list
  List<FloatingParticle> _particles = [];
  final int _particleCount = 25;

  // Cache loading state
  final AppCacheService _cacheService = AppCacheService();
  late final AppStateManager _appStateManager;
  double _loadingProgress = 0.0;
  String _loadingMessage = 'Inizializálás...';
  bool _isFirstRun = false;
  bool _disposed = false; // Flag to prevent setState after dispose

  // Prerendering
  Widget? _prerenderedMainApp;

  @override
  void initState() {
    super.initState();

    // App State Manager inicializálása
    _appStateManager = context.read<AppStateManager>();

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particlesController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeParticles();
    _startLoadingSequence();
  }

  void _initializeParticles() {
    final random = math.Random();
    _particles = List.generate(_particleCount, (index) {
      return FloatingParticle(
        position: Offset(random.nextDouble() * 400, random.nextDouble() * 800),
        size: random.nextDouble() * 4 + 2,
        color:
            [
              AppColors.primaryGreen.withOpacity(0.3),
              AppColors.secondaryGreen.withOpacity(0.25),
              Colors.white.withOpacity(0.4),
              AppColors.primaryGreen.withOpacity(0.2),
            ][random.nextInt(4)],
        speed: random.nextDouble() * 0.5 + 0.2,
        direction: random.nextDouble() * 2 * math.pi,
        opacity: random.nextDouble() * 0.6 + 0.2,
      );
    });
  }

  void _startLoadingSequence() async {
    // Debug: Splash screen indítása
    debugPrint('🚀 SplashScreen: Loading sequence kezdése...');

    // Gyors UI animációk indítása
    _backgroundController.forward();
    _particlesController.repeat();

    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    // CRITICAL: Disclaimer ellenőrzés MINDIG az elején
    await _checkAndShowDisclaimer();

    // Cache állapot ellenőrzése
    await _checkCacheStatus();

    // Cache betöltési folyamat
    await _performCacheLoading();

    // Navigáció a főoldalra
    await _navigateToHome();
  }

  /// Disclaimer ellenőrzése és megjelenítése
  Future<void> _checkAndShowDisclaimer() async {
    debugPrint('⚠️ SplashScreen: Disclaimer ellenőrzés kezdése...');

    try {
      final prefs = await SharedPreferences.getInstance();
      final disclaimerShown = prefs.getBool('disclaimer_shown') ?? false;

      debugPrint(
        '🔍 SplashScreen: Disclaimer státusz - megjelent: $disclaimerShown',
      );

      if (!disclaimerShown) {
        debugPrint('📋 SplashScreen: Disclaimer megjelenítése...');
        _safeSetState(() {
          _loadingMessage = 'Felhasználói feltételek...';
          _loadingProgress = 0.05;
        });

        // BLOKKOLÁS: Megvárjuk hogy elfogadják
        final accepted = await _showDisclaimerDialog();

        if (accepted) {
          // Disclaimer elfogadva, mentjük
          await prefs.setBool('disclaimer_shown', true);
          debugPrint('✅ SplashScreen: Disclaimer elfogadva és elmentve');
          _isFirstRun = true;
        } else {
          // Nem fogadták el - APP BEZÁRÁSA
          debugPrint('❌ SplashScreen: Disclaimer elutasítva - app bezárása');
          // SystemNavigator.pop() használata az app teljes bezárásához
          SystemNavigator.pop();
          return; // NEM FOLYTATJUK!
        }
      } else {
        debugPrint('✅ SplashScreen: Disclaimer már elfogadva, folytatás...');
        _isFirstRun = false;
      }
    } catch (e) {
      debugPrint('❌ SplashScreen: Hiba a disclaimer ellenőrzésben: $e');
      // Fallback: ha hiba van, mutassuk a disclaimer-t
      _isFirstRun = true;
      final accepted = await _showDisclaimerDialog();
      if (!accepted) {
        // SystemNavigator.pop() használata az app teljes bezárásához
        SystemNavigator.pop();
        return;
      }
    }
  }

  Future<void> _checkCacheStatus() async {
    _safeSetState(() {
      _loadingMessage = 'Alkalmazás állapotának ellenőrzése...';
      _loadingProgress = 0.1;
    });

    // Cache service inicializálása
    await _cacheService.initialize();

    _safeSetState(() {
      _loadingProgress = 0.2;
    });

    if (_isFirstRun) {
      _safeSetState(() {
        _loadingMessage = 'Első indítás - ez lassabb lehet...';
      });
      await Future.delayed(const Duration(milliseconds: 1000));
    }
  }

  Future<void> _performCacheLoading() async {
    if (_isFirstRun) {
      // Első indítás - teljes betöltés lépésekkel
      await _performFirstRunLoading();
    } else {
      // Ismételt indítás - gyors ellenőrzés
      await _performQuickLoading();
    }
  }

  Future<void> _performFirstRunLoading() async {
    // 1. Hírek betöltése
    _safeSetState(() {
      _loadingMessage = 'Hírek betöltése...';
      _loadingProgress = 0.3;
    });
    await _cacheService.getNews(); // Valódi hírek betöltése

    // 2. Időjárás betöltése
    _safeSetState(() {
      _loadingMessage = 'Időjárás adatok betöltése...';
      _loadingProgress = 0.5;
    });
    await _cacheService.getWeather(); // Valódi időjárás betöltése

    // 3. Főoldalak előre renderelése
    _safeSetState(() {
      _loadingMessage = 'Oldalak előkészítése...';
      _loadingProgress = 0.7;
    });
    await _prerenderMainApp();

    // 4. Képek és beállítások
    _safeSetState(() {
      _loadingMessage = 'Képek és beállítások előkészítése...';
      _loadingProgress = 0.85;
    });
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Egyéb előkészítések

    // 5. Befejezés
    _safeSetState(() {
      _loadingMessage = 'Alkalmazás előkészítése...';
      _loadingProgress = 1.0;
    });
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Főoldalak előre renderelése a swipe lag elkerülésére
  Future<void> _prerenderMainApp() async {
    try {
      debugPrint('🚀 SplashScreen: Főoldalak előre renderelése kezdődik...');

      // Invisible widget tree létrehozása a főoldalakkal
      _prerenderedMainApp = Offstage(
        offstage: true,
        child: const MainNavigationWrapper(),
      );

      // Force build a widget tree
      _safeSetState(() {
        // Widget tree frissítése
      });

      // Kis várakozás a render process-hez
      await Future.delayed(const Duration(milliseconds: 100));

      // Precache images, widgets, stb.
      await _precacheResources();

      debugPrint('✅ SplashScreen: Főoldalak előre renderelése kész!');
    } catch (e) {
      debugPrint('❌ SplashScreen: Prerender hiba: $e');
      // Fallback - ha a prerender nem sikerül, folytatjuk
    }
  }

  /// Képek és egyéb erőforrások előre cache-elése
  Future<void> _precacheResources() async {
    try {
      // Főbb képek előre betöltése
      final imagesToCache = [
        'assets/images/mlogo.png',
        'assets/images/mlogobig.png',
        // További képek itt...
      ];

      for (final imagePath in imagesToCache) {
        if (mounted) {
          try {
            await precacheImage(AssetImage(imagePath), context);
          } catch (e) {
            debugPrint('⚠️ Kép cache hiba ($imagePath): $e');
          }
        }
      }

      debugPrint('🖼️ SplashScreen: Képek cache-elése kész');
    } catch (e) {
      debugPrint('❌ SplashScreen: Precache hiba: $e');
    }
  }

  Future<void> _performQuickLoading() async {
    // Gyors betöltés korábbi felhasználóknak
    _safeSetState(() {
      _loadingMessage = 'Cache ellenőrzése...';
      _loadingProgress = 0.4;
    });
    await Future.delayed(const Duration(milliseconds: 150));

    _safeSetState(() {
      _loadingMessage = 'Adatok frissítése...';
      _loadingProgress = 0.8;
    });
    await Future.delayed(const Duration(milliseconds: 100));

    _safeSetState(() {
      _loadingMessage = 'Alkalmazás indítása...';
      _loadingProgress = 1.0;
    });
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _navigateToHome() async {
    _safeSetState(() {
      _loadingMessage = 'Kész!';
    });

    await Future.delayed(const Duration(milliseconds: 300));

    if (mounted) {
      // Jelezzük az AppStateManager-nek, hogy az app elindult
      _appStateManager.markAppAsStarted();

      // Navigálunk a főoldalra
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  /// Disclaimer dialog megjelenítése első indításkor
  Future<bool> _showDisclaimerDialog() async {
    debugPrint('🎯 SplashScreen: Disclaimer dialog építése...');

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Nem lehet bezárni kattintással
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        debugPrint('📱 SplashScreen: Disclaimer dialog megjelenítve');

        // Dark mode ellenőrzése
        final brightness = MediaQuery.of(context).platformBrightness;
        final isDarkMode = brightness == Brightness.dark;

        // Színek dark mode alapján
        final backgroundColor =
            isDarkMode ? Colors.grey.shade900 : Colors.white;
        final cardColor =
            isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50;
        final textColor = isDarkMode ? Colors.white : Colors.black87;

        return WillPopScope(
          onWillPop: () async => false, // Nem lehet visszalépéssel bezárni
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ), // Szélesebb
            child: Container(
              width: double.maxFinite, // Teljes szélesség
              constraints: BoxConstraints(
                maxHeight:
                    MediaQuery.of(context).size.height * 0.9, // Max magasság
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [backgroundColor, cardColor, backgroundColor],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                    spreadRadius: 5,
                  ),
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    blurRadius: 40,
                    offset: const Offset(0, 0),
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kisebb fejléc
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryGreen,
                          AppColors.secondaryGreen,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Kisebb figyelmeztetés ikon
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: Colors.orange,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FIGYELMEZTETÉS',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'ALPHA VERZIÓ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.9),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Scrollable tartalom
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nem hivatalos figyelmeztetés
                          _buildDisclaimerSection(
                            '🚫 NEM HIVATALOS ALKALMAZÁS',
                            'Ez az alkalmazás NEM a Miskolci Városi Közlekedési Zrt. hivatalos szoftvere! '
                                'Egy független fejlesztő készítette, és NINCS KAPCSOLATBAN a hivatalos MVK-val.',
                            Colors.red.shade600,
                            isDarkMode,
                            textColor,
                          ),

                          const SizedBox(height: 14),

                          // Alpha verzió figyelmeztetés
                          _buildDisclaimerSection(
                            '⚠️ ALPHA VERZIÓ - CSAK DEMO!',
                            'Ez egy korai fejlesztési verzió! A legtöbb funkció még NEM MŰKÖDIK. '
                                'Ez csak egy bemutató arról, hogyan fog kinézni a végleges alkalmazás.',
                            Colors.orange.shade600,
                            isDarkMode,
                            textColor,
                          ),

                          const SizedBox(height: 14),

                          // Adatvédelem
                          _buildDisclaimerSection(
                            '🔒 ADATVÉDELEM',
                            'Az alkalmazás NEM gyűjt személyes adatokat és NEM végez adathalászatot. '
                                'A teljes forráskód nyílt és elérhető a GitHub-on.',
                            Colors.green.shade600,
                            isDarkMode,
                            textColor,
                          ),

                          const SizedBox(height: 16),

                          // GitHub link - kompaktabb
                          GestureDetector(
                            onTap: () async {
                              try {
                                final Uri url = Uri.parse(
                                  'https://github.com/futozs/mvk-app',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                }
                              } catch (e) {
                                debugPrint('GitHub link megnyitási hiba: $e');
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    isDarkMode
                                        ? Colors.grey.shade800
                                        : Colors.blue.shade50,
                                    isDarkMode
                                        ? Colors.grey.shade700
                                        : Colors.blue.shade100,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      isDarkMode
                                          ? Colors.blue.shade700
                                          : Colors.blue.shade200,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade600,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.code,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'NYÍLT FORRÁSKÓD',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color:
                                              isDarkMode
                                                  ? Colors.blue.shade300
                                                  : Colors.blue.shade700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isDarkMode
                                              ? Colors.grey.shade900
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isDarkMode
                                                ? Colors.grey.shade600
                                                : Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.link,
                                          color: Colors.blue.shade600,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            'github.com/futozs/mvk-app',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade600,
                                              fontFamily: 'monospace',
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.touch_app,
                                        color:
                                            isDarkMode
                                                ? Colors.grey.shade400
                                                : Colors.grey.shade600,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        'Kattints a megnyitáshoz',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isDarkMode
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Gombok
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    child: Column(
                      children: [
                        // Elfogadom gomb
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pop(true); // TRUE = elfogadva
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 8,
                              shadowColor: AppColors.primaryGreen.withOpacity(
                                0.4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(23),
                              ),
                            ),
                            child: const Text(
                              'ELFOGADOM ÉS FOLYTATOM',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Kilépés gomb
                        SizedBox(
                          width: double.infinity,
                          height: 38,
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(
                                context,
                              ).pop(false); // FALSE = elutasítva
                            },
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                            child: const Text(
                              'Kilépés az alkalmazásból',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    return result ?? false; // Ha null, akkor false (elutasítva)
  }

  Widget _buildDisclaimerSection(
    String title,
    String content,
    Color color,
    bool isDarkMode,
    Color textColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDarkMode ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isDarkMode ? 0.4 : 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true; // Mark as disposed to prevent setState calls
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _particlesController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  // Safe setState that checks if widget is still mounted and not disposed
  void _safeSetState(VoidCallback fn) {
    if (!_disposed && mounted) {
      setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Prerendered main app (invisible)
          if (_prerenderedMainApp != null) _prerenderedMainApp!,

          // Splash screen tartalom
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen.withValues(
                        alpha: 0.9 + (_backgroundController.value * 0.1),
                      ),
                      AppColors.secondaryGreen.withValues(
                        alpha: 0.7 + (_backgroundController.value * 0.3),
                      ),
                      Colors.teal.shade300.withValues(
                        alpha: 0.5 + (_backgroundController.value * 0.2),
                      ),
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Háttér mintázat
                    _buildBackgroundPattern(),

                    // Fő tartalom
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // MVK Logo
                          _buildAnimatedLogo(),

                          const SizedBox(height: 30),

                          // Szöveg animáció
                          _buildAnimatedText(),

                          const SizedBox(height: 50),

                          // Betöltő indikátor
                          _buildLoadingIndicator(),
                        ],
                      ),
                    ),

                    // Verzió információ
                    _buildVersionInfo(),

                    // Lebegő részecskék
                    _buildFloatingParticles(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPatternPainter(animation: _backgroundController),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _logoController,
      builder: (context, child) {
        final scaleValue = Curves.elasticOut.transform(_logoController.value);
        final rotationValue = _logoController.value * 0.1;

        return Transform.scale(
          scale: scaleValue,
          child: Transform.rotate(
            angle: rotationValue,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.white.withValues(alpha: 0.9)],
                ),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    blurRadius: 40,
                    offset: const Offset(0, 0),
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: Image.asset(
                  'assets/images/mlogo.png',
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
    ).animate().shimmer(
      duration: const Duration(milliseconds: 2500),
      delay: const Duration(milliseconds: 1500),
      color: Colors.white.withValues(alpha: 0.4),
    );
  }

  Widget _buildAnimatedText() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        final slideValue = Curves.easeOutBack.transform(_textController.value);

        return Opacity(
          opacity: _textController.value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - slideValue)),
            child: Column(
              children: [
                Text(
                  'reMOBILON',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2.0,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Közösségi Közlekedés',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return AnimatedBuilder(
      animation: _textController,
      builder: (context, child) {
        return Opacity(
          opacity: _textController.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress Bar
                Container(
                  width: double.infinity,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _loadingProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Loading Message
                Text(
                  _loadingMessage,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Progress Percentage
                Text(
                  '${(_loadingProgress * 100).round()}%',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // First Run Warning
                if (_isFirstRun && _loadingProgress < 0.9) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '⚠️ Első indítás - kicsit lassabb',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVersionInfo() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _textController,
        builder: (context, child) {
          return Opacity(
            opacity: _textController.value,
            child: Center(
              child: Text(
                'Verzió 1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _particlesController,
        builder: (context, child) {
          return CustomPaint(
            painter: ParticlePainter(
              particles: _particles,
              animation: _particlesController,
            ),
          );
        },
      ),
    );
  }
}

class BackgroundPatternPainter extends CustomPainter {
  final Animation<double> animation;

  BackgroundPatternPainter({required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1 * animation.value)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    const spacing = 40.0;

    // Függőleges vonalak
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Vízszintes vonalak
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Animált körök
    final circlePaint =
        Paint()
          ..color = Colors.white.withOpacity(0.05 * animation.value)
          ..style = PaintingStyle.fill;

    final radius = 50 * animation.value;
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.3),
      radius,
      circlePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.7),
      radius * 0.7,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) {
    return animation != oldDelegate.animation;
  }
}

class ParticlePainter extends CustomPainter {
  final List<FloatingParticle> particles;
  final Animation<double> animation;

  ParticlePainter({required this.particles, required this.animation})
    : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withOpacity(particle.opacity)
            ..style = PaintingStyle.fill;

      final x =
          particle.position.dx +
          math.cos(particle.direction) * 10 * animation.value;
      final y =
          particle.position.dy +
          math.sin(particle.direction) * 10 * animation.value;

      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return particles != oldDelegate.particles;
  }
}
