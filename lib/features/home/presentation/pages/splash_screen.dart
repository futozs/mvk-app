import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
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
    // Gyors UI animációk indítása
    _backgroundController.forward();
    _particlesController.repeat();

    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 200));
    _textController.forward();

    // Cache állapot ellenőrzése
    await _checkCacheStatus();

    // Cache betöltési folyamat
    await _performCacheLoading();

    // Navigáció a főoldalra
    await _navigateToHome();
  }

  Future<void> _checkCacheStatus() async {
    setState(() {
      _loadingMessage = 'Alkalmazás állapotának ellenőrzése...';
      _loadingProgress = 0.1;
    });

    // Cache service inicializálása
    await _cacheService.initialize();

    // Ellenőrizzük hogy ez első indítás-e
    _isFirstRun = !_cacheService.isPreloadCompleted;

    setState(() {
      _loadingProgress = 0.2;
    });

    if (_isFirstRun) {
      setState(() {
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
    setState(() {
      _loadingMessage = 'Hírek betöltése...';
      _loadingProgress = 0.3;
    });
    await _cacheService.getNews(); // Valódi hírek betöltése

    // 2. Időjárás betöltése
    setState(() {
      _loadingMessage = 'Időjárás adatok betöltése...';
      _loadingProgress = 0.5;
    });
    await _cacheService.getWeather(); // Valódi időjárás betöltése

    // 3. Főoldalak előre renderelése
    setState(() {
      _loadingMessage = 'Oldalak előkészítése...';
      _loadingProgress = 0.7;
    });
    await _prerenderMainApp();

    // 4. Képek és beállítások
    setState(() {
      _loadingMessage = 'Képek és beállítások előkészítése...';
      _loadingProgress = 0.85;
    });
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Egyéb előkészítések

    // 5. Befejezés
    setState(() {
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
      if (mounted) {
        setState(() {
          // Widget tree frissítése
        });

        // Kis várakozás a render process-hez
        await Future.delayed(const Duration(milliseconds: 100));

        // Precache images, widgets, stb.
        await _precacheResources();

        debugPrint('✅ SplashScreen: Főoldalak előre renderelése kész!');
      }
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
    setState(() {
      _loadingMessage = 'Cache ellenőrzése...';
      _loadingProgress = 0.4;
    });
    await Future.delayed(const Duration(milliseconds: 150));

    setState(() {
      _loadingMessage = 'Adatok frissítése...';
      _loadingProgress = 0.8;
    });
    await Future.delayed(const Duration(milliseconds: 100));

    setState(() {
      _loadingMessage = 'Alkalmazás indítása...';
      _loadingProgress = 1.0;
    });
    await Future.delayed(const Duration(milliseconds: 100));
  }

  Future<void> _navigateToHome() async {
    setState(() {
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

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _backgroundController.dispose();
    _particlesController.dispose();
    _progressController.dispose();
    super.dispose();
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
                  'MVK Miskolc',
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
