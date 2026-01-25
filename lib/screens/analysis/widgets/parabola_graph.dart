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
              child: CustomPaint(
                painter: _ParabolaPainter(shots),
              ),
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
    canvas.drawLine(Offset(left, groundY), Offset(size.width - right, groundY), axisPaint);
    canvas.drawLine(Offset(left, groundY), Offset(left, top), axisPaint);

    final bgPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawLine(Offset(left, groundY), Offset(size.width - right, groundY), bgPaint);

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;
    for (int m = 1; m < maxH; m++) {
      final y = groundY - m * ky;
      canvas.drawLine(Offset(left, y), Offset(size.width - right, y), gridPaint);
    }
    for (int m = 1; m < fixedMaxD; m++) {
      final x = left + m * kx;
      canvas.drawLine(Offset(x, groundY), Offset(x, top), gridPaint);
    }

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
      final d = s.shotDistance > fixedMaxD ? fixedMaxD : s.shotDistance;
      final h = _peakHeightFor(s);
      final color = s.made ? Colors.green : Colors.red;
      final p = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
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

  double _peakHeightFor(Shot s) {
    final angRad = s.releaseAngle * math.pi / 180.0;
    const coeff = 0.25;
    return coeff * s.shotDistance * math.sin(angRad).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant _ParabolaPainter oldDelegate) {
    return !identical(oldDelegate.shots, shots);
  }
}
