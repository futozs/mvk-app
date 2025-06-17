import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// MVK API szolgáltatás a megálló lekérdezéshez és járat követéshez
class MVKApiService {
  static final MVKApiService _instance = MVKApiService._internal();
  factory MVKApiService() => _instance;
  MVKApiService._internal();

  // Proxy szerver URL (CORS megoldás)
  static const String _proxyBaseUrl = 'http://localhost:3002/api';

  // Közvetlen API URL mobilra (fallback)
  static const String _directUrl =
      'https://mobilalkalmazas.mvkzrt.hu:8443/analyzer.php';

  /// Megálló információk lekérése stopCode alapján
  Future<StopInfoResponse> getStopInfo(String stopCode) async {
    try {
      print('🚌 Megálló lekérdezése: $stopCode');

      // Először próbáljuk a proxy szervert (CORS megoldás)
      if (kIsWeb) {
        return await _getStopInfoViaProxy(stopCode);
      } else {
        // Mobil/desktop esetén próbáljuk a proxyt, ha nem megy akkor direktet
        try {
          return await _getStopInfoViaProxy(stopCode);
        } catch (proxyError) {
          print('⚠️ Proxy hiba, próbálom direktet: $proxyError');
          return await _getStopInfoDirect(stopCode);
        }
      }
    } catch (e) {
      print('❌ Megálló lekérdezési hiba: $e');
      throw MVKApiException(
        'Hiba történt a megálló adatainak lekérdezésekor: $e',
      );
    }
  }

  /// Proxy szerveren keresztüli megálló lekérdezés
  Future<StopInfoResponse> _getStopInfoViaProxy(String stopCode) async {
    final url = '$_proxyBaseUrl/stop/$stopCode';
    print('📞 Proxy URL: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        final Map<String, dynamic> data = responseData['data'];
        return StopInfoResponse.fromJson(data);
      } else {
        throw Exception('Proxy hiba: ${responseData['error']}');
      }
    } else {
      throw Exception('HTTP hiba: ${response.statusCode}');
    }
  }

  /// Közvetlen API hívás (mobil/desktop)
  Future<StopInfoResponse> _getStopInfoDirect(String stopCode) async {
    final postData = 'V=53&SWhRaK4rdu=$stopCode';
    print('📞 POST adat: $postData');
    print('📞 URL: $_directUrl');

    final response = await http.post(
      Uri.parse(_directUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent':
            'Dalvik/2.1.0 (Linux; U; Android 15; SM-A566B Build/AP3A.240905.015.A2)',
        'Host': 'mobilalkalmazas.mvkzrt.hu:8443',
        'Accept': '*/*',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
      },
      body: postData,
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      print(
        '📥 HTTP válasz: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...',
      );

      final String cleanResponse = _cleanJsonResponse(responseBody);
      print(
        '🧹 Tisztított válasz: ${cleanResponse.substring(0, cleanResponse.length > 200 ? 200 : cleanResponse.length)}...',
      );

      final Map<String, dynamic> data = json.decode(cleanResponse);
      return StopInfoResponse.fromJson(data);
    } else {
      print('❌ HTTP hiba: ${response.statusCode}');
      throw Exception(
        'HTTP hiba: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  /// Járat követés
  Future<RouteInfoResponse> trackRoute(
    String routeNumber,
    String direction,
  ) async {
    try {
      print('🚌 Járat követése: $routeNumber ($direction)');

      // Először próbáljuk a proxy szervert (CORS megoldás)
      if (kIsWeb) {
        return await _trackRouteViaProxy(routeNumber, direction);
      } else {
        // Mobil/desktop esetén próbáljuk a proxyt, ha nem megy akkor direktet
        try {
          return await _trackRouteViaProxy(routeNumber, direction);
        } catch (proxyError) {
          print('⚠️ Proxy hiba, próbálom direktet: $proxyError');
          return await _trackRouteDirect(routeNumber, direction);
        }
      }
    } catch (e) {
      print('❌ Járat követési hiba: $e');
      throw MVKApiException(
        'Hiba történt a járat adatainak lekérdezésekor: $e',
      );
    }
  }

  /// Proxy szerveren keresztüli járat követés
  Future<RouteInfoResponse> _trackRouteViaProxy(
    String routeNumber,
    String direction,
  ) async {
    final url = '$_proxyBaseUrl/route/$routeNumber/$direction';
    print('📞 Proxy URL: $url');

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        final Map<String, dynamic> data = responseData['data'];
        return RouteInfoResponse.fromJson(data);
      } else {
        throw Exception('Proxy hiba: ${responseData['error']}');
      }
    } else {
      throw Exception('HTTP hiba: ${response.statusCode}');
    }
  }

  /// Közvetlen járat követés API hívás (mobil/desktop fallback)
  Future<RouteInfoResponse> _trackRouteDirect(
    String routeNumber,
    String direction,
  ) async {
    // Pontosan ugyanaz az adat, mint a JavaScript curl parancsban
    final postData =
        'iv8S7HUu4E=$direction&kWCvM9rmn3=$routeNumber&V=53&bL8sv0jx=$routeNumber';

    print('📞 POST adat: $postData');

    // HTTP POST kérés ugyanazokkal a fejlécekkel, mint a JavaScript
    final response = await http.post(
      Uri.parse(_directUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent':
            'Dalvik/2.1.0 (Linux; U; Android 15; SM-A566B Build/AP3A.240905.015.A2)',
        'Host': 'mobilalkalmazas.mvkzrt.hu:8443',
      },
      body: postData,
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      print(
        '📥 HTTP válasz: ${responseBody.substring(0, responseBody.length > 200 ? 200 : responseBody.length)}...',
      );

      final String cleanResponse = _cleanJsonResponse(responseBody);
      print(
        '🧹 Tisztított válasz: ${cleanResponse.substring(0, cleanResponse.length > 200 ? 200 : cleanResponse.length)}...',
      );

      final Map<String, dynamic> data = json.decode(cleanResponse);
      return RouteInfoResponse.fromJson(data);
    } else {
      print('❌ HTTP hiba: ${response.statusCode}');
      throw Exception(
        'HTTP hiba: ${response.statusCode} - ${response.reasonPhrase}',
      );
    }
  }

  /// Hírek lekérdezése
  Future<NewsResponse> getNews() async {
    try {
      print('📰 Hírek lekérdezése');

      if (kIsWeb) {
        return await _getNewsViaProxy();
      } else {
        try {
          return await _getNewsViaProxy();
        } catch (proxyError) {
          print('⚠️ Proxy hiba, próbálom direktet: $proxyError');
          return await _getNewsDirect();
        }
      }
    } catch (e) {
      print('❌ Hírek lekérdezési hiba: $e');
      throw MVKApiException('Hiba történt a hírek lekérdezésekor: $e');
    }
  }

  /// Proxy szerveren keresztüli hírek lekérdezés
  Future<NewsResponse> _getNewsViaProxy() async {
    final url = '$_proxyBaseUrl/news';
    print('📞 Proxy URL: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        final Map<String, dynamic> data = responseData['data'];
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Proxy hiba: ${responseData['error']}');
      }
    } else {
      throw Exception('HTTP hiba: ${response.statusCode}');
    }
  }

  /// Közvetlen hírek lekérdezés
  Future<NewsResponse> _getNewsDirect() async {
    final postData = 'NI9rln8F=1&V=53&o5xfIG1p99=hu';

    final response = await http.post(
      Uri.parse(_directUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent':
            'Dalvik/2.1.0 (Linux; U; Android 15; SM-A566B Build/AP3A.240905.015.A2)',
        'Host': 'mobilalkalmazas.mvkzrt.hu:8443',
        'Accept-Encoding': 'gzip, deflate',
      },
      body: postData,
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      final String cleanResponse = _cleanJsonResponse(responseBody);
      final Map<String, dynamic> data = json.decode(cleanResponse);
      return NewsResponse.fromJson(data);
    } else {
      throw Exception('HTTP hiba: ${response.statusCode}');
    }
  }

  /// Hír részletek lekérdezése ID alapján
  Future<NewsDetailResponse> getNewsDetail(String newsId) async {
    try {
      print('📰 Hír részletek lekérdezése: $newsId');

      if (kIsWeb) {
        return await _getNewsDetailViaProxy(newsId);
      } else {
        try {
          return await _getNewsDetailViaProxy(newsId);
        } catch (proxyError) {
          print('⚠️ Proxy hiba, próbálom direktet: $proxyError');
          return await _getNewsDetailDirect(newsId);
        }
      }
    } catch (e) {
      print('❌ Hír részletek lekérdezési hiba: $e');
      throw MVKApiException(
        'Hiba történt a hír részleteinek lekérdezésekor: $e',
      );
    }
  }

  /// Proxy szerveren keresztüli hír részletek lekérdezés
  Future<NewsDetailResponse> _getNewsDetailViaProxy(String newsId) async {
    final url = '$_proxyBaseUrl/news/$newsId';
    print('📞 Proxy URL: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        final Map<String, dynamic> data = responseData['data'];
        return NewsDetailResponse.fromJson(data);
      } else {
        throw Exception('Proxy hiba: ${responseData['error']}');
      }
    } else {
      throw Exception('HTTP hiba: ${response.statusCode}');
    }
  }

  /// Közvetlen hír részletek lekérdezés
  Future<NewsDetailResponse> _getNewsDetailDirect(String newsId) async {
    final postData = 'K3WQtr=$newsId&NI9rln8F=1&V=53&o5xfIG1p99=hu';

    final response = await http.post(
      Uri.parse(_directUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent':
            'Dalvik/2.1.0 (Linux; U; Android 15; SM-A566B Build/AP3A.240905.015.A2)',
        'Host': 'mobilalkalmazas.mvkzrt.hu:8443',
        'Accept-Encoding': 'gzip, deflate',
      },
      body: postData,
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      final String cleanResponse = _cleanJsonResponse(responseBody);
      final Map<String, dynamic> data = json.decode(cleanResponse);
      return NewsDetailResponse.fromJson(data);
    } else {
      throw Exception('HTTP hiba: ${response.statusCode}');
    }
  }

  /// Törölt járatok lekérdezése
  Future<CancelledRoutesResponse> getCancelledRoutes() async {
    try {
      print('🚫 Törölt járatok lekérdezése');

      if (kIsWeb) {
        return await _getCancelledRoutesViaProxy();
      } else {
        try {
          return await _getCancelledRoutesViaProxy();
        } catch (proxyError) {
          print('⚠️ Proxy hiba, próbálom direktet: $proxyError');
          return await _getCancelledRoutesDirect();
        }
      }
    } catch (e) {
      print('❌ Törölt járatok lekérdezési hiba: $e');
      throw MVKApiException('Hiba történt a törölt járatok lekérdezésekor: $e');
    }
  }

  /// Proxy szerveren keresztüli törölt járatok lekérdezés
  Future<CancelledRoutesResponse> _getCancelledRoutesViaProxy() async {
    final url = '$_proxyBaseUrl/cancelled-routes';
    print('📞 Proxy URL: $url');

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData['success'] == true) {
        final Map<String, dynamic> data = responseData['data'];
        return CancelledRoutesResponse.fromJson(data);
      } else {
        throw Exception('Proxy hiba: ${responseData['error']}');
      }
    } else {
      throw Exception('HTTP hiba: ${response.statusCode}');
    }
  }

  /// Közvetlen törölt járatok lekérdezés
  Future<CancelledRoutesResponse> _getCancelledRoutesDirect() async {
    final postData = 'CU6hVQ6xqIV=1&V=53';

    final response = await http.post(
      Uri.parse(_directUrl),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'User-Agent':
            'Dalvik/2.1.0 (Linux; U; Android 15; SM-A566B Build/AP3A.240905.015.A2)',
        'Host': 'mobilalkalmazas.mvkzrt.hu:8443',
        'Accept-Encoding': 'gzip, deflate',
      },
      body: postData,
    );

    if (response.statusCode == 200) {
      final String responseBody = response.body;
      final String cleanResponse = _cleanJsonResponse(responseBody);
      final Map<String, dynamic> data = json.decode(cleanResponse);
      return CancelledRoutesResponse.fromJson(data);
    } else {
      throw Exception('HTTP hiba: ${response.statusCode}');
    }
  }

  /// JSON válasz tisztítása (eltávolítja a felesleges karaktereket)
  String _cleanJsonResponse(String response) {
    String cleanResponse = response.trim();

    // JSON kezdet és vég keresése
    final jsonStart = cleanResponse.indexOf('{');
    final jsonEnd = cleanResponse.lastIndexOf('}');

    if (jsonStart != -1 && jsonEnd != -1) {
      cleanResponse = cleanResponse.substring(jsonStart, jsonEnd + 1);
    }

    // % karakter és minden utána eltávolítása
    final percentIndex = cleanResponse.indexOf('%');
    if (percentIndex != -1) {
      cleanResponse = cleanResponse.substring(0, percentIndex);
    }

    return cleanResponse;
  }
}

/// Megálló információ válasz modell
class StopInfoResponse {
  final List<DepartureInfo> departures;

  StopInfoResponse({required this.departures});

  factory StopInfoResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? megalloList = json['megallo'];

    if (megalloList == null || megalloList.isEmpty) {
      return StopInfoResponse(departures: []);
    }

    final List<DepartureInfo> departures =
        megalloList.map((item) => DepartureInfo.fromJson(item)).toList();

    return StopInfoResponse(departures: departures);
  }

  String? get stopName {
    if (departures.isNotEmpty) {
      return departures.first.stopName;
    }
    return null;
  }
}

/// Indulás információ modell
class DepartureInfo {
  final String? stopName;
  final String? routeName;
  final String? routeDestination;
  final String? arrivalTime;
  final int arrivalMinutes;
  final int arrivalSeconds;
  final bool isLowFloor;
  final int vehicleTypeId;
  final int routeId;
  final int tripId;
  final bool isAtStop;
  final int stopId;

  DepartureInfo({
    this.stopName,
    this.routeName,
    this.routeDestination,
    this.arrivalTime,
    required this.arrivalMinutes,
    required this.arrivalSeconds,
    required this.isLowFloor,
    required this.vehicleTypeId,
    required this.routeId,
    required this.tripId,
    required this.isAtStop,
    required this.stopId,
  });

  factory DepartureInfo.fromJson(Map<String, dynamic> json) {
    return DepartureInfo(
      stopName: json['megallo_nev']?.toString(),
      routeName: json['vonal_nev']?.toString(),
      routeDestination: json['nyomvonal_nev']?.toString(),
      arrivalTime: json['erkezes']?.toString(),
      arrivalMinutes: (json['erk_minute'] as num?)?.toInt() ?? 0,
      arrivalSeconds: (json['erk_second'] as num?)?.toInt() ?? 0,
      isLowFloor: (json['alacsony_tipus'] as num?)?.toInt() == 1,
      vehicleTypeId: (json['jarmu_tipus_id'] as num?)?.toInt() ?? 1,
      routeId: (json['nyomvonal_id'] as num?)?.toInt() ?? 0,
      tripId: (json['jarat_id'] as num?)?.toInt() ?? 0,
      isAtStop: (json['megalloban'] as num?)?.toInt() == 1,
      stopId: (json['kocsiallas_id'] as num?)?.toInt() ?? 0,
    );
  }

  String get arrivalText {
    if (arrivalMinutes <= 0) return 'Most érkezik';
    if (arrivalMinutes == 1) return '1 perc múlva';
    return '$arrivalMinutes perc múlva';
  }

  String get detailedArrivalText {
    if (arrivalMinutes <= 0) return 'Most érkezik';
    if (arrivalMinutes == 1) return '1 perc múlva';
    if (arrivalMinutes < 60) return '$arrivalMinutes perc múlva';

    final hours = arrivalMinutes ~/ 60;
    final mins = arrivalMinutes % 60;
    return '${hours}h ${mins}p múlva';
  }

  String get vehicleTypeText {
    switch (vehicleTypeId) {
      case 1:
        return 'Autóbusz';
      case 2:
        return 'Trolibusz';
      case 3:
        return 'Villamos';
      default:
        return 'Jármű';
    }
  }

  String get statusText => isAtStop ? 'Megállóban' : 'Úton';
  String get routeDisplayName => routeName ?? 'Ismeretlen járat';
  String get destinationDisplayName => routeDestination ?? 'Ismeretlen útvonal';
}

/// Járat információ válasz modell
class RouteInfoResponse {
  final List<BusInfo> buses;

  RouteInfoResponse({required this.buses});

  factory RouteInfoResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? busInfoList = json['bus_info_on_vonal'];

    if (busInfoList == null || busInfoList.isEmpty) {
      return RouteInfoResponse(buses: []);
    }

    final List<BusInfo> buses =
        busInfoList.map((item) => BusInfo.fromJson(item)).toList();

    return RouteInfoResponse(buses: buses);
  }
}

/// Busz információ modell
class BusInfo {
  final String? vehicleId;
  final double latitude;
  final double longitude;
  final int direction;
  final bool isLowFloor;
  final bool isAtStop;

  BusInfo({
    this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.direction,
    required this.isLowFloor,
    required this.isAtStop,
  });

  factory BusInfo.fromJson(Map<String, dynamic> json) {
    return BusInfo(
      vehicleId: json['fszg_id']?.toString(),
      latitude: double.tryParse(json['szelesseg']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['hosszusag']?.toString() ?? '0') ?? 0.0,
      direction: (json['iranyszog'] as num?)?.toInt() ?? 0,
      isLowFloor: (json['alacsony_padlos'] as num?)?.toInt() == 1,
      isAtStop: (json['megalloban8_v_elhagyta0'] as num?)?.toInt() == 8,
    );
  }

  String get statusText => isAtStop ? 'Megállóban' : 'Úton';
  String get vehicleDisplayId => vehicleId ?? 'Ismeretlen';
  String get googleMapsUrl =>
      'https://www.google.com/maps?q=$latitude,$longitude';
}

/// API hiba exception
class MVKApiException implements Exception {
  final String message;
  MVKApiException(this.message);

  @override
  String toString() => 'MVKApiException: $message';
}

/// Hírek információ válasz modell
class NewsResponse {
  final List<NewsItem> news;

  NewsResponse({required this.news});

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? newsList = json['forgalmi_hirek'];

    if (newsList == null || newsList.isEmpty) {
      return NewsResponse(news: []);
    }

    final List<NewsItem> news =
        newsList.map((item) => NewsItem.fromJson(item)).toList();

    return NewsResponse(news: news);
  }
}

/// Hír elem modell
class NewsItem {
  final String id;
  final String title;
  final String type;
  final String shortContent;
  final DateTime modificationTime;
  final DateTime validFrom;
  final DateTime validTo;

  NewsItem({
    required this.id,
    required this.title,
    required this.type,
    required this.shortContent,
    required this.modificationTime,
    required this.validFrom,
    required this.validTo,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id_forgalmi_hir']?.toString() ?? '',
      title: json['cim']?.toString() ?? '',
      type: json['hir_tipusa']?.toString() ?? '',
      shortContent: json['rovid_tartalom']?.toString() ?? '',
      modificationTime:
          DateTime.tryParse(json['modositas_idopontja']?.toString() ?? '') ??
          DateTime.now(),
      validFrom:
          DateTime.tryParse(json['ervenyesseg_kezdete']?.toString() ?? '') ??
          DateTime.now(),
      validTo:
          DateTime.tryParse(json['ervenyesseg_vege']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validTo);
  }

  String get formattedValidPeriod {
    final formatter = DateFormat('yyyy.MM.dd HH:mm');
    return '${formatter.format(validFrom)} - ${formatter.format(validTo)}';
  }
}

/// Hír részletek válasz modell
class NewsDetailResponse {
  final List<NewsDetail> details;

  NewsDetailResponse({required this.details});

  factory NewsDetailResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? detailsList = json['forgalmi_hirek'];

    if (detailsList == null || detailsList.isEmpty) {
      return NewsDetailResponse(details: []);
    }

    final List<NewsDetail> details =
        detailsList.map((item) => NewsDetail.fromJson(item)).toList();

    return NewsDetailResponse(details: details);
  }

  NewsDetail? get firstDetail => details.isNotEmpty ? details.first : null;
}

/// Hír részlet modell
class NewsDetail extends NewsItem {
  final String longContent;
  final String mapUrl;

  NewsDetail({
    required super.id,
    required super.title,
    required super.type,
    required super.shortContent,
    required super.modificationTime,
    required super.validFrom,
    required super.validTo,
    required this.longContent,
    required this.mapUrl,
  });

  factory NewsDetail.fromJson(Map<String, dynamic> json) {
    return NewsDetail(
      id: json['id_forgalmi_hir']?.toString() ?? '',
      title: json['cim']?.toString() ?? '',
      type: json['hir_tipusa']?.toString() ?? '',
      shortContent: json['rovid_tartalom']?.toString() ?? '',
      longContent: json['hosszu_tartalom']?.toString() ?? '',
      mapUrl: json['terkep_url']?.toString() ?? '',
      modificationTime:
          DateTime.tryParse(json['modositas_idopontja']?.toString() ?? '') ??
          DateTime.now(),
      validFrom:
          DateTime.tryParse(json['ervenyesseg_kezdete']?.toString() ?? '') ??
          DateTime.now(),
      validTo:
          DateTime.tryParse(json['ervenyesseg_vege']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  String get cleanLongContent {
    // HTML tagek eltávolítása
    return longContent
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&aacute;', 'á')
        .replaceAll('&eacute;', 'é')
        .replaceAll('&iacute;', 'í')
        .replaceAll('&oacute;', 'ó')
        .replaceAll('&uacute;', 'ú')
        .replaceAll('&ouml;', 'ö')
        .replaceAll('&uuml;', 'ü')
        .replaceAll('&Aacute;', 'Á')
        .replaceAll('&Eacute;', 'É')
        .replaceAll('&Iacute;', 'Í')
        .replaceAll('&Oacute;', 'Ó')
        .replaceAll('&Uacute;', 'Ú')
        .replaceAll('&Ouml;', 'Ö')
        .replaceAll('&Uuml;', 'Ü');
  }
}

/// Törölt járatok válasz modell
class CancelledRoutesResponse {
  final List<CancelledRoute> cancelledRoutes;

  CancelledRoutesResponse({required this.cancelledRoutes});

  factory CancelledRoutesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? routesList = json['torolt_jaratok'];

    if (routesList == null || routesList.isEmpty) {
      return CancelledRoutesResponse(cancelledRoutes: []);
    }

    final List<CancelledRoute> routes =
        routesList.map((item) => CancelledRoute.fromJson(item)).toList();

    return CancelledRoutesResponse(cancelledRoutes: routes);
  }

  bool get hasActiveCancellations => cancelledRoutes.isNotEmpty;
}

/// Törölt járat modell
class CancelledRoute {
  final String routeId;
  final String routeName;
  final String reason;
  final DateTime cancelTime;
  final DateTime? estimatedRestoration;

  CancelledRoute({
    required this.routeId,
    required this.routeName,
    required this.reason,
    required this.cancelTime,
    this.estimatedRestoration,
  });

  factory CancelledRoute.fromJson(Map<String, dynamic> json) {
    return CancelledRoute(
      routeId: json['jarat_id']?.toString() ?? '',
      routeName: json['vonal_nev']?.toString() ?? '',
      reason: json['torles_oka']?.toString() ?? '',
      cancelTime:
          DateTime.tryParse(json['torles_ideje']?.toString() ?? '') ??
          DateTime.now(),
      estimatedRestoration: DateTime.tryParse(
        json['helyreallitas_ideje']?.toString() ?? '',
      ),
    );
  }

  String get formattedCancelTime {
    return DateFormat('yyyy.MM.dd HH:mm').format(cancelTime);
  }

  String get formattedEstimatedRestoration {
    if (estimatedRestoration != null) {
      return DateFormat('yyyy.MM.dd HH:mm').format(estimatedRestoration!);
    }
    return 'Nincs megadva';
  }
}
