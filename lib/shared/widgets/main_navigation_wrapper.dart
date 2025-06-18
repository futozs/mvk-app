import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'navigation_widgets.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/timetable/presentation/pages/timetable_page.dart';
import '../../features/stops/presentation/pages/map_page.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../core/constants/app_colors.dart';

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
    return Scaffold(
      body: Column(
        children: [
          // MVK Header csík
          _buildMVKHeader(context),
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
                  _pages.map((page) => _KeepAliveWrapper(child: page)).toList(),
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

  Widget _buildMVKHeader(BuildContext context) {
    return Container(
      color: AppColors.getBackgroundColor(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              IconButton(
                icon: Icon(
                  Symbols.person,
                  color: AppColors.getPrimaryColor(context),
                ),
                onPressed: () {
                  // Profil megnyitása
                },
              ),
            ],
          ),
        ),
      ),
    );
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
