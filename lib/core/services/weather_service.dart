import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum WeatherCondition {
  sunny,
  partlyCloudy,
  cloudy,
  rainy,
  thunderstorm,
  snowy,
  foggy,
  windy,
}

class WeatherData {
  final double temperature;
  final WeatherCondition condition;
  final String description;
  final int humidity;
  final double windSpeed;
  final String cityName;
  final DateTime timestamp;

  WeatherData({
    required this.temperature,
    required this.condition,
    required this.description,
    required this.humidity,
    required this.windSpeed,
    required this.cityName,
    required this.timestamp,
  });

  String get weatherIcon {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 20;

    switch (condition) {
      case WeatherCondition.sunny:
        return isNight ? '🌙' : '☀️';
      case WeatherCondition.partlyCloudy:
        return isNight ? '☁️' : '⛅';
      case WeatherCondition.cloudy:
        return '☁️';
      case WeatherCondition.rainy:
        return '🌧️';
      case WeatherCondition.thunderstorm:
        return '⛈️';
      case WeatherCondition.snowy:
        return '❄️';
      case WeatherCondition.foggy:
        return '🌫️';
      case WeatherCondition.windy:
        return '💨';
    }
  }

  String get animatedWeatherIcon {
    final hour = DateTime.now().hour;
    final isNight = hour < 6 || hour > 20;

    switch (condition) {
      case WeatherCondition.sunny:
        return isNight ? '🌜' : '☀️';
      case WeatherCondition.partlyCloudy:
        return isNight ? '☁️' : '⛅';
      case WeatherCondition.cloudy:
        return '☁️💭';
      case WeatherCondition.rainy:
        return '🌧️💧';
      case WeatherCondition.thunderstorm:
        return '⛈️⚡';
      case WeatherCondition.snowy:
        return '❄️❄️';
      case WeatherCondition.foggy:
        return '🌫️👻';
      case WeatherCondition.windy:
        return '💨🍃';
    }
  }

  List<String> get weatherParticles {
    switch (condition) {
      case WeatherCondition.rainy:
        return ['💧', '🌧️'];
      case WeatherCondition.snowy:
        return ['❄️', '🌨️'];
      case WeatherCondition.thunderstorm:
        return [ '💧', '🌩️'];
      case WeatherCondition.sunny:
        return ['☀️', '✨'];
      case WeatherCondition.windy:
        return ['💨', '🌪️'];
      default:
        return ['☁️', '💭'];
    }
  }
}

class WeatherService {
  static String get _apiKey => 
      dotenv.env['WEATHER_API_KEY'] ?? 'your_api_key_here';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // Miskolc koordinátái
  static const double _miskolcLat = 48.1034;
  static const double _miskolcLon = 20.7784;

  // Cache az API hívások csökkentésére
  WeatherData? _cachedWeather;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5); // 5 perc cache

  // Singleton pattern a service-hez
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

  Future<WeatherData> getCurrentWeather({bool forceRefresh = false}) async {
    // Cache ellenőrzés - csak akkor frissítünk ha szükséges
    if (!forceRefresh &&
        _cachedWeather != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      print(
        '📱 Cache-elt időjárási adat használata (${DateTime.now().difference(_lastFetchTime!).inMinutes} perc régi)',
      );
      return _cachedWeather!;
    }

    try {
      print('🌤️ Időjárási adatok lekérése Miskolc számára...');

      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/weather?lat=$_miskolcLat&lon=$_miskolcLon&appid=$_apiKey&units=metric&lang=hu',
            ),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('✅ Sikeres API válasz: ${response.statusCode}');
        final data = json.decode(response.body);
        final weather = _parseWeatherData(data);

        _cachedWeather = weather;
        _lastFetchTime = DateTime.now();

        print('🌡️ Aktuális hőmérséklet: ${weather.temperature.round()}°C');
        print('🌦️ Időjárás: ${weather.description}');
        print(
          '⏰ Cache frissítve, következő frissítés: ${DateTime.now().add(_cacheDuration).toString().substring(11, 16)}',
        );

        return weather;
      } else {
        print('⚠️ API hiba: ${response.statusCode}');
        throw Exception('Weather API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Időjárási adatok lekérése sikertelen: $e');

      // Ha van cache-elt adat, azt adjuk vissza hiba esetén is
      if (_cachedWeather != null) {
        print('🔄 Régi cache-elt adat használata hiba esetén...');
        return _cachedWeather!;
      }

      // Ha nincs cache és az API nem elérhető, dobunk egy hibát
      throw Exception('Időjárási adatok nem elérhetők és nincs cache-elt adat');
    }
  }

  // Új metódus: frissítés ellenőrzése háttérben
  bool get needsRefresh {
    if (_cachedWeather == null || _lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) >= _cacheDuration;
  }

  // Új metódus: cache státusz lekérdezése
  String get cacheStatus {
    if (_cachedWeather == null || _lastFetchTime == null) {
      return 'Nincs cache-elt adat';
    }

    final age = DateTime.now().difference(_lastFetchTime!);
    final remaining = _cacheDuration - age;

    if (remaining.isNegative) {
      return 'Cache lejárt ${(-remaining.inMinutes)} perce';
    }

    return 'Cache érvényes még ${remaining.inMinutes} percig';
  }

  // Új metódus: háttérben történő frissítés
  Future<void> refreshInBackground() async {
    if (needsRefresh) {
      try {
        await getCurrentWeather(forceRefresh: true);
      } catch (e) {
        print('🔄 Háttér frissítés sikertelen: $e');
      }
    }
  }

  WeatherData _parseWeatherData(Map<String, dynamic> data) {
    final main = data['main'];
    final weather = data['weather'][0];
    final wind = data['wind'] ?? {};

    final temperature = (main['temp'] as num).toDouble();
    final condition = _mapWeatherCondition(weather['id'] as int);
    final description = weather['description'] as String;
    final humidity = main['humidity'] as int;
    final windSpeed = (wind['speed'] as num?)?.toDouble() ?? 0.0;

    return WeatherData(
      temperature: temperature,
      condition: condition,
      description: description,
      humidity: humidity,
      windSpeed: windSpeed,
      cityName: 'Miskolc',
      timestamp: DateTime.now(),
    );
  }

  WeatherCondition _mapWeatherCondition(int weatherId) {
    if (weatherId >= 200 && weatherId < 300) {
      return WeatherCondition.thunderstorm;
    } else if (weatherId >= 300 && weatherId < 600) {
      return WeatherCondition.rainy;
    } else if (weatherId >= 600 && weatherId < 700) {
      return WeatherCondition.snowy;
    } else if (weatherId >= 700 && weatherId < 800) {
      return WeatherCondition.foggy;
    } else if (weatherId == 800) {
      return WeatherCondition.sunny;
    } else if (weatherId > 800) {
      return WeatherCondition.partlyCloudy;
    }
    return WeatherCondition.cloudy;
  }

  // Óránkénti előrejelzés cache-eléssel
  List<WeatherData>? _cachedHourlyForecast;
  DateTime? _lastHourlyFetchTime;
  static const Duration _hourlyForecastCacheDuration = Duration(
    minutes: 30,
  ); // 30 perces cache az óránkénti előrejelzéshez

  Future<List<WeatherData>> getHourlyForecast({
    bool forceRefresh = false,
  }) async {
    // Cache ellenőrzés az óránkénti előrejelzéshez
    if (!forceRefresh &&
        _cachedHourlyForecast != null &&
        _lastHourlyFetchTime != null &&
        DateTime.now().difference(_lastHourlyFetchTime!) <
            _hourlyForecastCacheDuration) {
      print('📊 Cache-elt óránkénti előrejelzés használata');
      return _cachedHourlyForecast!;
    }

    print('🔮 Óránkénti előrejelzés generálása...');

    final List<WeatherData> forecast = [];
    final now = DateTime.now();

    for (int i = 1; i <= 24; i++) {
      final futureTime = now.add(Duration(hours: i));
      final random = Random(futureTime.millisecondsSinceEpoch);

      final conditions = [
        WeatherCondition.sunny,
        WeatherCondition.partlyCloudy,
        WeatherCondition.cloudy,
        WeatherCondition.rainy,
      ];

      final condition = conditions[random.nextInt(conditions.length)];
      final baseTemp = 15 + random.nextDouble() * 15;

      forecast.add(
        WeatherData(
          temperature: baseTemp,
          condition: condition,
          description: _getDescriptionForCondition(condition),
          humidity: 40 + random.nextInt(40),
          windSpeed: random.nextDouble() * 20,
          cityName: 'Miskolc',
          timestamp: futureTime,
        ),
      );
    }

    // Cache-eljük az előrejelzést
    _cachedHourlyForecast = forecast;
    _lastHourlyFetchTime = DateTime.now();
    print('📊 Óránkénti előrejelzés cache-elve 2 órára');

    return forecast;
  }

  String _getDescriptionForCondition(WeatherCondition condition) {
    switch (condition) {
      case WeatherCondition.sunny:
        return 'Napos';
      case WeatherCondition.partlyCloudy:
        return 'Részben felhős';
      case WeatherCondition.cloudy:
        return 'Felhős';
      case WeatherCondition.rainy:
        return 'Esős';
      case WeatherCondition.thunderstorm:
        return 'Viharos';
      case WeatherCondition.snowy:
        return 'Havas';
      case WeatherCondition.foggy:
        return 'Ködös';
      case WeatherCondition.windy:
        return 'Szeles';
    }
  }

  // Cache törlése (debugging vagy frissítési célokra)
  void clearCache() {
    _cachedWeather = null;
    _lastFetchTime = null;
    _cachedHourlyForecast = null;
    _lastHourlyFetchTime = null;
    print('🗑️ Weather cache törölve');
  }

  // Debug információk
  Map<String, dynamic> get cacheInfo {
    return {
      'currentWeather': {
        'cached': _cachedWeather != null,
        'lastFetch': _lastFetchTime?.toString(),
        'age':
            _lastFetchTime != null
                ? DateTime.now().difference(_lastFetchTime!).inMinutes
                : null,
        'needsRefresh': needsRefresh,
      },
      'hourlyForecast': {
        'cached': _cachedHourlyForecast != null,
        'lastFetch': _lastHourlyFetchTime?.toString(),
        'age':
            _lastHourlyFetchTime != null
                ? DateTime.now().difference(_lastHourlyFetchTime!).inMinutes
                : null,
      },
    };
  }
}
