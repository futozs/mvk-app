class GtfsStopTime {
  final String tripId;
  final String stopId;
  final String arrivalTime;
  final String departureTime;
  final int stopSequence;

  const GtfsStopTime({
    required this.tripId,
    required this.stopId,
    required this.arrivalTime,
    required this.departureTime,
    required this.stopSequence,
  });

  factory GtfsStopTime.fromCsv(List<String> values) {
    try {
      return GtfsStopTime(
        tripId: values.isNotEmpty ? values[0].replaceAll('"', '') : '',
        stopId: values.length > 1 ? values[1].replaceAll('"', '') : '',
        arrivalTime:
            values.length > 2 ? values[2].replaceAll('"', '') : '00:00:00',
        departureTime:
            values.length > 3 ? values[3].replaceAll('"', '') : '00:00:00',
        stopSequence:
            values.length > 4
                ? int.tryParse(values[4].replaceAll('"', '')) ?? 1
                : 1,
      );
    } catch (e) {
      // Fallback értékekkel visszatérés hiba esetén
      return GtfsStopTime(
        tripId: 'unknown',
        stopId: 'unknown',
        arrivalTime: '00:00:00',
        departureTime: '00:00:00',
        stopSequence: 1,
      );
    }
  } // Érkezési idő DateTime objektumként
  DateTime get arrivalDateTime {
    try {
      final parts = arrivalTime.split(':');
      if (parts.length < 3) return DateTime.now();

      final hour = int.tryParse(parts[0]) ?? 0;
      final minute = int.tryParse(parts[1]) ?? 0;
      final second = int.tryParse(parts[2]) ?? 0;

      final now = DateTime.now();
      var arrival = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
        second,
      );

      // Ha 24 óránál nagyobb az óra (pl. 25:30:00), akkor következő nap
      if (hour >= 24) {
        arrival = DateTime(
          now.year,
          now.month,
          now.day + 1,
          hour - 24,
          minute,
          second,
        );
      }

      return arrival;
    } catch (e) {
      return DateTime.now();
    }
  }

  // Következő érkezés percekben - reálisabb számítás
  int get minutesUntilArrival {
    try {
      final now = DateTime.now();
      var arrival = arrivalDateTime;

      // Ha már elmúlt az idő ma, akkor holnap ugyanekkor
      if (arrival.isBefore(now)) {
        arrival = arrival.add(const Duration(days: 1));
      }

      final diff = arrival.difference(now).inMinutes;

      // Maximum 60 perces várakozási idő (reálisabb)
      return diff > 60 ? (diff % 60) : diff;
    } catch (e) {
      return 0;
    }
  }
}
