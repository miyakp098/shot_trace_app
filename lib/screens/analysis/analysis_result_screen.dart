import 'dart:convert';
import 'dart:math' as math;

import 'widgets/parabola_graph.dart';
import 'widgets/stats_row.dart';
import 'package:shot_trace_app/models/shot.dart';
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
          final media = MediaQuery.of(context);
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
                // グラフは固定（スクロールさせない）
                LayoutBuilder(
                  builder: (context, constraints) {
                    // 画面幅に合わせつつ、縦が厳しい端末では高さを抑える
                    final maxByWidth = constraints.maxWidth;
                    final maxByHeight = media.size.height * 0.50;
                    final side = math.min(maxByWidth, maxByHeight);

                    return Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: side,
                        height: side,
                        child: ParabolaGraph(shots: summary.shots),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // 統計は下部だけスクロール
                Expanded(
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StatsRow(summary: summary),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
