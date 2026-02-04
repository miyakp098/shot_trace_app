import 'dart:convert';
import 'widgets/parabola_graph.dart';
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
      appBar: AppBar(title: const Text('分析結果')),
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
                    _LegendDot(color: Colors.green, label: 'sucsess'),
                    SizedBox(width: 12),
                    _LegendDot(color: Colors.red, label: 'fail'),
                  ],
                ),
                const SizedBox(height: 12),
                // グラフとリストをまとめて広く使う
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ParabolaGraph(shots: summary.shots),
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
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}
