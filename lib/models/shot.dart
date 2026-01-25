class ShotSummary {
  ShotSummary({required this.shots});

  final List<Shot> shots;

  int get total => shots.length;

  int get madeCount => shots.where((s) => s.made).length;

  double get successRate => total == 0 ? 0 : madeCount / total;

  double get averageAngle => total == 0
      ? 0
      : shots.map((s) => s.releaseAngle).reduce((a, b) => a + b) / total;
}

class Shot {
  Shot({
    required this.shotId,
    required this.made,
    required this.releaseAngle,
    required this.releaseHeight,
    required this.shotDistance,
  });

  final int shotId;
  final bool made;
  final double releaseAngle; // degrees
  final double releaseHeight; // meters
  final double shotDistance; // meters

  factory Shot.fromJson(Map<String, dynamic> json) {
    return Shot(
      shotId: (json['shotId'] as num).toInt(),
      made: json['made'] as bool,
      releaseAngle: (json['releaseAngle'] as num).toDouble(),
      releaseHeight: (json['releaseHeight'] as num).toDouble(),
      shotDistance: (json['shotDistance'] as num).toDouble(),
    );
  }
}
