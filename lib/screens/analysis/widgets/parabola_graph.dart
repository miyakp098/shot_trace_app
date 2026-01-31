import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shot_trace_app/models/shot.dart';

class ParabolaGraph extends StatelessWidget {
  final List<Shot> shots;
  const ParabolaGraph({super.key, required this.shots});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: side,
            height: side,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CustomPaint(painter: _ParabolaPainter(shots)),
            ),
          ),
        );
      },
    );
  }
}

class _ParabolaPainter extends CustomPainter {
  _ParabolaPainter(this.shots);
  final List<Shot> shots;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 24.0;
    const right = 12.0;
    const top = 16.0;
    const fixedMaxD = 9.0;
    const fixedMaxH = 9.0;
    final maxH = fixedMaxH;
    final groundY = size.height - 24;
    final widthUsable = size.width - left - right;
    final heightUsable = groundY - top;
    final kx = widthUsable / fixedMaxD;
    final ky = heightUsable / (maxH == 0 ? 1 : maxH);

    final axisPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(left, groundY),
      Offset(size.width - right, groundY),
      axisPaint,
    );
    canvas.drawLine(Offset(left, groundY), Offset(left, top), axisPaint);

    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(left, groundY),
      Offset(size.width - right, groundY),
      bgPaint,
    );

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    for (int m = 1; m < maxH; m++) {
      final y = groundY - m * ky;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }
    for (int m = 1; m < fixedMaxD; m++) {
      final x = left + m * kx;
      canvas.drawLine(Offset(x, groundY), Offset(x, top), gridPaint);
    }

    // 横軸8m、縦軸3.05mの位置に円を描画（目印として残す場合はこのまま）
    final double plotX = left + 8.0 * kx;
    final double plotY = groundY - 3.05 * ky;
    final Paint plotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(plotX, plotY), 7, plotPaint);
    final Paint borderPaint = Paint()
      ..color = Colors.blue.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(plotX, plotY), 7, borderPaint);

    // リリースポイントの円描画は削除

    final tickPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1;
    final textStyle = TextStyle(color: Colors.grey[700], fontSize: 10);
    for (int m = 0; m <= fixedMaxD; m++) {
      final x = left + m * kx;
      canvas.drawLine(Offset(x, groundY), Offset(x, groundY + 6), tickPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$m', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(x - tp.width / 2, groundY + 8));
    }
    for (int m = 1; m <= maxH; m++) {
      final y = groundY - m * ky;
      canvas.drawLine(Offset(left - 6, y), Offset(left, y), tickPaint);
      final tp = TextPainter(
        text: TextSpan(text: '$m', style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(left - tp.width - 10, y - tp.height / 2));
    }

    if (shots.isEmpty) return;

    for (final s in shots) {
      final path = Path();
      final color = s.made ? Colors.green : Colors.red;
      final p = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      const samples = 60;
      // リリース・ゴール座標
      final rx = left + s.releasePosition.x * kx;
      final ry = groundY - s.releasePosition.y * ky;
      final ex = left + s.endPosition.x * kx;
      final ey = groundY - s.endPosition.y * ky;
      // 放物線の高さ（releaseHeightとゴール高さの中間+αで近似）
      final peakY = math.min(ry, ey) - 2.0 * ky;
      for (int i = 0; i <= samples; i++) {
        final t = i / samples;
        // 2次ベジェで近似
        final px =
            (1 - t) * (1 - t) * rx +
            2 * (1 - t) * t * ((rx + ex) / 2) +
            t * t * ex;
        final py =
            (1 - t) * (1 - t) * ry + 2 * (1 - t) * t * peakY + t * t * ey;
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
    return !identical(oldDelegate.shots, shots);
  }
}
