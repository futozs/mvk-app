import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../shared/widgets/animated_cards.dart';
import '../../../../shared/widgets/shimmer_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/services/weather_service.dart';
import '../../../stop_search/presentation/pages/stop_search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _greetingController;
  late AnimationController _weatherController;
  late AnimationController _quickAccessController;
  late AnimationController _servicesController;
  late AnimationController _masterController;
  late AnimationController _weatherParticleController;

  bool _isLoading = true;
  WeatherData? _currentWeather;
  final WeatherService _weatherService = WeatherService();

  // Mock adatok
  final List<String> _newsItems = [
    '🚍 Új elektromos buszok érkeztek a 12-es járatra',
    '⚠️ A Kálvária tér felújítása miatt módosított útvonal',
    '🎉 Új mobilapp funkciók: valós idejű járatkövetés',
    '📱 Töltsd le az új MVK alkalmazást még ma!',
  ];

  @override
  void initState() {
    super.initState();

    // Ultra smooth animáció kontrollerek
    _masterController = AnimationController(
      duration: AppAnimations.cinematic,
      vsync: this,
    );

    _greetingController = AnimationController(
      duration: AppAnimations.extraSlow,
      vsync: this,
    );

    _weatherController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _weatherParticleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _quickAccessController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _servicesController = AnimationController(
      duration: AppAnimations.extraSlow,
      vsync: this,
    );

    _initializeData();
  }

  Future<void> _initializeData() async {
    // Időjárás betöltése
    try {
      _currentWeather = await _weatherService.getCurrentWeather();
    } catch (e) {
      // Alapértelmezett időjárás hiba esetén
      _currentWeather = null;
    }

    // Ultra smooth betöltés szekvencia
    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Mesterkélt animáció orchestration
      _masterController.forward();

      await Future.delayed(const Duration(milliseconds: 200));
      _greetingController.forward();

      await Future.delayed(const Duration(milliseconds: 300));
      _weatherController.forward();

      // Időjárás-függő részecske animáció indítása
      if (_currentWeather?.condition == WeatherCondition.rainy ||
          _currentWeather?.condition == WeatherCondition.snowy) {
        _weatherParticleController.repeat();
      } else {
        _weatherParticleController.forward();
      }

      await Future.delayed(const Duration(milliseconds: 200));
      _quickAccessController.forward();

      await Future.delayed(const Duration(milliseconds: 400));
      _servicesController.forward();
    }
  }

  @override
  void dispose() {
    _masterController.dispose();
    _greetingController.dispose();
    _weatherController.dispose();
    _weatherParticleController.dispose();
    _quickAccessController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  String get _getGreeting {
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;

    // Nagyon részletes napszak-alapú köszöntések
    if (hour >= 5 && hour < 9) {
      if (hour < 6) return 'Korán kelő! 🌅';
      if (hour < 7) return 'Szuper reggelt! ☀️';
      if (hour < 8) return 'Jó reggelt! 🌞';
      return 'Kellemes reggelt! ☕';
    } else if (hour >= 9 && hour < 12) {
      if (hour < 10) return 'Jó délelőttöt! 🌤️';
      if (hour < 11) return 'Szép délelőttöt! ☀️';
      return 'Kellemes délelőttöt! 🌻';
    } else if (hour >= 12 && hour < 14) {
      if (minute < 30) return 'Jó napot! 🌞';
      return 'Kellemes délutánt! 🌤️';
    } else if (hour >= 14 && hour < 17) {
      return 'Szép délutánt! ☀️';
    } else if (hour >= 17 && hour < 19) {
      if (hour < 18) return 'Jó délutánt! 🌅';
      return 'Kellemes estét! 🌇';
    } else if (hour >= 19 && hour < 22) {
      if (hour < 21) return 'Jó estét! 🌆';
      return 'Kellemes estét! 🌙';
    } else if (hour >= 22 || hour < 5) {
      if (hour >= 23 || hour < 1) return 'Jó éjszakát! 🌙';
      if (hour < 3) return 'Késő éjjel? 🌜';
      return 'Korán kelsz? 🌌';
    }
    return 'Szép napot! 🌈';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getBackgroundGradient(context),
        ),
        child: SafeArea(
          child: _isLoading ? _buildLoadingState() : _buildMainContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 80),
          // Greeting shimmer
          Container(
            margin: const EdgeInsets.all(16),
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
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingSection(),
                const SizedBox(height: 20),
                _buildQuickAccessSection(),
                const SizedBox(height: 20),
                NewsTickerWidget(newsItems: _newsItems),
                const SizedBox(height: 20),
                _buildFeaturesSection(),
                const SizedBox(height: 100), // Bottom navigation padding
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Időjárás frissítése
    try {
      _currentWeather = await _weatherService.getCurrentWeather();
    } catch (e) {
      // Alapértelmezett időjárás hiba esetén
      _currentWeather = null;
    }

    // Smooth refresh animáció
    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() {});

      // Újra indítjuk az animációkat
      _greetingController.reset();
      _weatherController.reset();
      _weatherParticleController.reset();

      await Future.delayed(const Duration(milliseconds: 200));
      _greetingController.forward();
      await Future.delayed(const Duration(milliseconds: 300));
      _weatherController.forward();

      // Időjárás-függő részecske animáció
      if (_currentWeather?.condition == WeatherCondition.rainy ||
          _currentWeather?.condition == WeatherCondition.snowy) {
        _weatherParticleController.repeat();
      } else {
        _weatherParticleController.forward();
      }
    }
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getBackgroundGradient(context),
        ),
      ),
      title: AnimatedBuilder(
        animation: _masterController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _masterController,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.5),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: _masterController,
                  curve: AppAnimations.springCurve,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.getPrimaryColor(context).withOpacity(0.15),
                          AppColors.getPrimaryColor(context).withOpacity(0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.getPrimaryColor(
                            context,
                          ).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/mlogobig.png',
                        width: 26,
                        height: 26,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'MVK Miskolc',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getPrimaryColor(context),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(
            Symbols.notifications,
            color: AppColors.getPrimaryColor(context),
          ),
          onPressed: () {
            // Értesítések megnyitása
          },
        ),
        IconButton(
          icon: Icon(Symbols.person, color: AppColors.getPrimaryColor(context)),
          onPressed: () {
            // Profil megnyitása
          },
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
                            animation: _greetingController,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _greetingController,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(-0.8, 0),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: _greetingController,
                                      curve: AppAnimations.ultraSmoothCurve,
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
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _currentWeather?.condition ==
                                      WeatherCondition.rainy
                                  ? 'Vigyázz, esik! Vegyél esernyőt! ☔'
                                  : _currentWeather?.condition ==
                                      WeatherCondition.snowy
                                  ? 'Hó esik! Öltözz fel melegen! ❄️'
                                  : _currentWeather?.condition ==
                                      WeatherCondition.sunny
                                  ? 'Szuper időjárás! Élvezd a napot! ☀️'
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
      animation: _weatherController,
      builder: (context, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(_weatherController.value),
          child: Transform.rotate(
            angle: (1 - _weatherController.value) * 0.5,
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
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
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
          animation: _weatherParticleController,
          builder: (context, child) {
            return Stack(
              children: List.generate(
                isRaining || isSnowing ? 12 : 6, // Több részecske esőnél/hónál
                (index) {
                  final delay = index * (isRaining ? 0.1 : 0.2);
                  final animationValue = (_weatherParticleController.value -
                          delay)
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
      animation: _quickAccessController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _quickAccessController,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: _quickAccessController,
                curve: AppAnimations.springCurve,
              ),
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

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.getPrimaryColor(context),
                      AppColors.secondaryGreen,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Szolgáltatások',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.getPrimaryColor(context),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnimatedFeatureCard(
              title: 'Menetrend',
              subtitle: 'Járatok és érkezési idők',
              icon: Symbols.schedule,
              onTap: () {
                // Menetrend megnyitása
              },
              animationDelay: 100,
            )
            .animate()
            .slideX(
              begin: -1.2,
              delay: const Duration(milliseconds: 150),
              duration: AppAnimations.slow,
              curve: AppAnimations.ultraSmoothCurve,
            )
            .then()
            .shimmer(
              duration: const Duration(milliseconds: 1800),
              delay: const Duration(milliseconds: 100),
            ),
        AnimatedFeatureCard(
              title: 'Térkép',
              subtitle: 'Járatok valós idejű követése',
              icon: Symbols.map,
              onTap: () {
                // Térkép megnyitása
              },
              animationDelay: 200,
              backgroundColor: const Color.fromARGB(255, 56, 67, 189),
              iconColor: const Color.fromARGB(255, 56, 67, 189),
            )
            .animate()
            .slideX(
              begin: 1.2,
              delay: const Duration(milliseconds: 250),
              duration: AppAnimations.slow,
              curve: AppAnimations.ultraSmoothCurve,
            )
            .then()
            .shimmer(
              duration: const Duration(milliseconds: 1800),
              delay: const Duration(milliseconds: 200),
            ),
        AnimatedFeatureCard(
              title: 'Kedvencek',
              subtitle: 'Mentett megállók és útvonalak',
              icon: Symbols.favorite,
              onTap: () {
                // Kedvencek megnyitása
              },
              animationDelay: 300,
              backgroundColor: const Color(0xFFE91E63),
              iconColor: const Color(0xFFE91E63),
            )
            .animate()
            .slideX(
              begin: -1.2,
              delay: const Duration(milliseconds: 350),
              duration: AppAnimations.slow,
              curve: AppAnimations.ultraSmoothCurve,
            )
            .then()
            .shimmer(
              duration: const Duration(milliseconds: 1800),
              delay: const Duration(milliseconds: 300),
            ),
        AnimatedFeatureCard(
              title: 'Forgalmi hírek',
              subtitle: 'Aktuális közlekedési információk',
              icon: Symbols.campaign,
              onTap: () {
                // Hírek megnyitása
              },
              animationDelay: 400,
              backgroundColor: const Color(0xFFFF9800),
              iconColor: const Color(0xFFFF9800),
            )
            .animate()
            .slideX(
              begin: 1.2,
              delay: const Duration(milliseconds: 450),
              duration: AppAnimations.slow,
              curve: AppAnimations.ultraSmoothCurve,
            )
            .then()
            .shimmer(
              duration: const Duration(milliseconds: 1800),
              delay: const Duration(milliseconds: 400),
            ),
        AnimatedFeatureCard(
              title: 'Busz galéria',
              subtitle: 'Járművek képei és információi',
              icon: Symbols.photo_library,
              onTap: () {
                // Galéria megnyitása
              },
              animationDelay: 500,
              backgroundColor: const Color(0xFF9C27B0),
              iconColor: const Color(0xFF9C27B0),
            )
            .animate()
            .slideX(
              begin: -1.2,
              delay: const Duration(milliseconds: 550),
              duration: AppAnimations.slow,
              curve: AppAnimations.ultraSmoothCurve,
            )
            .then()
            .shimmer(
              duration: const Duration(milliseconds: 1800),
              delay: const Duration(milliseconds: 500),
            ),
      ],
    );
  }
}
