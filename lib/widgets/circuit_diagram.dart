import 'package:flutter/material.dart';
import '../models/bjt_physics.dart';

class CircuitDiagramWidget extends StatelessWidget {
  final bool isInputMode;
  final double v1; // V1: Vbb (0-5V) in Input mode, or 5V in Output mode
  final double v2; // V2: Vce (1V, 2V) in Input mode, or Vcc (0-15V) in Output mode
  final double vbe; // V
  final double vce; // V
  final double ibMa; // mA
  final double ibUa; // uA
  final double icMa; // mA
  final BaseResistorOption baseResistor;

  const CircuitDiagramWidget({
    super.key,
    required this.isInputMode,
    required this.v1,
    required this.v2,
    required this.vbe,
    required this.vce,
    required this.ibMa,
    required this.ibUa,
    required this.icMa,
    required this.baseResistor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff17140c),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xff3d3216)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isInputMode
                      ? const Color(0xfffacc15).withValues(alpha: 0.15)
                      : const Color(0xfff59e0b).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.schema_rounded,
                  color: isInputMode ? const Color(0xfffacc15) : const Color(0xfff59e0b),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isInputMode
                          ? 'Input Characteristics Circuit Diagram'
                          : 'Output Characteristics Circuit Diagram',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
                    ),
                    Text(
                      isInputMode
                          ? 'Lab Manual Image 2  ·  V1 (0-5V DC), R1 (1k), Q1 (BC547), V2 (1V, 2V)'
                          : 'Lab Manual Image 3  ·  V1 (5V DC), R1 (470k/1M), Q1 (BC547), R2 (1k), V2 (0-15V)',
                      style: const TextStyle(fontSize: 10, color: Color(0xffbaa87e)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Custom Painted Schematic
          SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(
              painter: _LabCircuitPainter(
                isInputMode: isInputMode,
                v1: v1,
                v2: v2,
                vbe: vbe,
                vce: vce,
                ibMa: ibMa,
                icMa: icMa,
                baseResistor: baseResistor,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Live Meter Readings Summary
          Row(
            children: [
              _meterBadge(
                title: 'Ammeter (IB)',
                reading: isInputMode
                    ? '${ibMa.toStringAsFixed(2)} mA  (${ibUa.toStringAsFixed(0)} µA)'
                    : '${ibUa.toStringAsFixed(1)} µA',
                color: const Color(0xfff6ad55),
              ),
              const SizedBox(width: 8),
              _meterBadge(
                title: 'Voltmeter (VBE)',
                reading: '${vbe.toStringAsFixed(2)} V',
                color: const Color(0xffe6a23c),
              ),
              const SizedBox(width: 8),
              _meterBadge(
                title: 'Voltmeter (VCE)',
                reading: '${vce.toStringAsFixed(2)} V',
                color: const Color(0xff67d7b4),
              ),
              if (!isInputMode) ...[
                const SizedBox(width: 8),
                _meterBadge(
                  title: 'Ammeter (IC)',
                  reading: '${icMa.toStringAsFixed(2)} mA',
                  color: const Color(0xff48c79c),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _meterBadge({required String title, required String reading, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        decoration: BoxDecoration(
          color: const Color(0xff1e1a12),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: const TextStyle(fontSize: 8.5, color: Color(0xffbaa87e))),
            const SizedBox(height: 3),
            Text(
              reading,
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _LabCircuitPainter extends CustomPainter {
  final bool isInputMode;
  final double v1;
  final double v2;
  final double vbe;
  final double vce;
  final double ibMa;
  final double icMa;
  final BaseResistorOption baseResistor;

  _LabCircuitPainter({
    required this.isInputMode,
    required this.v1,
    required this.v2,
    required this.vbe,
    required this.vce,
    required this.ibMa,
    required this.icMa,
    required this.baseResistor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = const Color(0xff476288)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final componentPaint = Paint()
      ..color = const Color(0xff8cb2ea)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final midX = size.width * 0.50;
    final midY = size.height * 0.50;
    final leftX = size.width * 0.08;
    final rightX = size.width * 0.92;
    final topY = midY - 60;
    final bottomY = midY + 65;

    // --- BC547 TRANSISTOR (Q1) AT CENTER ---
    const bjtRadius = 22.0;
    final bjtBg = Paint()..color = const Color(0xff182c4c);
    canvas.drawCircle(Offset(midX, midY), bjtRadius, bjtBg);

    final bjtBorder = Paint()
      ..color = const Color(0xff45679c)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(Offset(midX, midY), bjtRadius, bjtBorder);

    // Base vertical bar
    canvas.drawLine(Offset(midX - 6, midY - 12), Offset(midX - 6, midY + 12), componentPaint);

    // Collector lead (top)
    canvas.drawLine(Offset(midX - 6, midY - 6), Offset(midX + 10, midY - 14), componentPaint);
    canvas.drawLine(Offset(midX + 10, midY - 14), Offset(midX + 10, topY), wirePaint);

    // Emitter lead (bottom)
    canvas.drawLine(Offset(midX - 6, midY + 6), Offset(midX + 10, midY + 14), componentPaint);
    canvas.drawLine(Offset(midX + 10, midY + 14), Offset(midX + 10, bottomY), wirePaint);

    // Emitter arrow (pointing downwards / outwards for NPN BC547)
    final arrowPaint = Paint()
      ..color = const Color(0xff67d7b4)
      ..style = PaintingStyle.fill;
    final arrowPath = Path()
      ..moveTo(midX + 9, midY + 14)
      ..lineTo(midX + 3, midY + 15)
      ..lineTo(midX + 6, midY + 10)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint);

    // Transistor Label: Q1 BC547
    _drawText(
      canvas,
      'Q1\nBC547',
      Offset(midX + 16, midY - 10),
      const TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Color(0xffadc6ec)),
    );

    // Base horizontal connection to the left
    canvas.drawLine(Offset(midX - 6, midY), Offset(midX - 25, midY), wirePaint);

    // Common Bottom Emitter Rail
    canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, bottomY), wirePaint);

    // ==========================================
    // DIAGRAM 1: INPUT CHARACTERISTICS (Image 2)
    // ==========================================
    if (isInputMode) {
      // Connect base to top loop
      canvas.drawLine(Offset(midX - 25, midY), Offset(midX - 25, topY), wirePaint);
      canvas.drawLine(Offset(midX - 25, topY), Offset(leftX, topY), wirePaint);

      // Ammeter in base branch: (+) mA (-)
      final meterX = midX - 60;
      _drawAmmeter(
        canvas: canvas,
        center: Offset(meterX, topY),
        unit: 'mA',
        plusOnLeft: true,
        color: const Color(0xfff6ad55),
      );

      // Resistor R1 = 1K
      final r1X = midX - 110;
      _drawResistor(canvas: canvas, center: Offset(r1X, topY), label: 'R1\n1K');

      // Variable Power Supply V1 (0-5V DC) on left
      canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), wirePaint);
      _drawBattery(
        canvas: canvas,
        center: Offset(leftX, midY),
        label: 'V1\n0-5V DC',
        isVariable: true,
      );

      // Voltmeter V across Base and Emitter
      _drawVoltmeter(
        canvas: canvas,
        from: Offset(midX - 25, midY),
        to: Offset(midX - 25, bottomY),
        center: Offset(midX - 25, midY + 32),
        label: 'V',
        subLabel: 'VBE',
        color: const Color(0xffe6a23c),
      );

      // Right: DC Supply V2 (1V, 2V) across Collector and Emitter
      canvas.drawLine(Offset(midX + 10, topY), Offset(rightX, topY), wirePaint);
      canvas.drawLine(Offset(rightX, topY), Offset(rightX, bottomY), wirePaint);
      _drawBattery(
        canvas: canvas,
        center: Offset(rightX, midY),
        label: 'V2\n1V, 2V',
        isVariable: false,
      );
    }
    // ===========================================
    // DIAGRAM 2: OUTPUT CHARACTERISTICS (Image 3)
    // ===========================================
    else {
      // Fixed Base Supply V1 (5V DC) on left
      canvas.drawLine(Offset(midX - 25, midY), Offset(leftX, midY), wirePaint);
      canvas.drawLine(Offset(leftX, midY), Offset(leftX, bottomY), wirePaint);

      // Resistor R1 = 470K, 1M
      final r1X = (leftX + midX - 25) / 2;
      _drawResistor(
        canvas: canvas,
        center: Offset(r1X, midY),
        label: baseResistor == BaseResistorOption.oneMega ? 'R1: 1M\n(4.3µA)' : 'R1: 470K\n(10µA)',
        highlightColor: const Color(0xfff6ad55),
      );

      // Fixed Battery V1 = 5V DC
      _drawBattery(
        canvas: canvas,
        center: Offset(leftX, midY + 32),
        label: 'V1\n5V DC',
        isVariable: false,
      );

      // Top collector branch to right
      canvas.drawLine(Offset(midX + 10, topY), Offset(rightX, topY), wirePaint);

      // Collector Ammeter: (-) mA (+)
      final meterX = midX + 55;
      _drawAmmeter(
        canvas: canvas,
        center: Offset(meterX, topY),
        unit: 'mA',
        plusOnLeft: false, // (-) on left, (+) on right as in Image 3
        color: const Color(0xff67d7b4),
      );

      // Resistor R2 = 1K
      final r2X = midX + 105;
      _drawResistor(canvas: canvas, center: Offset(r2X, topY), label: 'R2\n1K');

      // Variable Power Supply V2 (0-15V DC) on right
      canvas.drawLine(Offset(rightX, topY), Offset(rightX, bottomY), wirePaint);
      _drawBattery(
        canvas: canvas,
        center: Offset(rightX, midY),
        label: 'V2\n0-15V DC',
        isVariable: true,
      );

      // Voltmeter V across Collector and Emitter (VCE)
      _drawVoltmeter(
        canvas: canvas,
        from: Offset(midX + 25, topY),
        to: Offset(midX + 25, bottomY),
        center: Offset(midX + 25, midY + 12),
        label: 'V',
        subLabel: 'VCE',
        color: const Color(0xff67d7b4),
      );
    }
  }

  void _drawAmmeter({
    required Canvas canvas,
    required Offset center,
    required String unit,
    required bool plusOnLeft,
    required Color color,
  }) {
    final meterPaint = Paint()
      ..color = const Color(0xff0a1626)
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawCircle(center, 12, meterPaint);
    canvas.drawCircle(center, 12, ringPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: unit,
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));

    // Polarities (+) and (-)
    final plusText = plusOnLeft ? '+' : '-';
    final minusText = plusOnLeft ? '-' : '+';
    _drawText(
      canvas,
      plusText,
      Offset(center.dx - 18, center.dy - 12),
      TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
    );
    _drawText(
      canvas,
      minusText,
      Offset(center.dx + 13, center.dy - 12),
      TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
    );
  }

  void _drawVoltmeter({
    required Canvas canvas,
    required Offset from,
    required Offset to,
    required Offset center,
    required String label,
    required String subLabel,
    required Color color,
  }) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, Offset(center.dx, from.dy), linePaint);
    canvas.drawLine(Offset(center.dx, from.dy), Offset(center.dx, center.dy - 11), linePaint);
    canvas.drawLine(Offset(center.dx, center.dy + 11), Offset(center.dx, to.dy), linePaint);
    canvas.drawLine(Offset(center.dx, to.dy), to, linePaint);

    final vPaint = Paint()
      ..color = const Color(0xff0a1626)
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    canvas.drawCircle(center, 11, vPaint);
    canvas.drawCircle(center, 11, ringPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));

    // Sublabel (e.g. VBE or VCE)
    _drawText(
      canvas,
      subLabel,
      Offset(center.dx + 13, center.dy - 5),
      TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: color),
    );

    // Polarity (+) on top, (-) on bottom
    _drawText(
      canvas,
      '+',
      Offset(center.dx + 3, center.dy - 20),
      TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
    );
    _drawText(
      canvas,
      '-',
      Offset(center.dx + 4, center.dy + 12),
      TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
    );
  }

  void _drawResistor({
    required Canvas canvas,
    required Offset center,
    required String label,
    Color? highlightColor,
  }) {
    final rPaint = Paint()
      ..color = highlightColor ?? const Color(0xff88a8d6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    const w = 18.0;
    const h = 9.0;
    final rect = Rect.fromCenter(center: center, width: w, height: h);
    final fillPaint = Paint()..color = const Color(0xff0a1626);
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, rPaint);

    _drawText(
      canvas,
      label,
      Offset(center.dx - 18, center.dy - 24),
      TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.bold,
        color: highlightColor ?? const Color(0xff99b9e6),
      ),
    );
  }

  void _drawBattery({
    required Canvas canvas,
    required Offset center,
    required String label,
    required bool isVariable,
  }) {
    final bPaint = Paint()
      ..color = const Color(0xff8bb2e8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // Long plate (+)
    canvas.drawLine(Offset(center.dx - 10, center.dy - 4), Offset(center.dx + 10, center.dy - 4), bPaint);
    // Short thick plate (-)
    final bThick = Paint()
      ..color = const Color(0xff8bb2e8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawLine(Offset(center.dx - 6, center.dy + 4), Offset(center.dx + 6, center.dy + 4), bThick);

    // Polarity signs
    _drawText(
      canvas,
      '+',
      Offset(center.dx - 16, center.dy - 10),
      const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xff8bb2e8)),
    );
    _drawText(
      canvas,
      '-',
      Offset(center.dx - 15, center.dy + 2),
      const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xff8bb2e8)),
    );

    // Diagonal variable arrow if variable DC power supply
    if (isVariable) {
      final arrowPaint = Paint()
        ..color = const Color(0xfff6ad55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3;
      canvas.drawLine(Offset(center.dx - 11, center.dy + 12), Offset(center.dx + 11, center.dy - 12), arrowPaint);
    }

    _drawText(
      canvas,
      label,
      Offset(center.dx - 22, center.dy + 15),
      const TextStyle(fontSize: 7.5, color: Color(0xff9ab4dc), fontWeight: FontWeight.bold),
    );
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _LabCircuitPainter oldDelegate) {
    return oldDelegate.isInputMode != isInputMode ||
        oldDelegate.v1 != v1 ||
        oldDelegate.v2 != v2 ||
        oldDelegate.vbe != vbe ||
        oldDelegate.vce != vce ||
        oldDelegate.ibMa != ibMa ||
        oldDelegate.icMa != icMa ||
        oldDelegate.baseResistor != baseResistor;
  }
}
