import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'navigation_widgets.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/timetable/presentation/pages/timetable_page.dart';
import '../../features/stops/presentation/pages/map_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/app_state_manager.dart';
import '../../services/auth_service.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  // Oldalak cache-elése - egyszer létrehozzuk és újrahasználjuk
  late final List<Widget> _cachedPages;

  @override
  void initState() {
    super.initState();
    // Oldalak előre betöltése és cache-elése
    _cachedPages = [
      const HomePage(),
      const TimetablePage(),
      MapPage(onNavigateToHome: _navigateToHome),
      const FavoritesPage(),
      const MorePage(),
    ];
  }

  void _navigateToHome() {
    setState(() {
      _currentIndex = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 200), // Gyors animáció
      curve: Curves.easeOut,
    );
  }

  List<Widget> get _pages => _cachedPages;

  void _onTabTapped(int index) {
    if (_currentIndex == index)
      return; // Ha ugyanaz a tab, ne csináljunk semmit

    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 200), // Gyors és smooth animáció
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Ne lépjen ki automatikusan
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Vissza gomb kezelése az AppStateManager-rel
          final appStateManager = context.read<AppStateManager>();
          final shouldPop = await appStateManager.handleBackButton(context);

          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // reMOBILON Header csík
            _buildReMobilonHeader(context),
            // Fő tartalom - Optimalizált PageView a swipe funkcionalitással
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                // Performance optimalizációk
                physics: const ClampingScrollPhysics(), // Smooth scrolling
                children:
                    _pages
                        .map((page) => _KeepAliveWrapper(child: page))
                        .toList(),
              ),
            ),
          ],
        ),
        bottomNavigationBar: MainNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
        ),
        floatingActionButton:
            _currentIndex ==
                    2 // Térkép oldal
                ? AnimatedFloatingActionButton(
                  onPressed: () {
                    // Közeli megállók keresése
                    _showNearbyStopsBottomSheet();
                  },
                  icon: Symbols.my_location,
                  tooltip: 'Saját helyzet',
                )
                : null,
      ),
    );
  }

  void _showNearbyStopsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Közeli megállók',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Symbols.directions_bus),
                            title: Text('Megálló ${index + 1}'),
                            subtitle: Text('${(index + 1) * 100}m távolságra'),
                            trailing: Text('${index + 3} perc'),
                            onTap: () {
                              Navigator.pop(context);
                              // Navigálás a megálló részleteihez
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildReMobilonHeader(BuildContext context) {
    return Container(
      color: AppColors.getBackgroundColor(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showMVKWebsiteDialog(context),
                child: Container(
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
              ),
              const SizedBox(width: 14),
              Text(
                'reMOBILON',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.getPrimaryColor(context),
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Symbols.notifications,
                  color: AppColors.getPrimaryColor(context),
                ),
                onPressed: () {
                  // Értesítések megnyitása
                },
              ),
              Consumer<AuthService>(
                builder: (context, authService, child) {
                  return IconButton(
                    icon:
                        authService.isLoggedIn &&
                                authService.userPhotoURL != null
                            ? CircleAvatar(
                              radius: 12,
                              backgroundImage: NetworkImage(
                                authService.userPhotoURL!,
                              ),
                            )
                            : Icon(
                              Symbols.person,
                              color: AppColors.getPrimaryColor(context),
                            ),
                    onPressed: () {
                      if (authService.isLoggedIn) {
                        // Profil oldal megnyitása
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ProfilePage(),
                          ),
                        );
                      } else {
                        // Bejelentkezés
                        _showLoginDialog(context, authService);
                      }
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLoginDialog(BuildContext context, AuthService authService) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation1,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                width: 340,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: AppColors.getPrimaryColor(
                        context,
                      ).withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 0),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header - profil ikon és cím
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.getPrimaryColor(context),
                                      AppColors.getPrimaryColor(
                                        context,
                                      ).withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.getPrimaryColor(
                                        context,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Symbols.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Bejelentkezés',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : const Color(0xFF1A202C),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (isDark
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade100),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Google fiók',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Cloud sync ikon középen
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.getPrimaryColor(
                                context,
                              ).withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.getPrimaryColor(
                                  context,
                                ).withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Symbols.cloud_sync,
                              size: 36,
                              color: AppColors.getPrimaryColor(context),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Leírás szöveg
                          Text(
                            'Jelentkezz be a Google fiókoddal,\nhogy szinkronizálhasd a kedvenceidet\nés a beállításaidat.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark
                                      ? Colors.grey.shade300
                                      : const Color(0xFF4A5568),
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Előnyök lista
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  isDark
                                      ? Colors.grey.shade900.withOpacity(0.5)
                                      : AppColors.getPrimaryColor(
                                        context,
                                      ).withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    isDark
                                        ? Colors.grey.shade800
                                        : AppColors.getPrimaryColor(
                                          context,
                                        ).withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildFeatureItem(
                                  icon: Symbols.favorite,
                                  text: 'A kedvencek szinkronizálása',
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 8),
                                _buildFeatureItem(
                                  icon: Symbols.settings,
                                  text: 'A beállítások mentése',
                                  isDark: isDark,
                                ),
                                const SizedBox(height: 8),
                                _buildFeatureItem(
                                  icon: Symbols.devices,
                                  text: 'Több eszköz támogatása',
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Gombok
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isDark
                                              ? Colors.grey.shade700
                                              : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Mégse',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.getPrimaryColor(context),
                                        AppColors.getPrimaryColor(
                                          context,
                                        ).withOpacity(0.85),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.getPrimaryColor(
                                          context,
                                        ).withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        authService.isLoading
                                            ? null
                                            : () async {
                                              final success =
                                                  await authService
                                                      .signInWithGoogle();
                                              if (context.mounted) {
                                                Navigator.of(context).pop();
                                                if (success) {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                        'Sikeres bejelentkezés!',
                                                      ),
                                                      backgroundColor:
                                                          Colors.green,
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                        'Bejelentkezés sikertelen!',
                                                      ),
                                                      backgroundColor:
                                                          Colors.red,
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon:
                                        authService.isLoading
                                            ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                            : const Icon(
                                              Symbols.login,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                    label: Text(
                                      authService.isLoading
                                          ? 'Folyamatban...'
                                          : 'Bejelentkezés',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.getPrimaryColor(context)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey.shade400 : const Color(0xFF4A5568),
            ),
          ),
        ),
      ],
    );
  }

  void _showMVKWebsiteDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation1, animation2) {
        return Container();
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(parent: animation1, curve: Curves.easeOutBack),
          ),
          child: FadeTransition(
            opacity: animation1,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                width: 320,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: AppColors.getPrimaryColor(
                        context,
                      ).withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 0),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header kompakt verzió
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.getPrimaryColor(context),
                                      AppColors.getPrimaryColor(
                                        context,
                                      ).withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.getPrimaryColor(
                                        context,
                                      ).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/mlogobig.png',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'MVK Weboldal',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            isDark
                                                ? Colors.white
                                                : const Color(0xFF1A202C),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            (isDark
                                                ? Colors.grey.shade800
                                                : Colors.grey.shade100),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'mvkzrt.hu',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              isDark
                                                  ? Colors.grey.shade400
                                                  : Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text(
                            'Megnyitod a hivatalos MVK weboldalt?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark
                                      ? Colors.grey.shade300
                                      : const Color(0xFF4A5568),
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Kompakt gombok
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        isDark
                                            ? Colors.grey.shade800
                                            : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          isDark
                                              ? Colors.grey.shade700
                                              : Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  child: TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Mégse',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isDark
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.getPrimaryColor(context),
                                        AppColors.getPrimaryColor(
                                          context,
                                        ).withOpacity(0.85),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.getPrimaryColor(
                                          context,
                                        ).withOpacity(0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await _launchMVKWebsite();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Symbols.open_in_new,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      'Megnyitás',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchMVKWebsite() async {
    final Uri url = Uri.parse('https://mvkzrt.hu/');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Ha nem sikerül megnyitni, mutassunk hibaüzenetet
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nem sikerült megnyitni a weboldalt!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Hibakezelés
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hiba történt a weboldal megnyitása során!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Wrapper widget az oldalak állapotának megőrzéséhez
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;

  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // Fontos az AutomaticKeepAliveClientMixin miatt
    return widget.child;
  }
}
