import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/bjt_physics.dart';

class OutputCurvePainter extends CustomPainter {
  final double currentVcc; // 0 to 15 V
  final double currentVce; // V
  final double currentIcMa; // mA
  final double selectedIbUa; // 4.3 or 10.0 uA

  OutputCurvePainter({
    required this.currentVcc,
    required this.currentVce,
    required this.currentIcMa,
    required this.selectedIbUa,
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

    // Saturation region background shading (0 to 2V) as in Image 4
    final satWidth = (2.0 / 20.0) * graphWidth;
    final satRect = Rect.fromLTWH(leftMargin, topMargin, satWidth, graphHeight);
    canvas.drawRect(satRect, Paint()..color = const Color(0xff4ea5d9).withValues(alpha: 0.12));

    // Active region background shading (2 to 20V) as in Image 4
    final activeRect = Rect.fromLTWH(leftMargin + satWidth, topMargin, graphWidth - satWidth, graphHeight);
    canvas.drawRect(activeRect, Paint()..color = const Color(0xffd16ba5).withValues(alpha: 0.08));

    // Saturation boundary line at 2V
    _drawDashedLine(
      canvas,
      Offset(leftMargin + satWidth, topMargin),
      Offset(leftMargin + satWidth, bottomMargin),
      Paint()
        ..color = const Color(0xff4ea5d9).withValues(alpha: 0.4)
        ..strokeWidth = 1.0,
    );

    // Y-axis grid lines and ticks (IC: 0 to 30 mA as in Image 4)
    const yMax = 30.0;
    const ySteps = 3;
    for (int i = 0; i <= ySteps; i++) {
      final y = bottomMargin - (graphHeight * i / ySteps);
      canvas.drawLine(Offset(leftMargin, y), Offset(rightMargin, y), gridPaint);

      final currentVal = (i * 10).toString();
      _drawText(
        canvas,
        currentVal,
        Offset(leftMargin - 22, y - 6),
        const TextStyle(color: Color(0xff889ec1), fontSize: 10, fontWeight: FontWeight.w600),
      );
    }

    // X-axis grid lines and ticks (Vce: 0 to 20 Volts as in Image 4)
    const xMax = 20.0;
    const xSteps = 4;
    for (int i = 0; i <= xSteps; i++) {
      final x = leftMargin + (graphWidth * i / xSteps);
      canvas.drawLine(Offset(x, topMargin), Offset(x, bottomMargin), gridPaint);

      final voltageVal = (i * 5).toString();
      _drawText(
        canvas,
        voltageVal,
        Offset(x - 6, bottomMargin + 8),
        const TextStyle(color: Color(0xff889ec1), fontSize: 10, fontWeight: FontWeight.w600),
      );
    }

    // Axes
    canvas.drawLine(Offset(leftMargin, topMargin - 6), Offset(leftMargin, bottomMargin), axisPaint);
    canvas.drawLine(Offset(leftMargin, bottomMargin), Offset(rightMargin + 6, bottomMargin), axisPaint);

    // Axis Labels
    _drawText(
      canvas,
      'IC (mA)',
      const Offset(6, 4),
      const TextStyle(color: Color(0xff67d7b4), fontSize: 11, fontWeight: FontWeight.w800),
    );
    _drawText(
      canvas,
      'Vce (Volts) →',
      Offset(rightMargin - 60, bottomMargin + 14),
      const TextStyle(color: Color(0xff67d7b4), fontSize: 11, fontWeight: FontWeight.w800),
    );

    // Family of Curves from Image 4: Ib = 50, 100, 150, 200, 250 uA + Lab curves (4.3uA, 10uA)
    final ibCurves = [4.3, 10.0, 50.0, 100.0, 150.0, 200.0, 250.0];

    for (final curveIb in ibCurves) {
      final isCurrent = (selectedIbUa - curveIb).abs() < 1.0;
      final path = Path();
      bool started = false;

      for (int step = 0; step <= 80; step++) {
        final stepVce = step * (xMax / 80);
        // Base transistor active current in mA: beta * Ib with Early slope
        final icActive = (BjtPhysics.nominalBeta * curveIb) / 1000.0;
        final satFactor = 1.0 - math.exp(-stepVce / 0.5);
        final earlyFactor = 1.0 + (stepVce / BjtPhysics.earlyVoltageVa);
        final icVal = icActive * satFactor * earlyFactor;

        final x = leftMargin + (stepVce / xMax) * graphWidth;
        final clampedIc = math.min(yMax, icVal);
        final y = bottomMargin - (clampedIc / yMax) * graphHeight;

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
          ..color = const Color(0xff67d7b4)
          ..strokeWidth = 2.8;

        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xff67d7b4).withValues(alpha: 0.3)
          ..strokeWidth = 6.0;
        canvas.drawPath(path, glowPaint);
      } else {
        curvePaint
          ..color = curveIb <= 10.0
              ? const Color(0xff7ca4d8).withValues(alpha: 0.8)
              : const Color(0xff445f82).withValues(alpha: 0.5)
          ..strokeWidth = 1.2;
      }

      canvas.drawPath(path, curvePaint);

      // Curve label tag on right
      final icEnd = ((BjtPhysics.nominalBeta * curveIb) / 1000.0) * (1.0 + xMax / 100.0);
      final tagY = bottomMargin - (math.min(yMax - 0.5, icEnd) / yMax) * graphHeight;
      _drawText(
        canvas,
        'Ib=${curveIb.toInt()}µA',
        Offset(rightMargin - 42, tagY - 6),
        TextStyle(
          color: isCurrent ? const Color(0xff67d7b4) : const Color(0xff6b84a8),
          fontSize: 8,
          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
        ),
      );
    }

    // Operating point (Q-point) for current Vce and IC
    final qX = leftMargin + (math.min(xMax, currentVce) / xMax) * graphWidth;
    final clampedCurrentIc = math.min(yMax, currentIcMa);
    final qY = bottomMargin - (clampedCurrentIc / yMax) * graphHeight;

    // Crosshairs
    final crosshairPaint = Paint()
      ..color = const Color(0xff67d7b4).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;
    _drawDashedLine(canvas, Offset(leftMargin, qY), Offset(qX, qY), crosshairPaint);
    _drawDashedLine(canvas, Offset(qX, bottomMargin), Offset(qX, qY), crosshairPaint);

    // Q-point dot
    final qGlow = Paint()
      ..color = const Color(0xff67d7b4).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(qX, qY), 9, qGlow);

    final qDot = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(qX, qY), 4.5, qDot);

    final qRing = Paint()
      ..color = const Color(0xff1ca783)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(Offset(qX, qY), 4.5, qRing);

    // Q-point badge
    final badgeText = 'Q: ${currentVce.toStringAsFixed(1)}V, ${currentIcMa.toStringAsFixed(2)}mA';
    final badgeX = (qX > rightMargin - 105) ? qX - 120 : qX + 10;
    final badgeY = (qY < topMargin + 25) ? qY + 10 : qY - 22;

    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, 115, 18),
      const Radius.circular(5),
    );
    canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xee10262b));
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..color = const Color(0xff67d7b4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    _drawText(
      canvas,
      badgeText,
      Offset(badgeX + 5, badgeY + 3.5),
      const TextStyle(color: Color(0xff67d7b4), fontSize: 9, fontWeight: FontWeight.bold),
    );

    // Region labels
    _drawText(
      canvas,
      'SATURATION',
      Offset(leftMargin + 4, topMargin + 4),
      const TextStyle(color: Color(0xff4ea5d9), fontSize: 8.5, fontWeight: FontWeight.bold),
    );
    _drawText(
      canvas,
      'ACTIVE REGION',
      Offset(leftMargin + graphWidth * 0.45, topMargin + 4),
      const TextStyle(color: Color(0xffd16ba5), fontSize: 9, fontWeight: FontWeight.bold),
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
  bool shouldRepaint(covariant OutputCurvePainter oldDelegate) {
    return oldDelegate.currentVcc != currentVcc ||
        oldDelegate.currentVce != currentVce ||
        oldDelegate.currentIcMa != currentIcMa ||
        oldDelegate.selectedIbUa != selectedIbUa;
  }
}
