import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/mvk_api_service.dart';
import '../../../timetable/data/services/gtfs_service.dart';
import '../../../timetable/domain/entities/gtfs_stop.dart';

class MapStyleData {
  final String url;
  final String name;
  final IconData icon;
  final String description;
  final List<String>? subdomains;

  const MapStyleData({
    required this.url,
    required this.name,
    required this.icon,
    required this.description,
    this.subdomains,
  });
}

class MapPage extends StatefulWidget {
  final VoidCallback? onNavigateToHome;
  final String? routeNumber;
  final String? routeDirection;
  final String? routeName;

  const MapPage({
    super.key,
    this.onNavigateToHome,
    this.routeNumber,
    this.routeDirection,
    this.routeName,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _mapController;
  late MapController _flutterMapController;
  bool _showStyleSelector = false;

  // Térkép beállítások
  String _selectedMapStyle = 'OpenStreetMap';
  double _currentZoom = 13.0;
  final LatLng _miskolcCenter = LatLng(48.1034, 20.7784); // Miskolc koordinátái

  // GPS helymeghatározás
  LatLng? _currentLocation;
  bool _isLocationLoading = false;

  // GTFS megállók
  final GtfsService _gtfsService = GtfsService();
  final MVKApiService _mvkApiService = MVKApiService();
  List<GtfsStop> _stops = [];
  GtfsStop? _selectedStop;

  // Vehicle tracking
  List<BusInfo> _vehicles = [];
  Timer? _vehicleUpdateTimer;
  bool _isTrackingVehicles = false;

  // Modernebb térkép stílusok
  final Map<String, MapStyleData> _mapStyles = {
    'OpenStreetMap': MapStyleData(
      url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      name: 'OpenStreetMap',
      icon: Symbols.map,
      description: 'Klasszikus térkép',
    ),
    'Domborzati': MapStyleData(
      url: 'https://tile.opentopomap.org/{z}/{x}/{y}.png',
      name: 'Domborzati',
      icon: Symbols.terrain,
      description: 'Domborzati viszonyok',
    ),
    'Műholdas': MapStyleData(
      url:
          'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
      name: 'Műholdas',
      icon: Symbols.satellite_alt,
      description: 'Műholdas felvételek',
    ),
    'Sötét': MapStyleData(
      url:
          'https://cartodb-basemaps-{s}.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png',
      name: 'Sötét',
      icon: Symbols.dark_mode,
      description: 'Sötét téma',
      subdomains: ['a', 'b', 'c'],
    ),
    'Akvarell': MapStyleData(
      url:
          'https://stamen-tiles-{s}.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg',
      name: 'Akvarell',
      icon: Symbols.brush,
      description: 'Művészi stílus',
      subdomains: ['a', 'b', 'c'],
    ),
  };

  @override
  void initState() {
    super.initState();
    _mapController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _flutterMapController = MapController();
    _loadMapData();

    // Start vehicle tracking if route information is provided
    if (widget.routeNumber != null && widget.routeDirection != null) {
      _startVehicleTracking();
    }
  }

  Future<void> _loadMapData() async {
    // Betöltjük a GTFS megállókat
    try {
      _stops = await _gtfsService.getStops();
      print('Betöltve ${_stops.length} megálló');
    } catch (e) {
      print('Hiba a megállók betöltésekor: $e');
    }

    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _mapController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading ? _buildLoadingState() : _buildMapContent(),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.getBackgroundGradient(context),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.getPrimaryColor(context),
        ),
      ),
    );
  }

  Widget _buildMapContent() {
    return Stack(
      children: [
        // Teljes képernyős térkép
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _mapController,
            builder: (context, child) {
              return Transform.scale(
                scale: _mapController.value,
                child: FlutterMap(
                  mapController: _flutterMapController,
                  options: MapOptions(
                    initialCenter: _miskolcCenter,
                    initialZoom: _currentZoom,
                    minZoom: 8.0,
                    maxZoom: 18.0,
                    onTap: (tapPosition, point) {
                      // Térkép koppintáskor eltűnteti a stíluskiválasztót
                      setState(() {
                        _showStyleSelector = false;
                      });
                    },
                  ),
                  children: [
                    // Térkép réteg
                    TileLayer(
                      urlTemplate: _mapStyles[_selectedMapStyle]!.url,
                      userAgentPackageName: 'com.mvk.miskolc.app',
                      maxZoom: 18,
                      subdomains:
                          _mapStyles[_selectedMapStyle]!.subdomains ??
                          ['a', 'b', 'c'],
                    ),
                    // Jelenlegi helyzet jelölő
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentLocation!,
                            width: 40,
                            height: 40,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.getPrimaryColor(context),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.getPrimaryColor(
                                      context,
                                    ).withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Symbols.person_pin_circle,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    // Megállók jelölő réteg
                    MarkerLayer(
                      markers:
                          _stops.map((stop) => _buildStopMarker(stop)).toList(),
                    ),
                    // Vehicle markers layer
                    if (_vehicles.isNotEmpty)
                      MarkerLayer(
                        markers:
                            _vehicles
                                .map((vehicle) => _buildVehicleMarker(vehicle))
                                .toList(),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // Vissza gomb
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          child: _buildBackButton(),
        ),

        // Zoom vezérlők
        Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          right: 16,
          child: _buildZoomControls(),
        ),

        // Stíluskiválasztó gomb
        Positioned(bottom: 100, right: 16, child: _buildStyleButton()),

        // Modern stíluskiválasztó panel
        if (_showStyleSelector) _buildModernStyleSelector(),
      ],
    );
  }

  Widget _buildBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // Vissza a főoldalra
            if (widget.onNavigateToHome != null) {
              widget.onNavigateToHome!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Ha nincs callback és nincs előző oldal, akkor a home route-ra megyünk
              Navigator.of(context).pushReplacementNamed('/home');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Icon(
              Symbols.arrow_back,
              size: 24,
              color: AppColors.getPrimaryColor(context),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 400),
    );
  }

  Widget _buildZoomControls() {
    return Column(
      children: [
        _buildZoomButton(icon: Symbols.add, onTap: _zoomIn),
        const SizedBox(height: 8),
        _buildZoomButton(icon: Symbols.remove, onTap: _zoomOut),
        const SizedBox(height: 16),
        _buildZoomButton(
          icon:
              _isLocationLoading
                  ? Symbols.hourglass_empty
                  : Symbols.my_location,
          onTap: _getCurrentLocation,
        ),
        const SizedBox(height: 8),
        _buildZoomButton(icon: Symbols.location_city, onTap: _centerToMiskolc),
      ],
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 600),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.getPrimaryColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.getPrimaryColor(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.getPrimaryColor(context).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              _showStyleSelector = !_showStyleSelector;
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _mapStyles[_selectedMapStyle]!.icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Stílus',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 600),
      delay: const Duration(milliseconds: 800),
    );
  }

  Widget _buildModernStyleSelector() {
    return Positioned(
      bottom: 180,
      right: 16,
      left: 16,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Fejléc
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.getPrimaryColor(context),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Symbols.layers, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Térkép stílusok',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showStyleSelector = false;
                      });
                    },
                    icon: const Icon(
                      Symbols.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            // Stílus lista
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8),
                itemCount: _mapStyles.length,
                itemBuilder: (context, index) {
                  final entry = _mapStyles.entries.elementAt(index);
                  final key = entry.key;
                  final style = entry.value;
                  final isSelected = _selectedMapStyle == key;

                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.getPrimaryColor(context)
                                : Colors.grey.withOpacity(0.2),
                        width: 2,
                      ),
                      color:
                          isSelected
                              ? AppColors.getPrimaryColor(
                                context,
                              ).withOpacity(0.1)
                              : Colors.transparent,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          setState(() {
                            _selectedMapStyle = key;
                            _showStyleSelector = false;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? AppColors.getPrimaryColor(context)
                                          : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  style.icon,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      style.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            isSelected
                                                ? AppColors.getPrimaryColor(
                                                  context,
                                                )
                                                : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      style.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Symbols.check_circle,
                                  color: AppColors.getPrimaryColor(context),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ).animate().slideY(
        begin: 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutBack,
      ),
    );
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(8.0, 18.0);
    });
    _flutterMapController.move(
      _flutterMapController.camera.center,
      _currentZoom,
    );
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(8.0, 18.0);
    });
    _flutterMapController.move(
      _flutterMapController.camera.center,
      _currentZoom,
    );
  }

  void _centerToMiskolc() {
    _flutterMapController.move(_miskolcCenter, 13.0);
    setState(() {
      _currentZoom = 13.0;
    });
  }

  // GPS helymeghatározás funkciók
  Future<void> _getCurrentLocation() async {
    if (_isLocationLoading) return;

    setState(() {
      _isLocationLoading = true;
    });

    try {
      // Ellenőrizzük a szolgáltatás állapotát
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError(
          'A helymeghatározási szolgáltatás nincs engedélyezve',
        );
        return;
      }

      // Ellenőrizzük az engedélyeket
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('A helymeghatározási engedély megtagadva');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError(
          'A helymeghatározási engedély véglegesen megtagadva. Engedélyezze a beállításokban.',
        );
        return;
      }

      // Helyzet lekérése
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _currentZoom = 16.0;
      });

      // Térkép mozgatása a jelenlegi helyzetre
      _flutterMapController.move(_currentLocation!, _currentZoom);

      // Sikeres helymeghatározás visszajelzés
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Symbols.location_on, color: Colors.white),
                SizedBox(width: 8),
                Text('Jelenlegi helyzet megtalálva'),
              ],
            ),
            backgroundColor: AppColors.getPrimaryColor(context),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      _showLocationError('Hiba a helymeghatározás során: ${e.toString()}');
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  void _showLocationError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Symbols.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          action: SnackBarAction(
            label: 'Beállítások',
            textColor: Colors.white,
            onPressed: () async {
              await Geolocator.openAppSettings();
            },
          ),
        ),
      );
    }
  }

  // Modern megálló jelölő készítése
  Marker _buildStopMarker(GtfsStop stop) {
    final isSelected = _selectedStop?.stopId == stop.stopId;

    return Marker(
      point: LatLng(stop.stopLat, stop.stopLon),
      width: isSelected ? 100 : 80,
      height: isSelected ? 60 : 50,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedStop = _selectedStop?.stopId == stop.stopId ? null : stop;
          });

          // Zoom a megállóra
          if (_selectedStop != null) {
            _flutterMapController.move(
              LatLng(stop.stopLat, stop.stopLon),
              16.0,
            );
          }
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern buborék
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 12 : 8,
                vertical: isSelected ? 8 : 6,
              ),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? AppColors.getPrimaryColor(context)
                        : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.getPrimaryColor(context),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.getPrimaryColor(context).withOpacity(0.3),
                    blurRadius: isSelected ? 12 : 8,
                    offset: const Offset(0, 4),
                    spreadRadius: isSelected ? 3 : 1,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Symbols.directions_bus,
                    color:
                        isSelected
                            ? Colors.white
                            : AppColors.getPrimaryColor(context),
                    size: isSelected ? 18 : 16,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        stop.stopName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Nyíl mutató
            Container(
              width: 0,
              height: 0,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.transparent, width: 6),
                  right: BorderSide(color: Colors.transparent, width: 6),
                  top: BorderSide(
                    color:
                        isSelected
                            ? AppColors.getPrimaryColor(context)
                            : Colors.white,
                    width: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vehicle tracking methods
  void _startVehicleTracking() {
    if (widget.routeNumber == null || widget.routeDirection == null) return;

    setState(() {
      _isTrackingVehicles = true;
    });

    // Initial fetch
    _updateVehiclePositions();

    // Set up timer to update every 3 seconds
    _vehicleUpdateTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _updateVehiclePositions();
    });
  }

  void _stopVehicleTracking() {
    _vehicleUpdateTimer?.cancel();
    _vehicleUpdateTimer = null;
    setState(() {
      _isTrackingVehicles = false;
      _vehicles.clear();
    });
  }

  Future<void> _updateVehiclePositions() async {
    if (!_isTrackingVehicles ||
        widget.routeNumber == null ||
        widget.routeDirection == null) {
      return;
    }

    try {
      final routeInfo = await _mvkApiService.trackRoute(
        widget.routeNumber!,
        widget.routeDirection!,
      );

      if (mounted) {
        setState(() {
          _vehicles = routeInfo.buses;
        });

        // Center map on first vehicle if available
        if (_vehicles.isNotEmpty &&
            _vehicles.first.latitude != 0 &&
            _vehicles.first.longitude != 0) {
          _flutterMapController.move(
            LatLng(_vehicles.first.latitude, _vehicles.first.longitude),
            15.0,
          );
        }
      }
    } catch (e) {
      print('Error updating vehicle positions: $e');
    }
  }

  Marker _buildVehicleMarker(BusInfo vehicle) {
    return Marker(
      point: LatLng(vehicle.latitude, vehicle.longitude),
      width: 60,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color:
              vehicle.isAtStop
                  ? Colors.green
                  : AppColors.getPrimaryColor(context),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: (vehicle.isAtStop
                      ? Colors.green
                      : AppColors.getPrimaryColor(context))
                  .withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Symbols.directions_bus, color: Colors.white, size: 20),
            if (widget.routeNumber != null)
              Text(
                widget.routeNumber!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopVehicleTracking();
    _mapController.dispose();
    _flutterMapController.dispose();
    super.dispose();
  }
}
