import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../shared/widgets/shimmer_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../stop_search/presentation/pages/stop_search_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with WidgetsBindingObserver {
  bool _isLoading = true;
  List<FavoriteStop> _favorites = [];
  final FavoritesService _favoritesService = FavoritesService();
  String _selectedFilter = 'Összes';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    WidgetsBinding.instance.addObserver(this);
    // Hallgatjuk a favorites service változásait
    _favoritesService.addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _favoritesService.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (mounted) {
      setState(() {
        _favorites = _favoritesService.favoritesSortedByDate;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Frissítjük a kedvenceket, amikor az alkalmazás visszatér az előtérbe
      _refreshFavorites();
    }
  }

  Future<void> _refreshFavorites() async {
    if (mounted) {
      setState(() {
        _favorites = _favoritesService.favoritesSortedByDate;
      });
    }
  }

  Future<void> _loadFavorites() async {
    await _favoritesService.initialize();

    if (mounted) {
      setState(() {
        _isLoading = false;
        _favorites = _favoritesService.favoritesSortedByDate;
      });
    }
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
            _buildFilterChip('Összes', _selectedFilter == 'Összes'),
            const SizedBox(width: 8),
            _buildFilterChip('Megállók', _selectedFilter == 'Megállók'),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
      child: Container(
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
      ),
    );
  }

  Widget _buildFavoriteCard(FavoriteStop favorite, int index) {
    return GestureDetector(
      onTap: () => _openStopSearch(favorite.stopCode),
      child: Container(
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
                color: AppColors.routePlanningBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Symbols.location_on,
                color: AppColors.routePlanningBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    favorite.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${favorite.stopName} (${favorite.stopCode})',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                  ),
                  if (favorite.nickname != null &&
                      favorite.nickname!.isNotEmpty)
                    Text(
                      'Becenév: ${favorite.nickname}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.getPrimaryColor(context),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _editNickname(favorite),
                  icon: Icon(
                    Symbols.edit,
                    color: AppColors.getPrimaryColor(context),
                  ),
                  tooltip: 'Becenév szerkesztése',
                ),
                IconButton(
                  onPressed: () => _removeFavorite(favorite, index),
                  icon: Icon(
                    Symbols.delete,
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                  tooltip: 'Eltávolítás',
                ),
              ],
            ),
          ],
        ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StopSearchPage(),
                  ),
                );
              },
              icon: const Icon(Symbols.search),
              label: const Text('Megállók keresése'),
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

  void _removeFavorite(FavoriteStop favorite, int index) async {
    final success = await _favoritesService.removeFavorite(favorite.stopCode);

    if (success) {
      setState(() {
        _favorites.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${favorite.displayName} eltávolítva'),
          action: SnackBarAction(
            label: 'Visszavonás',
            onPressed: () async {
              // Visszaadás a kedvencekhez
              await _favoritesService.addFavorite(
                stopCode: favorite.stopCode,
                stopName: favorite.stopName,
                nickname: favorite.nickname,
              );
              await _loadFavorites();
            },
          ),
        ),
      );
    }
  }

  void _openStopSearch(String stopCode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StopSearchPage(initialStopCode: stopCode),
      ),
    );
  }

  void _editNickname(FavoriteStop favorite) {
    final TextEditingController nicknameController = TextEditingController();
    nicknameController.text = favorite.nickname ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.getCardColor(context),
            title: Text(
              'Becenév szerkesztése',
              style: TextStyle(
                color: AppColors.getTextPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Megálló: ${favorite.stopName} (${favorite.stopCode})',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Becenév',
                    hintText: 'pl. Otthon, Munka, Iskola...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getPrimaryColor(context),
                        width: 2,
                      ),
                    ),
                  ),
                  maxLength: 50,
                  autofocus: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Mégse',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(context),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  final newNickname = nicknameController.text.trim();
                  final success = await _favoritesService.updateNickname(
                    favorite.stopCode,
                    newNickname.isEmpty ? null : newNickname,
                  );

                  if (success) {
                    await _loadFavorites();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Becenév frissítve'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                  }
                },
                child: Text(
                  'Mentés',
                  style: TextStyle(
                    color: AppColors.getPrimaryColor(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
