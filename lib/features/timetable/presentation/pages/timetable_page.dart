import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../../shared/widgets/shimmer_widgets.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/services/gtfs_service.dart';
import '../../domain/entities/route_with_next_arrival.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  bool _isLoading = true;
  String _searchQuery = '';

  final GtfsService _gtfsService = GtfsService();
  List<RouteWithNextArrival> _routes = [];
  List<RouteWithNextArrival> _filteredRoutes = [];

  @override
  void initState() {
    super.initState();
    _loadTimetableData();
  }

  Future<void> _loadTimetableData() async {
    try {
      // GTFS adatok betöltése
      final routes = await _gtfsService.getRoutesWithNextArrivals();
      if (mounted) {
        setState(() {
          _routes = routes;
          _filteredRoutes = routes;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Hiba a menetrend betöltésekor: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterRoutes() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredRoutes = _routes;
      } else {
        _filteredRoutes =
            _routes.where((route) {
              return route.routeShortName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  route.routeLongName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
            }).toList();
      }
    });
  }

  Color _getRouteColor(RouteWithNextArrival route, int index) {
    // Színpaletta - 20 különböző szín
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.deepOrange,
      Colors.lime,
      Colors.brown,
      Colors.blueGrey,
      Colors.lightBlue,
      Colors.deepPurple,
      Colors.yellow.shade800,
      Colors.lightGreen,
      Colors.redAccent,
      Colors.purpleAccent,
    ];

    // Útvonal típus alapján módosítjuk a színt
    final baseColor = colors[index % colors.length];

    if (route.routeType == 0) {
      // Villamos - kék árnyalatúbb változatok
      return Color.lerp(baseColor, Colors.blue, 0.3) ?? baseColor;
    } else {
      // Busz - eredeti színek
      return baseColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Menetrend',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.getCardColor(context),
          ),
        ),
        backgroundColor: AppColors.getPrimaryColor(context),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.getBackgroundGradient(context),
        ),
        child: _isLoading ? _buildLoadingState() : _buildTimetableContent(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.getBackgroundGradient(context),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Symbols.schedule,
                    color: AppColors.getCardColor(context),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menetrend betöltése...',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getCardColor(context),
                          ),
                        ),
                        Text(
                          'Kérlek várj egy pillanatot',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.getCardColor(
                              context,
                            ).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: const Duration(milliseconds: 600)),
        const SizedBox(height: 16),
        ...List.generate(
          8,
          (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ShimmerWidgets.timetableShimmer(),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 200 + (index * 100)))
              .slideX(
                begin: 0.3,
                delay: Duration(milliseconds: 200 + (index * 100)),
              ),
        ),
      ],
    );
  }

  Widget _buildTimetableContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header Container
          Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.getCardShadow(context),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.getPrimaryColor(
                              context,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Symbols.schedule,
                            color: AppColors.getPrimaryColor(context),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Menetrend',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.getPrimaryColor(context),
                                ),
                              ),
                              Text(
                                'Járatok és érkezési idők',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.getTextSecondaryColor(
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.getPrimaryColor(
                          context,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Symbols.directions_bus,
                            color: AppColors.getPrimaryColor(context),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_filteredRoutes.length} járat elérhető',
                            style: TextStyle(
                              color: AppColors.getTextSecondaryColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: const Duration(milliseconds: 600))
              .slideY(begin: -0.3, duration: const Duration(milliseconds: 600)),

          const SizedBox(height: 16),

          // KERESŐŐŐŐŐŐ mező
          Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.getCardShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.search,
                          color: AppColors.getPrimaryColor(context),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Kereső',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.getPrimaryColor(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _filterRoutes();
                      },
                      decoration: InputDecoration(
                        hintText: 'Keresés járat száma vagy neve alapján...',
                        prefixIcon: const Icon(
                          Symbols.directions_bus,
                          color: Colors.grey,
                        ),
                        suffixIcon:
                            _searchQuery.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Symbols.clear),
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                    _filterRoutes();
                                  },
                                )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: AppColors.getTextSecondaryColor(
                              context,
                            ).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: AppColors.getPrimaryColor(context),
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: AppColors.getTextSecondaryColor(
                              context,
                            ).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        fillColor: AppColors.getTextSecondaryColor(
                          context,
                        ).withOpacity(0.05),
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_searchQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          '${_filteredRoutes.length} találat',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getTextSecondaryColor(context),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 800))
              .slideY(begin: -0.2, delay: const Duration(milliseconds: 800)),

          // Járat lista - GTFS adatokból
          ..._filteredRoutes.asMap().entries.map((entry) {
            final index = entry.key;
            final route = entry.value;
            final color = _getRouteColor(route, index);

            return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 8,
                    shadowColor: color.withOpacity(0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            AppColors.getCardColor(context),
                            color.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [color, color.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              route.routeShortName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          route.routeLongName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(
                                route.routeType == 0
                                    ? Symbols.tram
                                    : Symbols.directions_bus,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${route.routeTypeText} • Következő: ${route.nextArrivalText}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            route.nextArrivalText,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        onTap: () {
                          // Járat részletek megnyitása
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${route.routeShortName} - ${route.routeLongName}',
                              ),
                              backgroundColor: color,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  duration: const Duration(milliseconds: 500),
                )
                .slideX(
                  begin: 0.3,
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  duration: const Duration(milliseconds: 500),
                )
                .scale(
                  begin: const Offset(0.8, 0.8),
                  delay: Duration(milliseconds: 100 + (index * 50)),
                  duration: const Duration(milliseconds: 500),
                );
          }).toList(),

          // Spacer a lista végén
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
