import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/animations/app_animations.dart';
import '../../../../core/services/mvk_api_service.dart';
import '../../../../core/services/favorites_service.dart';
import '../../../stops/presentation/pages/map_page.dart';

class StopSearchPage extends StatefulWidget {
  final String? initialStopCode;

  const StopSearchPage({super.key, this.initialStopCode});

  @override
  State<StopSearchPage> createState() => _StopSearchPageState();
}

class _StopSearchPageState extends State<StopSearchPage>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pageController;
  late AnimationController _searchController;
  late AnimationController _resultController;
  late AnimationController _pulseController;

  // Search state
  final TextEditingController _stopCodeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;
  bool _hasResults = false;
  String? _errorMessage;
  bool _showSearchView =
      true; // Controls whether to show search or results view

  // API service
  final MVKApiService _apiService = MVKApiService();
  final FavoritesService _favoritesService = FavoritesService();

  // Results
  StopInfoResponse? _stopInfo;
  bool _isFavorite = false; // Add favorite state

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInitialAnimations();
    _initializeFavorites();

    // Ha van kezdő stopCode, töltsük be automatikusan
    if (widget.initialStopCode != null) {
      _stopCodeController.text = widget.initialStopCode!;
      Future.delayed(const Duration(milliseconds: 1000), () {
        _searchStop();
      });
    }
  }

  void _initializeFavorites() async {
    await _favoritesService.initialize();
  }

  void _initializeAnimations() {
    _pageController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _searchController = AnimationController(
      duration: AppAnimations.normal,
      vsync: this,
    );

    _resultController = AnimationController(
      duration: AppAnimations.slow,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
  }

  void _startInitialAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _pageController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    _searchController.forward();

    // Indítjuk a pulsing animációt
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    _resultController.dispose();
    _pulseController.dispose();
    _stopCodeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchStop() async {
    final stopCode = _stopCodeController.text.trim();

    if (stopCode.isEmpty) {
      _showError('Kérjük, adjon meg egy megálló kódot!');
      return;
    }

    if (stopCode.length < 2) {
      _showError('A megálló kód legalább 2 karakter hosszú legyen!');
      return;
    }

    setState(() {
      _isSearching = true;
      _hasResults = false;
      _errorMessage = null;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      final stopInfo = await _apiService.getStopInfo(stopCode);

      if (stopInfo.departures.isEmpty) {
        _showError(
          'Nem találhatók adatok a(z) $stopCode megálló kódhoz.\nKérjük, ellenőrizze a kódot.',
        );
      } else {
        setState(() {
          _stopInfo = stopInfo;
          _hasResults = true;
          _isSearching = false;
          _showSearchView = false; // Switch to results view
          _isFavorite = _favoritesService.isFavorite(stopCode);
        });

        // Success feedback
        HapticFeedback.mediumImpact();
        _resultController.forward();
      }
    } catch (e) {
      _showError('Hiba történt a lekérdezés során:\n${e.toString()}');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _isSearching = false;
      _hasResults = false;
      _showSearchView = true; // Always show search view when there's an error
    });

    // Error feedback
    HapticFeedback.heavyImpact();
  }

  void _clearSearch() {
    setState(() {
      _stopCodeController.clear();
      _hasResults = false;
      _errorMessage = null;
      _showSearchView = true; // Switch back to search view
    });
    _resultController.reset();
    _focusNode.requestFocus();
  }

  // Érkezési idő formázása percekkel és másodpercekkel
  String _formatArrivalTime(int minutes, int seconds) {
    if (minutes <= 0 && seconds <= 0) return 'Most érkezik';
    if (minutes == 0) return '${seconds}s';
    if (seconds == 0) return '${minutes}p';
    return '${minutes}p ${seconds}s';
  }

  // Részletes információ buborék megjelenítése
  void _showDepartureDetails(DepartureInfo departure, Color color) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.6,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder:
                (context, scrollController) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(context),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    boxShadow: AppColors.getCardShadow(context),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.getTextSecondaryColor(
                                context,
                              ).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Fejléc
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [color, color.withOpacity(0.8)],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  departure.routeDisplayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Járat információk',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.getTextPrimaryColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    departure.destinationDisplayName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: AppColors.getTextSecondaryColor(
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _trackVehicleOnMap(departure),
                              icon: Icon(Symbols.map, color: color),
                              style: IconButton.styleFrom(
                                backgroundColor: color.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Részletes információk
                        _buildDetailSection('Érkezési információ', [
                          _buildDetailItem(
                            'Pontos érkezés',
                            departure.arrivalTime ?? 'Ismeretlen',
                          ),
                          _buildDetailItem(
                            'Hátralévő idő',
                            _formatArrivalTime(
                              departure.arrivalMinutes,
                              departure.arrivalSeconds,
                            ),
                          ),
                          _buildDetailItem(
                            'Státusz',
                            departure.isAtStop
                                ? 'Megállóban várakozik'
                                : 'Úton van',
                          ),
                        ]),

                        const SizedBox(height: 24),

                        _buildDetailSection('Jármű adatok', [
                          _buildDetailItem('Típus', departure.vehicleTypeText),
                          _buildDetailItem(
                            'Akadálymentesség',
                            departure.isLowFloor
                                ? 'Akadálymentes jármű'
                                : 'Akadálymentesség ismeretlen',
                          ),
                          _buildDetailItem('Jármű ID', '#${departure.tripId}'),
                        ]),

                        const SizedBox(height: 24),

                        _buildDetailSection('Útvonal információ', [
                          _buildDetailItem(
                            'Célállomás',
                            departure.destinationDisplayName,
                          ),
                          _buildDetailItem(
                            'Útvonal ID',
                            '#${departure.routeId}',
                          ),
                          _buildDetailItem(
                            'Megálló ID',
                            '#${departure.stopId}',
                          ),
                        ]),

                        const SizedBox(height: 32),

                        // Akciók
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _trackVehicleOnMap(departure),
                                icon: Icon(Symbols.map),
                                label: Text('Térkép'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: color,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: Icon(Symbols.close),
                                label: Text('Bezárás'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.getTextSecondaryColor(
                                        context,
                                      ).withOpacity(0.1),
                                  foregroundColor:
                                      AppColors.getTextPrimaryColor(context),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildDetailSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.getTextPrimaryColor(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getBackgroundColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.getTextSecondaryColor(context).withOpacity(0.2),
            ),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.getTextSecondaryColor(context),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.getTextPrimaryColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackgroundColor(context),
      appBar: _buildModernAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildModernAppBar() {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      systemOverlayStyle:
          Theme.of(context).brightness == Brightness.dark
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.getCardColor(context).withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.getCardShadow(context),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).pop(),
            child: Icon(
              Symbols.arrow_back,
              color: AppColors.getPrimaryColor(context),
            ),
          ),
        ),
      ),
      title: Text(
        _showSearchView ? 'Megálló keresés' : 'Menetrend információk',
        style: TextStyle(
          color: AppColors.getPrimaryColor(context),
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions:
          _showSearchView
              ? null
              : [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(context).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.getCardShadow(context),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _clearSearch,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          Symbols.search,
                          color: AppColors.getPrimaryColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _pageController.value)),
          child: Opacity(
            opacity: _pageController.value,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (_showSearchView) ...[
                    _buildSearchSection(),
                    const SizedBox(height: 30),
                    if (_isSearching) _buildLoadingSection(),
                    if (_errorMessage != null) _buildErrorSection(),
                  ] else if (_hasResults) ...[
                    _buildResultsSection(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchSection() {
    return AnimatedBuilder(
      animation: _searchController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _searchController.value),
          child: Opacity(
            opacity: _searchController.value,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.getCardColor(context),
                    AppColors.getBackgroundColor(context),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: AppColors.getCardShadow(context),
              ),
              child: Column(
                children: [
                  // Icon with pulsing animation
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + (0.1 * _pulseController.value),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.getPrimaryColor(context),
                                AppColors.secondaryGreen,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.getPrimaryColor(
                                  context,
                                ).withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Symbols.search,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Megálló kód keresése',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.getPrimaryColor(context),
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Adja meg a keresett megálló számát a valós idejű információkért',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.getTextSecondaryColor(context),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Modern input field
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.getCardShadow(context),
                    ),
                    child: TextField(
                      controller: _stopCodeController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        color: AppColors.getTextPrimaryColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'pl. 84',
                        hintStyle: TextStyle(
                          color: AppColors.getTextSecondaryColor(
                            context,
                          ).withOpacity(0.6),
                          fontSize: 24,
                          fontWeight: FontWeight.w400,
                        ),
                        filled: true,
                        fillColor: AppColors.getCardColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: AppColors.getTextSecondaryColor(
                              context,
                            ).withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: AppColors.getPrimaryColor(context),
                            width: 3,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        suffixIcon:
                            _stopCodeController.text.isNotEmpty
                                ? IconButton(
                                  onPressed: _clearSearch,
                                  icon: Icon(
                                    Symbols.clear,
                                    color: AppColors.getTextSecondaryColor(
                                      context,
                                    ),
                                  ),
                                )
                                : null,
                      ),
                      onSubmitted: (_) => _searchStop(),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Search button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isSearching ? null : _searchStop,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.getPrimaryColor(context),
                        foregroundColor: AppColors.getCardColor(context),
                        elevation: 8,
                        shadowColor: AppColors.getPrimaryColor(
                          context,
                        ).withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        disabledBackgroundColor:
                            AppColors.getTextSecondaryColor(
                              context,
                            ).withOpacity(0.3),
                      ),
                      child:
                          _isSearching
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Symbols.search, size: 24),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Keresés indítása',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
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

  Widget _buildLoadingSection() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.getCardColor(context),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.getCardShadow(context),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppColors.getPrimaryColor(context),
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Adatok betöltése...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.getPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Valós idejű információk lekérése',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.getTextSecondaryColor(context),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildResultsSection() {
    if (_stopInfo == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _resultController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _resultController.value)),
          child: Opacity(
            opacity: _resultController.value,
            child: Column(
              children: [
                // Modern stop info header
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.getCardColor(context),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.getCardShadow(context),
                  ),
                  child: Column(
                    children: [
                      // Stop name with favorite button
                      Row(
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
                              Symbols.location_on,
                              color: AppColors.getPrimaryColor(context),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _stopInfo!.stopName ??
                                      '${_stopCodeController.text}. számú megálló',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.getTextPrimaryColor(
                                      context,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_stopInfo!.departures.length} aktív járat',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.getTextSecondaryColor(
                                      context,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: _toggleFavorite,
                            icon: Icon(
                              _isFavorite
                                  ? Symbols.favorite
                                  : Symbols.favorite_border,
                              color:
                                  _isFavorite
                                      ? AppColors.cancelledRed
                                      : AppColors.getTextSecondaryColor(
                                        context,
                                      ),
                              size: 28,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Quick stats row
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickStat(
                              icon: Symbols.accessible,
                              label: 'Akadálymentes',
                              value:
                                  '${_stopInfo!.departures.where((d) => d.isLowFloor).length}/${_stopInfo!.departures.length}',
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickStat(
                              icon: Symbols.schedule,
                              label: 'Legközelebbi',
                              value:
                                  _stopInfo!.departures.isNotEmpty
                                      ? '${_stopInfo!.departures.first.arrivalMinutes} perc'
                                      : 'Nincs adat',
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Departures list
                ...List.generate(_stopInfo!.departures.length, (index) {
                  final departure = _stopInfo!.departures[index];
                  return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: _buildDepartureCard(departure, index),
                      )
                      .animate(delay: Duration(milliseconds: 100 * index))
                      .fadeIn()
                      .slideX(begin: 0.3);
                }),

                const SizedBox(height: 32),

                // Back to search button
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _clearSearch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.getCardColor(context),
                      foregroundColor: AppColors.getPrimaryColor(context),
                      elevation: 8,
                      shadowColor: AppColors.getPrimaryColor(
                        context,
                      ).withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: AppColors.getPrimaryColor(
                            context,
                          ).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    icon: Icon(Symbols.search, size: 24),
                    label: Text(
                      'Új keresés indítása',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDepartureCard(DepartureInfo departure, int index) {
    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.green,
      Colors.brown,
    ];

    final color = colors[index % colors.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showDepartureDetails(departure, color),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Route number badge - tappable
              GestureDetector(
                onTap: () => _showDepartureDetails(departure, color),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      departure.routeDisplayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Jármű információk és célállomás
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Célállomás
                    Text(
                      departure.destinationDisplayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.getTextPrimaryColor(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Jármű típus és akadálymentesség
                    Row(
                      children: [
                        // Akadálymentesség státusz
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                departure.isLowFloor
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            departure.isLowFloor
                                ? 'Akadálymentes'
                                : 'Akadálymentesség ismeretlen',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  departure.isLowFloor
                                      ? Colors.green
                                      : Colors.grey.shade600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Státusz indikátor
                        if (departure.isAtStop)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Symbols.location_on,
                                  size: 12,
                                  color: Colors.green.shade700,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  'Megállóban',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
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

              const SizedBox(width: 8),

              // Érkezési idő
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatArrivalTime(
                      departure.arrivalMinutes,
                      departure.arrivalSeconds,
                    ),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: color,
                    ),
                  ),

                  if (departure.arrivalTime != null)
                    Text(
                      departure.arrivalTime!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.getTextSecondaryColor(context),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.getTextSecondaryColor(context),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _toggleFavorite() async {
    if (_stopInfo == null) return;

    final stopCode = _stopCodeController.text.trim();
    final stopName = _stopInfo!.stopName ?? 'Ismeretlen megálló';

    try {
      if (_isFavorite) {
        // Eltávolítás a kedvencekből
        final success = await _favoritesService.removeFavorite(stopCode);
        if (success) {
          setState(() {
            _isFavorite = false;
          });
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$stopName eltávolítva a kedvencekből'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppColors.getTextSecondaryColor(context),
            ),
          );
        }
      } else {
        // Hozzáadás a kedvencekhez - kérjük meg a becenevet
        _showNicknameDialog(stopCode, stopName);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hiba történt: $e'),
          backgroundColor: AppColors.cancelledRed,
        ),
      );
    }
  }

  void _showNicknameDialog(String stopCode, String stopName) {
    final TextEditingController nicknameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.getCardColor(context),
            title: Text(
              'Kedvenc megálló hozzáadása',
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
                  'Megálló: $stopName ($stopCode)',
                  style: TextStyle(
                    color: AppColors.getTextSecondaryColor(context),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Becenév (opcionális)',
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
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _addToFavorites(
                    stopCode,
                    stopName,
                    nicknameController.text.trim().isEmpty
                        ? null
                        : nicknameController.text.trim(),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.getPrimaryColor(context),
                  foregroundColor: AppColors.getCardColor(context),
                ),
                child: const Text('Hozzáadás'),
              ),
            ],
          ),
    );
  }

  Future<void> _addToFavorites(
    String stopCode,
    String stopName,
    String? nickname,
  ) async {
    try {
      final success = await _favoritesService.addFavorite(
        stopCode: stopCode,
        stopName: stopName,
        nickname: nickname,
      );

      if (success) {
        setState(() {
          _isFavorite = true;
        });
        HapticFeedback.lightImpact();

        final displayName = nickname?.isNotEmpty == true ? nickname! : stopName;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName hozzáadva a kedvencekhez'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('A megálló már a kedvencek között van'),
            backgroundColor: AppColors.getTextSecondaryColor(context),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hiba történt: $e'),
          backgroundColor: AppColors.cancelledRed,
        ),
      );
    }
  }

  Future<void> _trackVehicleOnMap(DepartureInfo departure) async {
    // Navigate directly to map page with vehicle tracking
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => MapPage(
              routeNumber: departure.routeDisplayName,
              routeDirection: 'O', // Default direction, could be made dynamic
              routeName: departure.destinationDisplayName,
            ),
      ),
    );
  }

  Widget _buildErrorSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cancelledRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cancelledRed.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Icon(Symbols.error, color: AppColors.cancelledRed, size: 48),
          const SizedBox(height: 16),
          Text(
            'Hiba történt',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.cancelledRed,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.cancelledRed,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _errorMessage = null;
              });
              _focusNode.requestFocus();
            },
            icon: const Icon(Symbols.refresh),
            label: const Text('Próbálja újra'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cancelledRed,
              foregroundColor: AppColors.getCardColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().shake();
  }
}
