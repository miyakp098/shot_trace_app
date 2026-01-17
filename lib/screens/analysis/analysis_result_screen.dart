import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class AnalysisResultScreen extends StatefulWidget {
  const AnalysisResultScreen({super.key});

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  late Future<ShotSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadMock();
  }

  Future<ShotSummary> _loadMock() async {
    final jsonStr = await rootBundle.loadString('mock/detailData.json');
    final map = json.decode(jsonStr) as Map<String, dynamic>;
    final shots = (map['shots'] as List<dynamic>)
        .map((e) => Shot.fromJson(e as Map<String, dynamic>))
        .toList();

    return ShotSummary(shots: shots);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('分析結果'),
      ),
      body: FutureBuilder<ShotSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('読み込みエラー: ${snapshot.error}'));
          }
          final summary = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Legend
                Row(
                  children: const [
                    _LegendDot(color: Colors.green, label: '成功'),
                    SizedBox(width: 12),
                    _LegendDot(color: Colors.red, label: '失敗'),
                  ],
                ),
                const SizedBox(height: 12),
                // Graph (正方形を維持)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final side = math.min(constraints.maxWidth, constraints.maxHeight);
                      return Center(
                        child: SizedBox(
                          width: side,
                          height: side,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: CustomPaint(
                              painter: _ParabolaPainter(summary.shots),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Stats
                _StatsRow(summary: summary),
              ],
            ),
          );
        },
      ),
    );
  }
}

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
  final double releaseHeight; // meters (unused in calc but available)
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

class _ParabolaPainter extends CustomPainter {
  _ParabolaPainter(this.shots);

  final List<Shot> shots;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw ground/base line
    final groundY = size.height - 24;
    canvas.drawLine(Offset(24, groundY), Offset(size.width - 12, groundY), bgPaint);

    if (shots.isEmpty) return;

    // Determine scaling based on max distance and peak height (derived from angle)
    final maxD = shots.map((s) => s.shotDistance).reduce(math.max);
    final peakHeights = shots.map((s) => _peakHeightFor(s));
    final maxH = peakHeights.reduce(math.max);

    // Margins
    const left = 24.0;
    const right = 12.0;
    const top = 16.0;
    final widthUsable = size.width - left - right;
    final heightUsable = groundY - top;

    // Scale factors to fit all parabolas
    final kx = widthUsable / maxD; // meters -> px
    final ky = heightUsable / (maxH == 0 ? 1 : maxH); // meters -> px

    for (final s in shots) {
      final path = Path();
      final d = s.shotDistance;
      final h = _peakHeightFor(s);
      final color = s.made ? Colors.green : Colors.red;
      final p = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      // Sample the parabola: y(x) = 4H*(x/D)*(1 - x/D)
      const samples = 60;
      for (int i = 0; i <= samples; i++) {
        final x = d * (i / samples);
        final y = 4 * h * (x / d) * (1 - (x / d));

        final px = left + x * kx;
        final py = groundY - y * ky;
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }

      canvas.drawPath(path, p);
    }
  }

  // Convert angle+distance into a visually reasonable peak height.
  // We simply scale by distance and sin(angle) to get intuitive curvature.
  double _peakHeightFor(Shot s) {
    final angRad = s.releaseAngle * math.pi / 180.0;
    // Base coefficient tuned for visual balance.
    const coeff = 0.25; // roughly quarter of distance as height at 45deg
    return coeff * s.shotDistance * math.sin(angRad).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _ParabolaPainter oldDelegate) {
    return !identical(oldDelegate.shots, shots);
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.summary});

  final ShotSummary summary;

  @override
  Widget build(BuildContext context) {
    final ratePct = (summary.successRate * 100).toStringAsFixed(1);
    final avgAngle = summary.averageAngle.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatTile(title: 'シュート成功率', value: '$ratePct%'),
          _StatTile(title: 'シュート平均角度', value: '$avgAngle°'),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
