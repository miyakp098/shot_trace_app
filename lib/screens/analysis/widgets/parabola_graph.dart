import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shot_trace_app/models/shot.dart';

class ParabolaGraph extends StatefulWidget {
  final List<Shot> shots;
  const ParabolaGraph({super.key, required this.shots});

  @override
  State<ParabolaGraph> createState() => _ParabolaGraphState();
}

class _ParabolaGraphState extends State<ParabolaGraph> {
  int? selectedShotId;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double minGraphSize = 180.0;
        final double maxHeight = constraints.hasBoundedHeight
            ? constraints.maxHeight * 0.6
            : constraints.maxWidth;
        final double desired = math.max(
          minGraphSize,
          math.min(constraints.maxWidth, maxHeight),
        );
        final double side = math.min(desired, constraints.maxWidth);
        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(
              width: side,
              height: side,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: CustomPaint(
                  painter: _ParabolaPainter(
                    widget.shots,
                    highlightedId: selectedShotId,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemBuilder: (context, index) {
                  final s = widget.shots[index];
                  final isSelected = s.shotId == selectedShotId;
                  return GestureDetector(
                    onTap: () => setState(() => selectedShotId = s.shotId),
                    child: AnimatedContainer(
                      width: double.infinity,
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade50 : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 6,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue.withOpacity(0.12)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ID ${s.shotId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peak ${s.peakHeight.toStringAsFixed(1)}m',
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'From (${s.releasePosition.x.toStringAsFixed(1)}, ${s.releasePosition.y.toStringAsFixed(1)}) → (${s.endPosition.x.toStringAsFixed(1)}, ${s.endPosition.y.toStringAsFixed(1)})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: widget.shots.length,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ParabolaPainter extends CustomPainter {
  _ParabolaPainter(this.shots, {this.highlightedId});
  final List<Shot> shots;
  final int? highlightedId;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 24.0;
    const right = 12.0;
    const top = 16.0;
    const bottom = 24.0;
    const fixedMaxD = 9.0; // x軸は1〜9m表示
    const fixedMaxH = 6.0; // y軸は0〜6m表示
    final maxH = fixedMaxH;
    final widthUsable = size.width - left - right;
    final heightUsable = size.height - top - bottom;
    // 1mあたりのピクセルをx/y同一にする
    final k = math.min(widthUsable / fixedMaxD, heightUsable / maxH);
    final kx = k;
    final ky = k;
    // グラフ領域を中央に揃える原点（左下）
    final xOrigin = left + (widthUsable - fixedMaxD * k) / 2.0;
    final groundY = top + (heightUsable - maxH * k) / 2.0 + maxH * k;

    final axisPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2;
    // X軸（地面）とY軸を同一スケールで描画
    canvas.drawLine(
      Offset(xOrigin, groundY),
      Offset(xOrigin + fixedMaxD * k, groundY),
      axisPaint,
    );
    canvas.drawLine(
      Offset(xOrigin, groundY),
      Offset(xOrigin, groundY - maxH * k),
      axisPaint,
    );
    // リリースポイントの円描画は削除

    final tickPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1;
    final textStyle = TextStyle(color: Colors.grey[700], fontSize: 10);
    // x目盛は1〜9表示（0は表示しない）
    for (int m = 1; m <= fixedMaxD; m++) {
      final x = xOrigin + m * kx;
      canvas.drawLine(Offset(x, groundY), Offset(x, groundY + 6), tickPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$m', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, groundY + 8));
    }
    // y目盛は1〜6表示
    for (int m = 1; m <= maxH; m++) {
      final y = groundY - m * ky;
      canvas.drawLine(Offset(xOrigin - 6, y), Offset(xOrigin, y), tickPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$m', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(xOrigin - tp.width - 10, y - tp.height / 2));
    }

    if (shots.isEmpty) return;

    // 二次関数 y = a(x - xv)^2 + hv でピーク高さを厳密に反映して描画
    for (final s in shots) {
      final path = Path();
      final bool isHighlight =
          highlightedId == null || s.shotId == highlightedId;
      final baseColor = s.made ? Colors.green : Colors.red;
      final color = isHighlight ? baseColor : baseColor.withOpacity(0.25);
      final stroke = isHighlight ? 3.0 : 1.5;
      final p = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke;
      const samples = 80;

      // メートル座標系での始点・終点・頂点高さ
      final double x0 = s.releasePosition.x;
      final double y0 = s.releasePosition.y;
      final double x2 = s.endPosition.x;
      final double y2 = s.endPosition.y;
      double hv = s.peakHeight;
      final double yminReq = math.max(y0, y2) + 1e-6;
      if (hv <= yminReq) {
        hv = yminReq + 0.1; // 頂点が始終点より上に来るよう僅かに調整
      }

      // 頂点x座標xvを解く（頂点が必ず区間内に来るよう距離の和で解く）
      // d0 = |x0 - xv|, d2 = |x2 - xv|, d0/d2 = r, かつ d0 + d2 = |x2 - x0|
      // r = sqrt((y0 - hv)/(y2 - hv)) (>0) として、xv = (xL + r*xR)/(1+r) の形で区間内に配置
      final double ratio = (y0 - hv) / (y2 - hv);
      final double r = ratio > 0 ? math.sqrt(ratio.abs()) : 1.0;
      double xv;
      if (x0 <= x2) {
        xv = (x0 + r * x2) / (1.0 + r);
      } else {
        xv = (x2 + r * x0) / (1.0 + r);
      }
      final double a = (y0 - hv) / ((x0 - xv) * (x0 - xv));

      for (int i = 0; i <= samples; i++) {
        final double xm = x0 + (x2 - x0) * (i / samples);
        final double ym = a * (xm - xv) * (xm - xv) + hv;
        final double px = xOrigin + xm * kx;
        final double py = groundY - ym * ky;
        if (i == 0) {
          path.moveTo(px, py);
        } else {
          path.lineTo(px, py);
        }
      }
      canvas.drawPath(path, p);
    }
  }

  // Peak height computation via shotDistance is no longer used.

  @override
  bool shouldRepaint(covariant _ParabolaPainter oldDelegate) {
    return !identical(oldDelegate.shots, shots) ||
        oldDelegate.highlightedId != highlightedId;
  }
}
