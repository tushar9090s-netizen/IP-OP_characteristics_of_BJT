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
      ..color = const Color(0xff1e293b)
      ..strokeWidth = 0.8;

    final axisPaint = Paint()
      ..color = const Color(0xff334155)
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
        const TextStyle(color: Color(0xff94a3b8), fontSize: 10, fontWeight: FontWeight.w600),
      );
    }

    // X-axis grid lines and ticks (VBE: 0.0 to 1.0 V for focused conduction view)
    const xMax = 1.0; // V (was 1.2V)
    const xSteps = 5;
    for (int i = 0; i <= xSteps; i++) {
      final x = leftMargin + (graphWidth * i / xSteps);
      canvas.drawLine(Offset(x, topMargin), Offset(x, bottomMargin), gridPaint);

      final voltageVal = (i * 0.2).toStringAsFixed(1);
      _drawText(
        canvas,
        voltageVal,
        Offset(x - 8, bottomMargin + 8),
        const TextStyle(color: Color(0xff94a3b8), fontSize: 10, fontWeight: FontWeight.w600),
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
      const TextStyle(color: Color(0xff38bdf8), fontSize: 11, fontWeight: FontWeight.w700),
    );
    _drawText(
      canvas,
      'VBE (V) →',
      Offset(rightMargin - 46, bottomMargin + 14),
      const TextStyle(color: Color(0xff38bdf8), fontSize: 11, fontWeight: FontWeight.w700),
    );

    // Cut-in reference line (0.65 - 0.7 V)
    const kneeV = 0.68;
    final kneeX = leftMargin + (kneeV / xMax) * graphWidth;
    final kneePaint = Paint()
      ..color = const Color(0xff38bdf8).withValues(alpha: 0.35)
      ..strokeWidth = 1.2;
    _drawDashedLine(canvas, Offset(kneeX, topMargin + 25), Offset(kneeX, bottomMargin), kneePaint);
    _drawText(
      canvas,
      'Cut-in ≈ 0.7V',
      Offset(kneeX - 25, topMargin + 10),
      const TextStyle(
        color: Color(0xff7dd3fc),
        fontSize: 9.5,
        fontWeight: FontWeight.w600,
        backgroundColor: Color(0xdd0f172a),
      ),
    );

    // Family of VCE curves: VCE = 1V and VCE = 2V (from Experiment 5)
    for (final curveVce in [1.0, 2.0]) {
      final isCurrent = (selectedVce - curveVce).abs() < 0.5;
      final path = Path();

      // Sample 70 points from VBB = 0 to 5.5 V.
      final points = <Offset>[];
      for (int step = 0; step <= 70; step++) {
        final stepVbb = step * (5.5 / 70);
        final res = BjtPhysics.solveInputCircuit(vbb: stepVbb, vce: curveVce);
        final vbeVal = res['vbe']!;
        final ibVal = res['ibMa']!;

        final x = leftMargin + (math.min(xMax, vbeVal) / xMax) * graphWidth;
        final clampedIb = math.min(yMax, ibVal);
        final y = bottomMargin - (clampedIb / yMax) * graphHeight;

        points.add(Offset(x, y));
      }

      // Catmull-Rom control points keep the plotted samples smooth without
      // changing their values or the graph's axis scaling.
      if (points.isNotEmpty) {
        path.moveTo(points.first.dx, points.first.dy);
      }
      for (int i = 0; i < points.length - 1; i++) {
        final previous = points[i == 0 ? 0 : i - 1];
        final current = points[i];
        final next = points[i + 1];
        final following = points[i + 2 < points.length ? i + 2 : points.length - 1];

        final control1 = Offset(
          current.dx + (next.dx - previous.dx) / 6,
          current.dy + (next.dy - previous.dy) / 6,
        );
        final control2 = Offset(
          next.dx - (following.dx - current.dx) / 6,
          next.dy - (following.dy - current.dy) / 6,
        );
        path.cubicTo(
          control1.dx,
          control1.dy,
          control2.dx,
          control2.dy,
          next.dx,
          next.dy,
        );
      }

      final curvePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      if (isCurrent) {
        curvePaint
          ..color = const Color(0xff38bdf8)
          ..strokeWidth = 2.8;

        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..color = const Color(0xff38bdf8).withValues(alpha: 0.25)
          ..strokeWidth = 6.0;
        canvas.drawPath(path, glowPaint);
      } else {
        curvePaint
          ..color = const Color(0xff475569)
          ..strokeWidth = 1.4;
      }

      canvas.drawPath(path, curvePaint);

      // Curve label tag with clean visual separation between VCE=1V and VCE=2V
      final endRes = BjtPhysics.solveInputCircuit(vbb: 5.0, vce: curveVce);
      final tagY = bottomMargin - (math.min(yMax - 0.3, endRes['ibMa']!) / yMax) * graphHeight;
      final tagX = leftMargin + (math.min(xMax - 0.05, endRes['vbe']!) / xMax) * graphWidth;

      final isVce1 = (curveVce == 1.0);
      final labelOffset = isVce1
          ? Offset(tagX - 58, tagY - 18)
          : Offset(tagX + 8, tagY + 12);

      _drawText(
        canvas,
        'VCE = ${curveVce.toInt()}V',
        labelOffset,
        TextStyle(
          color: isCurrent ? const Color(0xff38bdf8) : const Color(0xff64748b),
          fontSize: 9.5,
          fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
          backgroundColor: const Color(0xdd0f172a),
        ),
      );
    }

    // Operating point (Q-point) on the current curve
    final qX = leftMargin + (math.min(xMax, currentVbe) / xMax) * graphWidth;
    final clampedIb = math.min(yMax, currentIbMa);
    final qY = bottomMargin - (clampedIb / yMax) * graphHeight;

    // Crosshairs
    final crosshairPaint = Paint()
      ..color = const Color(0xff38bdf8).withValues(alpha: 0.4)
      ..strokeWidth = 1.0;
    _drawDashedLine(canvas, Offset(leftMargin, qY), Offset(qX, qY), crosshairPaint);
    _drawDashedLine(canvas, Offset(qX, bottomMargin), Offset(qX, qY), crosshairPaint);

    // Q-point dot
    final qGlow = Paint()
      ..color = const Color(0xff38bdf8).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(qX, qY), 9, qGlow);

    final qDot = Paint()
      ..color = const Color(0xffffffff)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(qX, qY), 4.5, qDot);

    final qRing = Paint()
      ..color = const Color(0xff0284c7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    canvas.drawCircle(Offset(qX, qY), 4.5, qRing);

    // Badge with coordinates
    final badgeText = 'Q: ${currentVbe.toStringAsFixed(3)}V, ${currentIbMa.toStringAsFixed(2)}mA';
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
    canvas.drawRRect(badgeRRect, Paint()..color = const Color(0xee0f172a));
    canvas.drawRRect(
      badgeRRect,
      Paint()
        ..color = const Color(0xff38bdf8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    _drawText(
      canvas,
      badgeText,
      Offset(badgeX + 5, badgeY + 3.5),
      const TextStyle(color: Color(0xff38bdf8), fontSize: 9, fontWeight: FontWeight.bold),
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
