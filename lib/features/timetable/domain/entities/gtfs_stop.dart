class GtfsStop {
  final String stopId;
  final String stopName;
  final double stopLat;
  final double stopLon;

  const GtfsStop({
    required this.stopId,
    required this.stopName,
    required this.stopLat,
    required this.stopLon,
  });

  factory GtfsStop.fromCsv(List<String> values) {
    try {
      return GtfsStop(
        stopId: values.isNotEmpty ? values[0].replaceAll('"', '') : '',
        stopName: values.length > 1 ? values[1].replaceAll('"', '') : '',
        stopLat:
            values.length > 2
                ? double.tryParse(values[2].replaceAll('"', '')) ?? 0.0
                : 0.0,
        stopLon:
            values.length > 3
                ? double.tryParse(values[3].replaceAll('"', '')) ?? 0.0
                : 0.0,
      );
    } catch (e) {
      // Fallback értékekkel visszatérés hiba esetén
      return GtfsStop(
        stopId: 'unknown',
        stopName: 'Ismeretlen megálló',
        stopLat: 48.1,
        stopLon: 20.8,
      );
    }
  }
}
