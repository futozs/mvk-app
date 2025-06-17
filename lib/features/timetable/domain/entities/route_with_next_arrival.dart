class RouteWithNextArrival {
  final String routeId;
  final String routeShortName;
  final String routeLongName;
  final int routeType;
  final int nextArrivalMinutes;
  final String? nextStopName;

  const RouteWithNextArrival({
    required this.routeId,
    required this.routeShortName,
    required this.routeLongName,
    required this.routeType,
    required this.nextArrivalMinutes,
    this.nextStopName,
  });

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

  String get nextArrivalText {
    if (nextArrivalMinutes <= 0) return 'Most érkezik';
    if (nextArrivalMinutes == 1) return '1 perc';
    return '$nextArrivalMinutes perc';
  }
}
