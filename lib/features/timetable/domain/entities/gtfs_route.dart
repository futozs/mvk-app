class GtfsRoute {
  final String agencyId;
  final String routeId;
  final String routeShortName;
  final String routeLongName;
  final int routeType;

  const GtfsRoute({
    required this.agencyId,
    required this.routeId,
    required this.routeShortName,
    required this.routeLongName,
    required this.routeType,
  });

  factory GtfsRoute.fromCsv(List<String> values) {
    try {
      return GtfsRoute(
        agencyId: values.isNotEmpty ? values[0].replaceAll('"', '') : '',
        routeId: values.length > 1 ? values[1].replaceAll('"', '') : '',
        routeShortName: values.length > 2 ? values[2].replaceAll('"', '') : '',
        routeLongName: values.length > 3 ? values[3].replaceAll('"', '') : '',
        routeType:
            values.length > 4
                ? int.tryParse(values[4].replaceAll('"', '')) ?? 3
                : 3,
      );
    } catch (e) {
      // Fallback értékekkel visszatérés hiba esetén
      return GtfsRoute(
        agencyId: '31',
        routeId: 'unknown',
        routeShortName: '?',
        routeLongName: 'Ismeretlen járat',
        routeType: 3,
      );
    }
  }

  // Útvonal típus alapján színt ad vissza
  String get routeTypeText {
    switch (routeType) {
      case 0:
        return 'Villamos';
      case 3:
        return 'Busz';
      default:
        return 'Járat';
    }
  }
}
