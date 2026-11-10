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

    // Saturation region background shading (0 to 1.0V)
    const xMax = 12.0; // V (scaled for 0-10V lab procedure with label margin)
    final satWidth = (1.0 / xMax) * graphWidth;
    final satRect = Rect.fromLTWH(leftMargin, topMargin, satWidth, graphHeight);
    canvas.drawRect(satRect, Paint()..color = const Color(0xff4ea5d9).withValues(alpha: 0.12));

    // Active region background shading (1.0 to 12V)
    final activeRect = Rect.fromLTWH(leftMargin + satWidth, topMargin, graphWidth - satWidth, graphHeight);
    canvas.drawRect(activeRect, Paint()..color = const Color(0xffd16ba5).withValues(alpha: 0.08));

    // Saturation boundary line at 1.0V
    _drawDashedLine(
      canvas,
      Offset(leftMargin + satWidth, topMargin),
      Offset(leftMargin + satWidth, bottomMargin),
      Paint()
        ..color = const Color(0xff4ea5d9).withValues(alpha: 0.4)
        ..strokeWidth = 1.0,
    );

    // Y-axis grid lines and ticks (IC: 0 to 3.0 mA scaled for wide vertical separation of lab curves)
    const yMax = 3.0; // mA (gives ~47% of total graph height vertical separation between 4.3uA and 10uA)
    const ySteps = 3;
    for (int i = 0; i <= ySteps; i++) {
      final y = bottomMargin - (graphHeight * i / ySteps);
      canvas.drawLine(Offset(leftMargin, y), Offset(rightMargin, y), gridPaint);

      // Intermediate half-steps (dashed)
      if (i < ySteps) {
        final halfY = y - (graphHeight / (ySteps * 2));
        _drawDashedLine(
          canvas,
          Offset(leftMargin, halfY),
          Offset(rightMargin, halfY),
          Paint()
            ..color = const Color(0xff162238)
            ..strokeWidth = 0.6,
        );
      }

      final currentVal = (i * 1.0).toStringAsFixed(0);
      _drawText(
        canvas,
        '$currentVal.0',
        Offset(leftMargin - 28, y - 6),
        const TextStyle(color: Color(0xff889ec1), fontSize: 10, fontWeight: FontWeight.w600),
      );
    }

    // X-axis grid lines and ticks (Vce: 0 to 12 Volts)
    const xSteps = 6; // 0, 2, 4, 6, 8, 10, 12 V
    for (int i = 0; i <= xSteps; i++) {
      final x = leftMargin + (graphWidth * i / xSteps);
      canvas.drawLine(Offset(x, topMargin), Offset(x, bottomMargin), gridPaint);

      final voltageVal = (i * 2).toString();
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

    // Family of Curves focused on the experiment with wide vertical separation:
    // Lab curves: 4.3uA (1M) and 10.0uA (470k)
    // Baseline reference: 1.5uA
    final ibCurves = [1.5, 4.3, 10.0];

    for (final curveIb in ibCurves) {
      final isCurrent = (selectedIbUa - curveIb).abs() < 1.0;
      final isLabCurve = (curveIb == 4.3 || curveIb == 10.0);
      final path = Path();
      bool started = false;

      for (int step = 0; step <= 80; step++) {
        final stepVce = step * (xMax / 80);
        // Base transistor active current in mA: beta * Ib with Early slope
        final icActive = (BjtPhysics.nominalBeta * curveIb) / 1000.0;
        final satFactor = 1.0 - math.exp(-stepVce / 0.35);
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
          ..strokeWidth = 3.0;

        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xff67d7b4).withValues(alpha: 0.35)
          ..strokeWidth = 7.0;
        canvas.drawPath(path, glowPaint);
      } else if (isLabCurve) {
        curvePaint
          ..color = const Color(0xff4ca888).withValues(alpha: 0.75)
          ..strokeWidth = 1.8;
      } else {
        curvePaint
          ..color = const Color(0xff2d4766).withValues(alpha: 0.6)
          ..strokeWidth = 1.0;
      }

      canvas.drawPath(path, curvePaint);

      // Curve label tag on right margin with plenty of vertical spacing
      final icEnd = ((BjtPhysics.nominalBeta * curveIb) / 1000.0) * (1.0 + xMax / BjtPhysics.earlyVoltageVa);
      final tagY = bottomMargin - (math.min(yMax - 0.2, icEnd) / yMax) * graphHeight;

      String tagLabel;
      if (curveIb == 4.3) {
        tagLabel = 'IB=4.3µA (1MΩ)';
      } else if (curveIb == 10.0) {
        tagLabel = 'IB=10µA (470kΩ)';
      } else {
        tagLabel = 'IB=${curveIb.toInt()}µA';
      }

      _drawText(
        canvas,
        tagLabel,
        Offset(rightMargin - 75, tagY - 6),
        TextStyle(
          color: isCurrent
              ? const Color(0xff67d7b4)
              : isLabCurve
                  ? const Color(0xff88c7b0)
                  : const Color(0xff527299),
          fontSize: 8.5,
          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
          backgroundColor: const Color(0xcc10262b),
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

    // Q-point badge (clamped safely within graph bounds)
    final badgeText = 'Q: ${currentVce.toStringAsFixed(1)}V, ${currentIcMa.toStringAsFixed(2)}mA';
    const badgeWidth = 118.0;
    const badgeHeight = 18.0;
    double badgeX = (qX > rightMargin - 125) ? qX - 130 : qX + 12;
    double badgeY = (qY < topMargin + 25) ? qY + 12 : qY - 24;
    badgeX = badgeX.clamp(leftMargin + 4, rightMargin - badgeWidth);
    badgeY = badgeY.clamp(topMargin + 4, bottomMargin - badgeHeight);

    final badgeRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(badgeX, badgeY, badgeWidth, badgeHeight),
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
