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
    required this.releasePosition,
    required this.endPosition,
  });

  final int shotId;
  final bool made;
  final double releaseAngle; // degrees
  final double releaseHeight; // meters
  final ReleasePosition releasePosition;
  final ReleasePosition endPosition;

  factory Shot.fromJson(Map<String, dynamic> json) {
    return Shot(
      shotId: (json['shotId'] as num).toInt(),
      made: json['made'] as bool,
      releaseAngle: (json['releaseAngle'] as num).toDouble(),
      releaseHeight: (json['releaseHeight'] as num).toDouble(),
      releasePosition: ReleasePosition.fromJson(
        json['releasePosition'] as Map<String, dynamic>,
      ),
      endPosition: ReleasePosition.fromJson(
        json['endPosition'] as Map<String, dynamic>,
      ),
    );
  }
}

class ReleasePosition {
  final double x;
  final double y;
  ReleasePosition({required this.x, required this.y});

  factory ReleasePosition.fromJson(Map<String, dynamic> json) {
    return ReleasePosition(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}
