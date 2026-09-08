import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/bjt_physics.dart';

class InputCurvePainter extends CustomPainter {
  final double selectedVce; // 1.0 or 2.0 V
  final double currentVbb; // 0.0 to 5.0 V
  final double currentVbe; // V
  final double currentIbMa; // mA

  InputCurvePainter({
    required this.selectedVce,
    required this.currentVbb,
    required this.currentVbe,
    required this.currentIbMa,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftMargin = 45.0;
    const topMargin = 22.0;
    final rightMargin = size.width - 16.0;
    final bottomMargin = size.height - 30.0;
    final graphWidth = rightMargin - leftMargin;
    final graphHeight = bottomMargin - topMargin;

    final gridPaint = Paint()
      ..color = const Color(0xff1d2d48)
      ..strokeWidth = 0.8;

    final axisPaint = Paint()
      ..color = const Color(0xff3b5278)
      ..strokeWidth = 1.5;

    // Y-axis grid lines and ticks (IB: 0 to 5 mA as in Experiment 5 with 1k resistor)
    const yMax = 5.0; // mA
    const ySteps = 5;
    for (int i = 0; i <= ySteps; i++) {
      final y = bottomMargin - (graphHeight * i / ySteps);
      canvas.drawLine(Offset(leftMargin, y), Offset(rightMargin, y), gridPaint);

      final currentVal = (i * (yMax / ySteps)).toStringAsFixed(1);
      _drawText(
        canvas,
        currentVal,
        Offset(leftMargin - 28, y - 6),
        const TextStyle(color: Color(0xff889ec1), fontSize: 10, fontWeight: FontWeight.w600),
      );
    }

    // X-axis grid lines and ticks (VBE: 0.0 to 1.2 V as in Image 3)
    const xMax = 1.2; // V
    const xSteps = 6;
    for (int i = 0; i <= xSteps; i++) {
      final x = leftMargin + (graphWidth * i / xSteps);
      canvas.drawLine(Offset(x, topMargin), Offset(x, bottomMargin), gridPaint);

      final voltageVal = (i * 0.2).toStringAsFixed(1);
      _drawText(
        canvas,
        voltageVal,
        Offset(x - 8, bottomMargin + 8),
        const TextStyle(color: Color(0xff889ec1), fontSize: 10, fontWeight: FontWeight.w600),
      );
    }

    // Axes
    canvas.drawLine(Offset(leftMargin, topMargin - 6), Offset(leftMargin, bottomMargin), axisPaint);
    canvas.drawLine(Offset(leftMargin, bottomMargin), Offset(rightMargin + 6, bottomMargin), axisPaint);

    // Axis Labels
    _drawText(
      canvas,
      'IB (mA)',
      const Offset(6, 4),
      const TextStyle(color: Color(0xfff6ad55), fontSize: 11, fontWeight: FontWeight.w800),
    );
    _drawText(
      canvas,
      'VBE (V) →',
      Offset(rightMargin - 46, bottomMargin + 14),
      const TextStyle(color: Color(0xfff6ad55), fontSize: 11, fontWeight: FontWeight.w800),
    );

    // Cut-in reference line (0.65 - 0.7 V)
    const kneeV = 0.68;
    final kneeX = leftMargin + (kneeV / xMax) * graphWidth;
    final kneePaint = Paint()
      ..color = const Color(0xffe6a23c).withValues(alpha: 0.45)
      ..strokeWidth = 1.2;
    _drawDashedLine(canvas, Offset(kneeX, topMargin + 25), Offset(kneeX, bottomMargin), kneePaint);
    _drawText(
      canvas,
      'Cut-in ≈ 0.7V',
      Offset(kneeX - 25, topMargin + 10),
      const TextStyle(
        color: Color(0xfff5b358),
        fontSize: 9.5,
        fontWeight: FontWeight.bold,
        backgroundColor: Color(0xbb101d32),
      ),
    );

    // Family of VCE curves: VCE = 1V and VCE = 2V (from Experiment 5)
    for (final curveVce in [1.0, 2.0]) {
      final isCurrent = (selectedVce - curveVce).abs() < 0.5;
      final path = Path();
      bool started = false;

      // Sample 70 points from Vbb = 0 to 5.5 V
      for (int step = 0; step <= 70; step++) {
        final stepVbb = step * (5.5 / 70);
        final res = BjtPhysics.solveInputCircuit(vbb: stepVbb, vce: curveVce);
        final vbeVal = res['vbe']!;
        final ibVal = res['ibMa']!;

        final x = leftMargin + (math.min(xMax, vbeVal) / xMax) * graphWidth;
        final clampedIb = math.min(yMax, ibVal);
        final y = bottomMargin - (clampedIb / yMax) * graphHeight;

        if (!started) {
          path.moveTo(x, y);
          started = true;
        } else {
          path.lineTo(x, y);
        }
      }

      final curvePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (isCurrent) {
        curvePaint
          ..color = const Color(0xfff6ad55)
          ..strokeWidth = 2.8;

        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xfff6ad55).withValues(alpha: 0.25)
          ..strokeWidth = 6.0;
        canvas.drawPath(path, glowPaint);
      } else {
        curvePaint
          ..color = const Color(0xff577098)
          ..strokeWidth = 1.4;
      }

      canvas.drawPath(path, curvePaint);

      // Curve label tag at upper section
      final endRes = BjtPhysics.solveInputCircuit(vbb: 5.0, vce: curveVce);
      final tagY = bottomMargin - (math.min(yMax - 0.2, endRes['ibMa']!) / yMax) * graphHeight;
      final tagX = leftMargin + (math.min(xMax - 0.05, endRes['vbe']!) / xMax) * graphWidth;
      _drawText(
        canvas,
        'VCE=${curveVce.toInt()}V',
        Offset(tagX - 15, tagY - 14 - (curveVce == 1.0 ? 12 : 0)),
        TextStyle(
          color: isCurrent ? const Color(0xfff6ad55) : const Color(0xff758caa),
          fontSize: 9,
          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
        ),
      );
    }

    // Operating point (Q-point) on the current curve
    final qX = leftMargin + (math.min(xMax, currentVbe) / xMax) * graphWidth;
    final clampedIb = math.min(yMax, currentIbMa);
    final qY = bottomMargin - (clampedIb / yMax) * graphHeight;

    // Crosshairs
    final crosshairPaint = Paint()
      ..color = const Color(0xfff6ad55).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    _drawDashedLine(canvas, Offset(leftMargin, qY), Offset(qX, qY), crosshairPaint);
    _drawDashedLine(canvas, Offset(qX, bottomMargin), Offset(qX, qY), crosshairPaint);

    // Q-point dot
    final qGlow = Paint()
      ..color = const Color(0xfff6ad55).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(qX, qY), 9, qGlow);

    final qDot = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(qX, qY), 4.5, qDot);

    final qRing = Paint()
      ..color = const Color(0xffe67e22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(Offset(qX, qY), 4.5, qRing);

    // Badge with coordinates
    final badgeText = 'Q: ${currentVbe.toStringAsFixed(3)}V, ${currentIbMa.toStringAsFixed(2)}mA';
    final badgeX = (qX > rightMargin - 100) ? qX - 110 : qX + 10;
    final badgeY = (qY < topMargin + 25) ? qY + 10 : qY - 22;

    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, 110, 18),
      const Radius.circular(5),
    );
    canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xee162238));
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..color = const Color(0xfff6ad55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    _drawText(
      canvas,
      badgeText,
      Offset(badgeX + 5, badgeY + 3.5),
      const TextStyle(color: Color(0xfff6ad55), fontSize: 9, fontWeight: FontWeight.bold),
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.5;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;
    final unitX = dx / distance;
    final unitY = dy / distance;

    double current = 0.0;
    while (current < distance) {
      final startX = p1.dx + unitX * current;
      final startY = p1.dy + unitY * current;
      final endDistance = math.min(current + dashWidth, distance);
      final endX = p1.dx + unitX * endDistance;
      final endY = p1.dy + unitY * endDistance;
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
      current += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant InputCurvePainter oldDelegate) {
    return oldDelegate.selectedVce != selectedVce ||
        oldDelegate.currentVbb != currentVbb ||
        oldDelegate.currentVbe != currentVbe ||
        oldDelegate.currentIbMa != currentIbMa;
  }
}
