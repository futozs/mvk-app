import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../shared/widgets/shimmer_widgets.dart';
import '../../../../core/constants/app_colors.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isLoading = true;
  List<FavoriteItem> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _favorites = _getMockFavorites();
      });
    }
  }

  List<FavoriteItem> _getMockFavorites() {
    return [
      FavoriteItem(
        type: FavoriteType.route,
        title: '12-es autóbusz',
        subtitle: 'Széchenyi tér → Egyetemváros',
        icon: Symbols.directions_bus,
        color: AppColors.primaryGreen,
      ),
      FavoriteItem(
        type: FavoriteType.stop,
        title: 'Széchenyi tér',
        subtitle: '4 járat érinti',
        icon: Symbols.location_on,
        color: AppColors.routePlanningBlue,
      ),
      FavoriteItem(
        type: FavoriteType.route,
        title: '1-es villamos',
        subtitle: 'Diósgyőr → Selyemrét',
        icon: Symbols.tram,
        color: AppColors.routePlanningBlue,
      ),
      FavoriteItem(
        type: FavoriteType.stop,
        title: 'Városház tér',
        subtitle: '8 járat érinti',
        icon: Symbols.location_on,
        color: AppColors.primaryGreen,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      body: _isLoading ? _buildLoadingState() : _buildFavoritesContent(),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ShimmerWidgets.listItemShimmer(),
          ShimmerWidgets.listItemShimmer(),
          ShimmerWidgets.listItemShimmer(),
          ShimmerWidgets.listItemShimmer(),
        ],
      ),
    );
  }

  Widget _buildFavoritesContent() {
    if (_favorites.isEmpty) {
      return _buildEmptyState();
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(child: _buildHeader()),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final favorite = _favorites[index];
              return _buildFavoriteCard(favorite, index)
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn(duration: const Duration(milliseconds: 600))
                  .slideX(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 600),
                  );
            }, childCount: _favorites.length),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.favorite,
              color: AppColors.getPrimaryColor(context),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kedvenc útvonalak és megállók',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${_favorites.length} elem mentve',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildFilterChip('Összes', true),
            const SizedBox(width: 8),
            _buildFilterChip('Útvonalak', false),
            const SizedBox(width: 8),
            _buildFilterChip('Megállók', false),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color:
            isSelected
                ? AppColors.getPrimaryColor(context)
                : AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isSelected
                  ? AppColors.getPrimaryColor(context)
                  : AppColors.getTextSecondaryColor(context).withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color:
              isSelected
                  ? AppColors.getCardColor(context)
                  : AppColors.getTextSecondaryColor(context),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteItem favorite, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: favorite.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(favorite.icon, color: favorite.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  favorite.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  favorite.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  // Gyors útvonaltervezés
                },
                icon: Icon(
                  Symbols.navigation,
                  color: AppColors.getPrimaryColor(context),
                ),
              ),
              IconButton(
                onPressed: () {
                  _removeFavorite(index);
                },
                icon: Icon(
                  Symbols.delete,
                  color: AppColors.getTextSecondaryColor(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.favorite_border,
              size: 64,
              color: AppColors.getPrimaryColor(context),
            ),
            const SizedBox(height: 24),
            const Text(
              'Még nincsenek kedvencek',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Add hozzá a gyakran használt útvonalakat és megállókat a kedvenceidhez.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.getTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Navigálás menetrend oldalra
              },
              icon: const Icon(Symbols.search),
              label: const Text('Útvonalak böngészése'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.getPrimaryColor(context),
                foregroundColor: AppColors.getCardColor(context),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: const Duration(milliseconds: 800));
  }

  void _removeFavorite(int index) {
    setState(() {
      _favorites.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Kedvenc eltávolítva'),
        action: SnackBarAction(
          label: 'Visszavonás',
          onPressed: () {
            // Visszavonás logika
          },
        ),
      ),
    );
  }
}

class FavoriteItem {
  final FavoriteType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  FavoriteItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

enum FavoriteType { route, stop }
