import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:convert';
import '../../../../shared/widgets/animated_cards.dart';
import '../../../../shared/widgets/shimmer_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/services/app_cache_service.dart';
import '../../../stop_search/presentation/pages/stop_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _masterController;

  bool _isLoading = true;
  WeatherData? _currentWeather;
  final WeatherService _weatherService = WeatherService();
  final AppCacheService _cacheService = AppCacheService();

  // Automatikus frissítés timer
  Timer? _refreshTimer;

  // Valós hírek adatai - cache mechanizmussal
  List<Map<String, dynamic>> _newsItems = [];
  bool _newsLoading = true;
  String? _newsError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Egyszerűsített animáció kontroller
    _masterController = AnimationController(
      duration: const Duration(milliseconds: 800), // Gyorsabb betöltés
      vsync: this,
    );

    _initializeData();
    _startAutoRefresh();
  }

  Future<void> _initializeData() async {
    // Időjárás betöltése cache service-ből
    try {
      final cachedWeather = await _cacheService.getWeather();
      if (cachedWeather != null) {
        // WeatherData létrehozása a cache-elt adatokból
        _currentWeather = WeatherData(
          temperature: cachedWeather['temperature'] ?? 22,
          condition: _parseWeatherCondition(cachedWeather['condition']),
          humidity: cachedWeather['humidity'] ?? 65,
          windSpeed: cachedWeather['windSpeed'] ?? 12,
          cityName: cachedWeather['city'] ?? 'Miskolc',
          description: cachedWeather['description'] ?? 'Derült',
          timestamp: DateTime.now(),
        );
      } else {
        // Ha nincs cache, próbáljuk meg közvetlenül a weather service-ből
        try {
          _currentWeather = await _weatherService.getCurrentWeather();
        } catch (apiError) {
          print('⚠️ Weather API hiba: $apiError');
          // Ha az API nem elérhető, null-ra állítjuk
          _currentWeather = null;
        }
      }
    } catch (e) {
      print('❌ Időjárás inicializálási hiba: $e');
      // Alapértelmezett időjárás hiba esetén
      _currentWeather = null;
    }

    // Hírek betöltése
    await _loadNews();

    // Gyorsabb betöltés - rövidebb várakozás
    await Future.delayed(const Duration(milliseconds: 200)); // Még gyorsabb

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Egyszerűsített animáció
      _masterController.forward();
    }
  }

  Future<void> _loadNews() async {
    try {
      setState(() {
        _newsLoading = true;
        _newsError = null;
      });

      // Cache service használata
      final cachedNews = await _cacheService.getNews();

      if (cachedNews != null) {
        setState(() {
          _newsItems = cachedNews;
          _newsLoading = false;
        });
      } else {
        setState(() {
          _newsItems = [];
          _newsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _newsError = 'Hiba a hírek betöltésekor: $e';
        _newsLoading = false;
        _newsItems = [];
      });
    }
  }

  /// Automatikus frissítés indítása 5 percenként
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _refreshDataInBackground();
    });
  }

  /// Adatok frissítése a háttérben
  Future<void> _refreshDataInBackground() async {
    try {
      // Cache-ek frissítése
      await _cacheService.getNews(forceRefresh: true);
      await _cacheService.getWeather(forceRefresh: true);

      // Weather service háttér frissítése
      await _weatherService.refreshInBackground();

      // UI frissítése ha mounted
      if (mounted) {
        await _loadNews();
        final cachedWeather = await _cacheService.getWeather();
        if (cachedWeather != null) {
          setState(() {
            _currentWeather = WeatherData(
              temperature: cachedWeather['temperature'] ?? 22,
              condition: _parseWeatherCondition(cachedWeather['condition']),
              humidity: cachedWeather['humidity'] ?? 65,
              windSpeed: cachedWeather['windSpeed'] ?? 12,
              cityName: cachedWeather['city'] ?? 'Miskolc',
              description: cachedWeather['description'] ?? 'Derült',
              timestamp: DateTime.now(),
            );
          });
        }
      }
    } catch (e) {
      print('🔄 Háttér frissítés hiba: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Alkalmazás visszatéréskor frissítés
      _refreshDataInBackground();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _masterController.dispose();
    super.dispose();
  }

  String get _getGreeting {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;

    // Nagyon részletes napszak-alapú köszöntések
    if (hour >= 5 && hour < 9) {
      if (hour < 6) return 'Korán kelő!';
      if (hour < 7) return 'Szuper reggelt!';
      if (hour < 8) return 'Jó reggelt!';
      return 'Kellemes reggelt! ☕';
    } else if (hour >= 9 && hour < 12) {
      if (hour < 10) return 'Jó délelőttöt!';
      if (hour < 11) return 'Szép délelőttöt!';
      return 'Kellemes délelőttöt!';
    } else if (hour >= 12 && hour < 14) {
      if (minute < 30) return 'Jó napot!';
      return 'Kellemes délutánt!';
    } else if (hour >= 14 && hour < 17) {
      return 'Szép délutánt!';
    } else if (hour >= 17 && hour < 19) {
      if (hour < 18) return 'Jó délutánt!';
      return 'Kellemes estét! ';
    } else if (hour >= 19 && hour < 22) {
      if (hour < 21) return 'Jó estét!';
      return 'Kellemes estét!';
    } else if (hour >= 22 || hour < 5) {
      if (hour >= 23 || hour < 1) return 'Jó éjszakát!';
      if (hour < 3) return 'Késő éjjel?';
      return 'Korán kelsz?';
    }
    return 'Szép napot!';
  }

  Color get _getGreetingAccentColor {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 9) return const Color(0xFFFFEB3B); // Reggel sárga
    if (hour >= 9 && hour < 12)
      return const Color(0xFFFFC107); // Délelőtt arany
    if (hour >= 12 && hour < 17)
      return const Color(0xFFFF9800); // Délután narancs
    if (hour >= 17 && hour < 19)
      return const Color(0xFFFF5722); // Kora este vörös
    if (hour >= 19 && hour < 22) return const Color(0xFF9C27B0); // Este lila
    return const Color(0xFF3F51B5); // Éjjel kék
  }

  List<Color> _getWeatherBasedGradient() {
    final hour = DateTime.now().hour;
    final condition = _currentWeather?.condition;

    // Időjárás-függő színek
    if (condition == WeatherCondition.rainy) {
      return [
        const Color(0xFF607D8B), // Szürke-kék
        const Color(0xFF455A64),
        const Color(0xFF37474F),
      ];
    } else if (condition == WeatherCondition.thunderstorm) {
      return [
        const Color(0xFF424242), // Sötét szürke
        const Color(0xFF212121),
        const Color(0xFF1A1A1A),
      ];
    } else if (condition == WeatherCondition.snowy) {
      return [
        const Color(0xFF90CAF9), // Világos kék
        const Color(0xFF64B5F6),
        const Color(0xFF42A5F5),
      ];
    } else if (condition == WeatherCondition.sunny) {
      // Napszak-függő napos színek
      if (hour >= 5 && hour < 9) {
        return [
          const Color(0xFFFFEB3B), // Reggeli arany
          const Color(0xFFFFC107),
          AppColors.getPrimaryColor(context),
        ];
      } else if (hour >= 17 && hour < 20) {
        return [
          const Color(0xFFFF7043), // Esti narancs
          const Color(0xFFFF5722),
          AppColors.getPrimaryColor(context),
        ];
      }
    } else if (condition == WeatherCondition.foggy) {
      return [
        const Color(0xFF78909C), // Ködös szürke
        const Color(0xFF607D8B),
        const Color(0xFF546E7A),
      ];
    }

    // Alapértelmezett vagy felhős időjárás - napszak alapján
    if (hour >= 19 || hour < 6) {
      return [
        const Color(0xFF5C6BC0), // Éjjeli lila-kék
        const Color(0xFF3F51B5),
        const Color(0xFF303F9F),
      ];
    }

    // Alapértelmezett zöld gradiens
    return [
      AppColors.getPrimaryColor(context),
      AppColors.getPrimaryColor(context).withOpacity(0.85),
      AppColors.secondaryGreen.withOpacity(0.9),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: _isLoading ? _buildLoadingState() : _buildMainContent(),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Greeting shimmer
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ShimmerWidgets.cardShimmer(height: 120),
          ),
          const SizedBox(height: 20),
          // Quick access shimmer
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: AppColors.getPrimaryColor(
                    context,
                  ).withOpacity(0.08),
                  highlightColor: Colors.white.withOpacity(0.9),
                  period: const Duration(milliseconds: 2500),
                  child: Container(
                    width: 150,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey.shade100, Colors.grey.shade50],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ShimmerWidgets.quickAccessShimmer(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ShimmerWidgets.newsBannerShimmer(),
          const SizedBox(height: 20),
          ...List.generate(5, (index) => ShimmerWidgets.cardShimmer()),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      backgroundColor: Colors.white,
      color: AppColors.getPrimaryColor(context),
      strokeWidth: 3,
      displacement: 40,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGreetingSection(),
            const SizedBox(height: 20),
            _buildQuickAccessSection(),
            const SizedBox(height: 20),
            _buildNewsSection(),
            const SizedBox(height: 100), // Bottom navigation padding
          ],
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Időjárás frissítése
    try {
      _currentWeather = await _weatherService.getCurrentWeather(
        forceRefresh: true,
      );
    } catch (e) {
      print('⚠️ Weather refresh hiba: $e');
      // Ha az API nem elérhető, próbáljuk meg a cache-ből
      try {
        final cachedWeather = await _cacheService.getWeather();
        if (cachedWeather != null) {
          _currentWeather = WeatherData(
            temperature: cachedWeather['temperature'] ?? 22,
            condition: _parseWeatherCondition(cachedWeather['condition']),
            humidity: cachedWeather['humidity'] ?? 65,
            windSpeed: cachedWeather['windSpeed'] ?? 12,
            cityName: cachedWeather['city'] ?? 'Miskolc',
            description: cachedWeather['description'] ?? 'Derült',
            timestamp: DateTime.now(),
          );
        } else {
          _currentWeather = null;
        }
      } catch (cacheError) {
        print('❌ Cache hiba is: $cacheError');
        _currentWeather = null;
      }
    }

    // Hírek frissítése
    await _loadNews();

    // Smooth refresh animáció
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {});

      // Egyszerűsített animáció újraindítás
      _masterController.reset();
      await Future.delayed(const Duration(milliseconds: 100));
      _masterController.forward();
    }
  }

  Widget _buildGreetingSection() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: Stack(
        children: [
          // Fő köszöntő kártya
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getWeatherBasedGradient(),
                stops: const [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: _getWeatherBasedGradient().first.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: _getWeatherBasedGradient().first.withOpacity(0.1),
                  blurRadius: 60,
                  offset: const Offset(0, 20),
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Háttér dekoráció
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _getGreetingAccentColor.withOpacity(0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedBuilder(
                            animation: _masterController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _masterController,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-0.8, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _masterController,
                                      curve: Curves.easeOut,
                                    ),
                                  ),
                                  child: Text(
                                    _getGreeting,
                                    style: const TextStyle(
                                      fontSize: 28, // Nagyobb betűméretye
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.25),
                                  Colors.white.withOpacity(0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                  spreadRadius: 0,
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 2,
                                  offset: const Offset(0, -1),
                                  spreadRadius: -1,
                                ),
                              ],
                            ),
                            child: Text(
                              _currentWeather?.condition ==
                                      WeatherCondition.rainy
                                  ? 'Vigyázz, esik! Vigyél esernyőt!'
                                  : _currentWeather?.condition ==
                                      WeatherCondition.snowy
                                  ? 'Hó esik! Öltözz fel melegen!'
                                  : _currentWeather?.condition ==
                                      WeatherCondition.sunny
                                  ? 'Szuper időjárás! Élvezd a napot!'
                                  : 'Merre szeretnél utazni ma?',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Időjárás widget super animációkkal
                    _buildWeatherWidget(),
                  ],
                ),
              ],
            ),
          ),
          // Időjárás-függő részecske animációk
          if (_currentWeather != null) _buildWeatherParticles(),
        ],
      ),
    );
  }

  Widget _buildWeatherWidget() {
    return AnimatedBuilder(
      animation: _masterController,
      builder: (context, child) {
        return Transform.scale(
          scale: Curves.easeOut.transform(_masterController.value),
          child: Transform.rotate(
            angle: (1 - _masterController.value) * 0.3,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.3),
                    Colors.white.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(0, -2),
                    spreadRadius: -1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _currentWeather?.animatedWeatherIcon ?? '🌤️',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentWeather?.temperature.round() ?? 22}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (_currentWeather?.description != null)
                    Text(
                      _currentWeather!.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherParticles() {
    if (_currentWeather == null) return const SizedBox.shrink();

    final particles = _currentWeather!.weatherParticles;
    final isRaining = _currentWeather!.condition == WeatherCondition.rainy;
    final isSnowing = _currentWeather!.condition == WeatherCondition.snowy;

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _masterController,
          builder: (context, child) {
            return Stack(
              children: List.generate(
                isRaining || isSnowing
                    ? 8
                    : 4, // Kevesebb részecske a jobb performance miatt
                (index) {
                  final delay = index * 0.15;
                  final animationValue = (_masterController.value - delay)
                      .clamp(0.0, 1.0);

                  // Eső esetén vertikális mozgás
                  double xOffset, yOffset;
                  if (isRaining) {
                    xOffset =
                        (index % 4) * 60.0 +
                        (animationValue * 20); // Enyhe oldalirányú mozgás
                    yOffset = animationValue * 200 - 50; // Felülről lefelé
                  } else if (isSnowing) {
                    xOffset =
                        (index % 4) * 50.0 +
                        (animationValue *
                            40 *
                            (index % 2 == 0 ? 1 : -1)); // Hintázó mozgás
                    yOffset = animationValue * 150 - 30;
                  } else {
                    // Normál körköröző mozgás
                    xOffset =
                        (index % 2 == 0 ? 1 : -1) *
                        (50 + index * 30) *
                        (0.5 + 0.5 * animationValue);
                    yOffset = 100 * animationValue + (index * 20);
                  }

                  return Positioned(
                    left: 50 + xOffset,
                    top: 20 + yOffset,
                    child: Transform.rotate(
                      angle:
                          isRaining
                              ? 0 // Eső nem forog
                              : animationValue *
                                  6.28 *
                                  (index % 2 == 0 ? 1 : -1),
                      child: Opacity(
                        opacity:
                            isRaining || isSnowing
                                ? (0.8 - animationValue * 0.3).clamp(
                                  0.0,
                                  1.0,
                                ) // Eső/hó lassabban tűnik el
                                : (1 - animationValue * 0.7).clamp(0.0, 1.0),
                        child: Text(
                          particles[index % particles.length],
                          style: TextStyle(
                            fontSize:
                                isRaining || isSnowing
                                    ? 14 +
                                        (index % 2) *
                                            2 // Kisebb eső/hó részecskék
                                    : 16 + (index % 3) * 4,
                            shadows:
                                isRaining || isSnowing
                                    ? [
                                      Shadow(
                                        blurRadius: 2,
                                        color: Colors.white.withOpacity(0.5),
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                    : null,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickAccessSection() {
    return AnimatedBuilder(
      animation: _masterController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _masterController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: _masterController, curve: Curves.easeOut),
            ),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 5,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.getPrimaryColor(context),
                              AppColors.secondaryGreen,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.getPrimaryColor(
                                context,
                              ).withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        'Gyors hozzáférés',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.getPrimaryColor(context),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      QuickAccessButton(
                            label: 'Megálló\nkeresés',
                            icon: Symbols.search,
                            onTap: () {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => const StopSearchPage(),
                                  transitionsBuilder: (
                                    context,
                                    animation,
                                    secondaryAnimation,
                                    child,
                                  ) {
                                    const begin = Offset(0.0, 1.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOutCubic;

                                    var tween = Tween(
                                      begin: begin,
                                      end: end,
                                    ).chain(CurveTween(curve: curve));

                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: child,
                                    );
                                  },
                                  transitionDuration: const Duration(
                                    milliseconds: 400,
                                  ),
                                ),
                              );
                            },
                          )
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.slow,
                            delay: const Duration(milliseconds: 100),
                            curve: AppAnimations.ultraSmoothCurve,
                          )
                          .slideX(
                            begin: -1.2,
                            delay: const Duration(milliseconds: 100),
                            duration: AppAnimations.slow,
                            curve: AppAnimations.springCurve,
                          )
                          .scaleXY(
                            begin: 0.7,
                            delay: const Duration(milliseconds: 100),
                            duration: AppAnimations.slow,
                            curve: AppAnimations.elasticOut,
                          )
                          .shimmer(
                            duration: const Duration(milliseconds: 1500),
                            delay: const Duration(milliseconds: 300),
                          ),
                      QuickAccessButton(
                            label: 'Útvonal\ntervezés',
                            icon: Symbols.route,
                            color: const Color.fromARGB(255, 56, 67, 189),
                            onTap: () {
                              // Útvonaltervezés
                            },
                          )
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.slow,
                            delay: const Duration(milliseconds: 200),
                            curve: AppAnimations.ultraSmoothCurve,
                          )
                          .slideY(
                            begin: -1.2,
                            delay: const Duration(milliseconds: 200),
                            duration: AppAnimations.slow,
                            curve: AppAnimations.springCurve,
                          )
                          .scaleXY(
                            begin: 0.7,
                            delay: const Duration(milliseconds: 200),
                            duration: AppAnimations.slow,
                            curve: AppAnimations.elasticOut,
                          )
                          .shimmer(
                            duration: const Duration(milliseconds: 1500),
                            delay: const Duration(milliseconds: 400),
                          ),
                      QuickAccessButton(
                            label: 'Közeli\nmegállók',
                            icon: Symbols.near_me,
                            color: AppColors.secondaryGreen,
                            onTap: () {
                              // Közeli megállók
                            },
                          )
                          .animate()
                          .fadeIn(
                            duration: AppAnimations.slow,
                            delay: const Duration(milliseconds: 300),
                            curve: AppAnimations.ultraSmoothCurve,
                          )
                          .slideX(
                            begin: 1.2,
                            delay: const Duration(milliseconds: 300),
                            duration: AppAnimations.slow,
                            curve: AppAnimations.springCurve,
                          )
                          .scaleXY(
                            begin: 0.7,
                            delay: const Duration(milliseconds: 300),
                            duration: AppAnimations.slow,
                            curve: AppAnimations.elasticOut,
                          )
                          .shimmer(
                            duration: const Duration(milliseconds: 1500),
                            delay: const Duration(milliseconds: 500),
                          ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsSection() {
    if (_newsLoading) {
      return Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.getPrimaryColor(context).withOpacity(0.1),
              AppColors.getPrimaryColor(context).withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.getPrimaryColor(context).withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Icon(
                Symbols.newspaper,
                color: AppColors.getPrimaryColor(context).withOpacity(0.5),
                size: 24,
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppColors.getPrimaryColor(
                            context,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 1000.ms, color: Colors.white54),
                  const SizedBox(height: 8),
                  Container(
                        height: 12,
                        width: 200,
                        decoration: BoxDecoration(
                          color: AppColors.getPrimaryColor(
                            context,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(
                        duration: 1000.ms,
                        color: Colors.white54,
                        delay: 200.ms,
                      ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_newsError != null) {
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF5722).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Symbols.error_outline,
                color: Colors.white,
                size: 24,
              ),
            ),
            Expanded(
              child: Text(
                _newsError!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: GestureDetector(
                onTap: _loadNews,
                child: const Icon(
                  Symbols.refresh,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_newsItems.isEmpty) {
      return Container(
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.getPrimaryColor(context),
              AppColors.getPrimaryColor(context).withOpacity(0.85),
              AppColors.secondaryGreen.withOpacity(0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Icon(
                Symbols.newspaper,
                color: Colors.white,
                size: 24,
              ),
            ),
            Expanded(
              child: const Text(
                'Jelenleg nincsenek elérhető hírek',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _NewsTickerWidget(newsItems: _newsItems);
  }

  /// Weather condition string-et WeatherCondition enum-má alakítja
  WeatherCondition _parseWeatherCondition(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'rainy':
        return WeatherCondition.rainy;
      case 'snowy':
        return WeatherCondition.snowy;
      case 'cloudy':
        return WeatherCondition.cloudy;
      case 'sunny':
      default:
        return WeatherCondition.sunny;
    }
  }
}

class _NewsTickerWidget extends StatefulWidget {
  final List<Map<String, dynamic>> newsItems;

  const _NewsTickerWidget({required this.newsItems});

  @override
  State<_NewsTickerWidget> createState() => _NewsTickerWidgetState();
}

class _NewsTickerWidgetState extends State<_NewsTickerWidget>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    if (widget.newsItems.isNotEmpty) {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _nextPage();
        _animationController.reset();
        _animationController.forward();
      }
    });
    _animationController.forward();
  }

  Future<Map<String, dynamic>?> _loadNewsDetails(String newsId) async {
    try {
      final response = await http.post(
        Uri.parse('https://mobilalkalmazas.mvkzrt.hu:8443/analyzer.php'),
        headers: {
          'User-Agent':
              'Dalvik/2.1.0 (Linux; U; Android 15; SM-A566B Build/AP3A.240905.015.A2)',
          'Host': 'mobilalkalmazas.mvkzrt.hu:8443',
          'Accept-Encoding': 'gzip',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: 'K3WQtr=$newsId&NI9rln8F=1&V=53&o5xfIG1p99=hu',
      );

      if (response.statusCode == 200) {
        final decodedResponse = utf8.decode(response.bodyBytes);
        final jsonData = json.decode(decodedResponse);

        // A válasz `forgalmi_hirek` tömbből keressük az adott ID-t
        if (jsonData['forgalmi_hirek'] != null &&
            jsonData['forgalmi_hirek'].isNotEmpty) {
          // Általában egy elemű tömb jön vissza a konkrét ID-vel
          return jsonData['forgalmi_hirek'][0];
        }
        return jsonData;
      } else {
        print('HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error loading news details: $e');
      return null;
    }
  }

  void _nextPage() {
    if (widget.newsItems.isEmpty) return;

    _currentIndex = (_currentIndex + 1) % widget.newsItems.length;
    _pageController.animateToPage(
      _currentIndex,
      duration: AppAnimations.normal,
      curve: AppAnimations.defaultCurve,
    );
  }

  void _showNewsDetail(Map<String, dynamic> newsItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder:
          (context) => _NewsDetailModal(
            newsItem: newsItem,
            loadNewsDetails: _loadNewsDetails,
          ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.newsItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
          height: 80,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.getPrimaryColor(context),
                AppColors.getPrimaryColor(context).withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.getPrimaryColor(context).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Háttér dekoráció
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Fő tartalom
                Row(
                  children: [
                    // Ikon
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: const Icon(
                        Symbols.campaign,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    // Hírek
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: widget.newsItems.length,
                        itemBuilder: (context, index) {
                          final newsItem = widget.newsItems[index];
                          return GestureDetector(
                            onTap: () => _showNewsDetail(newsItem),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(right: 16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    newsItem['cim'] ?? 'Hír',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Progress indikátor
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return CircularProgressIndicator(
                                  value: _animationController.value,
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.3,
                                  ),
                                );
                              },
                            ),
                          ),
                          Text(
                            '${_currentIndex + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: AppAnimations.slow)
        .slideY(
          begin: 0.3,
          duration: AppAnimations.slow,
          curve: Curves.easeOutCubic,
        );
  }
}

class _NewsDetailModal extends StatefulWidget {
  final Map<String, dynamic> newsItem;
  final Future<Map<String, dynamic>?> Function(String) loadNewsDetails;

  const _NewsDetailModal({
    required this.newsItem,
    required this.loadNewsDetails,
  });

  @override
  State<_NewsDetailModal> createState() => _NewsDetailModalState();
}

class _NewsDetailModalState extends State<_NewsDetailModal> {
  bool _isLoading = true;
  Map<String, dynamic>? _detailData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final newsId = widget.newsItem['id_forgalmi_hir']?.toString() ?? '';
      if (newsId.isNotEmpty) {
        final details = await widget.loadNewsDetails(newsId);
        if (mounted) {
          setState(() {
            _detailData = details;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Hír azonosító hiányzik';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Hiba történt a részletek betöltésekor';
          _isLoading = false;
        });
      }
    }
  }

  String _stripHtmlTags(String htmlText) {
    // Egyszerű HTML tag eltávolítás
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&aacute;', 'á')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&Uuml;', 'Ü')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&Aacute;', 'Á')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&Iacute;', 'Í')
        .replaceAll('&Oacute;', 'Ó')
        .replaceAll('&Uacute;', 'Ú')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.getPrimaryColor(context),
                  AppColors.getPrimaryColor(context).withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Symbols.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Flexible(
            child:
                _isLoading
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.getPrimaryColor(context),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Részletek betöltése...',
                              style: TextStyle(
                                color: AppColors.getTextSecondaryColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    : _error != null
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.error,
                              size: 48,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: Colors.red[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                    : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          // Title
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.getPrimaryColor(
                                    context,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Symbols.newspaper,
                                  color: AppColors.getPrimaryColor(context),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  _detailData?['cim'] ??
                                      widget.newsItem['cim'] ??
                                      'Hír',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.getTextPrimaryColor(
                                      context,
                                    ),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Metadata (without category display)
                          if (_detailData?['modositas_idopontja'] != null ||
                              widget.newsItem['modositas_idopontja'] != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.getCardColor(context),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.getTextSecondaryColor(
                                    context,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Symbols.schedule,
                                    size: 16,
                                    color: AppColors.getTextSecondaryColor(
                                      context,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _detailData?['modositas_idopontja'] ??
                                        widget
                                            .newsItem['modositas_idopontja'] ??
                                        '',
                                    style: TextStyle(
                                      color: AppColors.getTextSecondaryColor(
                                        context,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 24),
                          // Content with clickable links
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.getCardColor(context),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.getTextSecondaryColor(
                                  context,
                                ).withOpacity(0.3),
                              ),
                              boxShadow: AppColors.getCardShadow(context),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Symbols.article,
                                      color: AppColors.getPrimaryColor(context),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Részletek',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.getPrimaryColor(
                                          context,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _ClickableText(
                                  text:
                                      _detailData?['hosszu_tartalom'] != null
                                          ? _stripHtmlTags(
                                            _detailData!['hosszu_tartalom'],
                                          )
                                          : _detailData?['rovid_tartalom'] ??
                                              widget
                                                  .newsItem['rovid_tartalom'] ??
                                              widget.newsItem['cim'] ??
                                              'Nincs tartalom',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.copyWith(
                                    height: 1.6,
                                    color: AppColors.getTextSecondaryColor(
                                      context,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Actions
                          ElevatedButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Symbols.check),
                            label: const Text('Rendben'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.getPrimaryColor(
                                context,
                              ),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 24,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              minimumSize: const Size(double.infinity, 50),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}

class _ClickableText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const _ClickableText({required this.text, this.style});

  Future<void> _launchUrlSafely(String url, BuildContext context) async {
    try {
      // URL tisztítása és validálása
      String cleanUrl = url.trim();

      // Ha nem kezdődik http-vel, hozzáadjuk
      if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
        cleanUrl = 'https://$cleanUrl';
      }

      final uri = Uri.parse(cleanUrl);

      print('Megpróbáljuk megnyitni: $cleanUrl');

      // 1. Próbálkozás: External alkalmazás
      try {
        final canLaunch = await canLaunchUrl(uri);
        print('canLaunchUrl eredmény: $canLaunch');

        if (canLaunch) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          print('Sikeresen megnyitva external alkalmazásban');
          return;
        }
      } catch (e) {
        print('External alkalmazás hiba: $e');
      }

      // 2. Próbálkozás: Platform default
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
        print('Sikeresen megnyitva platform default módban');
        return;
      } catch (e) {
        print('Platform default hiba: $e');
      }

      // 3. Próbálkozás: In-app web view
      try {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
        print('Sikeresen megnyitva in-app web view-ban');
        return;
      } catch (e) {
        print('In-app web view hiba: $e');
      }

      // Ha minden sikertelen, hibaüzenet
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nem sikerült megnyitni a linket: $cleanUrl'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
              textColor: Colors.white,
            ),
          ),
        );
      }
    } catch (e) {
      print('URL parsing hiba: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Érvénytelen link formátum: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  List<TextSpan> _buildTextSpans(BuildContext context) {
    final List<TextSpan> spans = [];
    final urlPattern = RegExp(r'https?://[^\s]+');
    final matches = urlPattern.allMatches(text);

    int lastMatchEnd = 0;

    for (final match in matches) {
      // Szöveg az URL előtt
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      // URL link
      final url = text.substring(match.start, match.end);
      spans.add(
        TextSpan(
          text: url,
          style:
              style?.copyWith(
                color: AppColors.getPrimaryColor(context),
                decoration: TextDecoration.underline,
              ) ??
              TextStyle(
                color: AppColors.getPrimaryColor(context),
                decoration: TextDecoration.underline,
              ),
          recognizer:
              TapGestureRecognizer()
                ..onTap = () => _launchUrlSafely(url, context),
        ),
      );

      lastMatchEnd = match.end;
    }

    // Maradék szöveg az utolsó URL után
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd), style: style));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final spans = _buildTextSpans(context);

    return RichText(
      text: TextSpan(
        children: spans.isEmpty ? [TextSpan(text: text, style: style)] : spans,
      ),
    );
  }
}
