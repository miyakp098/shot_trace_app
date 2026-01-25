import 'dart:convert';
import 'dart:math' as math;

import 'widgets/parabola_graph.dart';
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
                Expanded(
                  child: ParabolaGraph(shots: summary.shots),
                ),
                const SizedBox(height: 16),
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
