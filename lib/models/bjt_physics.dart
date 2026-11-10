import 'dart:math' as math;

enum BaseResistorOption {
  oneMega('1 MΩ', 1000000.0, 4.3),
  fourSeventyK('470 kΩ', 470000.0, 10.0);

  const BaseResistorOption(this.label, this.resistanceOhms, this.nominalIbUa);
  final String label;
  final double resistanceOhms;
  final double nominalIbUa;
}

class InputLabReading {
  final double vbb; // V
  final double vce; // 1V or 2V
  final double ibMa; // mA
  final double ibUa; // uA
  final double vbe; // V

  const InputLabReading({
    required this.vbb,
    required this.vce,
    required this.ibMa,
    required this.ibUa,
    required this.vbe,
  });
}

class OutputLabReading {
  final double vcc; // V
  final double ibUa; // 4.3uA or 10uA
  final double vce; // V
  final double icMa; // mA

  const OutputLabReading({
    required this.vcc,
    required this.ibUa,
    required this.vce,
    required this.icMa,
  });
}

class BjtPhysics {
  // BC547 NPN Transistor specifications
  static const String transistorModel = 'BC547';
  static const double earlyVoltageVa = 100.0; // Early Voltage (V)
  static const double nominalBeta = 230.0; // Typical hFE for BC547 (200 - 300)
  static const double vCutIn = 0.65; // Cut-in / Knee voltage for Silicon (V)
  static const double inputR1Ohms = 1000.0; // 1k Ohm series resistor in Input circuit
  static const double outputR2Ohms = 1000.0; // 1k Ohm collector load resistor in Output circuit

  /// Solves the input circuit:
  /// Vbb = IB * R1 + VBE
  /// where Base-Emitter behaves as a silicon diode:
  /// IB = IS * (exp((VBE - vceShift) / Vt) - 1)
  /// Returns { 'vbe': double, 'ibMa': double, 'ibUa': double }
  static Map<String, double> solveInputCircuit({
    required double vbb,
    required double vce, // 1.0 or 2.0 V
  }) {
    // Early effect shift: at Vce = 2V, base width narrows, knee shifts right (~0.055V visible distinction)
    final vceShift = 0.055 * (vce - 1.0);

    if (vbb <= 0.0) {
      return {'vbe': 0.0, 'ibMa': 0.0, 'ibUa': 0.0};
    }

    if (vbb < vCutIn + vceShift) {
      // Below cut-in: tiny leakage, almost all Vbb appears across base-emitter
      final leakageUa = 0.05 * math.exp((vbb - (vCutIn + vceShift)) / 0.04);
      final vbe = vbb;
      return {
        'vbe': double.parse(vbe.toStringAsFixed(3)),
        'ibMa': double.parse((leakageUa / 1000).toStringAsFixed(4)),
        'ibUa': double.parse(leakageUa.toStringAsFixed(2)),
      };
    }

    // Above cut-in: diode turns on.
    // Iterative solution for Vbe: Vbe = Vgamma + Vt * ln(1 + IB/IS) with R1 = 1k
    // Closed form approximation for 1k resistor & BC547:
    // When Vbb increases, Vbe gently increases from 0.66V to ~0.78V while IB = (Vbb - Vbe)/1k
    final vOver = vbb - (vCutIn + vceShift);
    final deltaVbe = 0.075 * math.log(1.0 + 8.0 * vOver) / math.log(10.0);
    final vbe = (vCutIn + vceShift) + deltaVbe;
    final clampedVbe = math.min(vbb, math.min(0.82, vbe));

    // IB = (Vbb - VBE) / R1 (in mA, since R1 = 1k)
    final ibMa = (vbb - clampedVbe) / (inputR1Ohms / 1000.0);
    final ibUa = ibMa * 1000.0;

    return {
      'vbe': clampedVbe,
      'ibMa': ibMa,
      'ibUa': ibUa,
    };
  }

  /// Calculates Dynamic Input Resistance: ri = dVbe / dIb (in Ohms)
  static double calculateDynamicInputResistance({
    required double vbb,
    required double vce,
  }) {
    const deltaV = 0.02;
    final r1 = solveInputCircuit(vbb: math.max(0.0, vbb - deltaV), vce: vce);
    final r2 = solveInputCircuit(vbb: vbb + deltaV, vce: vce);

    final dVbe = r2['vbe']! - r1['vbe']!;
    final dIbA = (r2['ibMa']! - r1['ibMa']!) * 1e-3;

    if (dIbA <= 1e-7) return 999999.0;
    return dVbe / dIbA;
  }

  /// Solves the output circuit:
  /// V1 = 5V DC fixed, R1 = 1M (4.3uA) or 470k (10uA)
  /// Output loop: VCC = IC * R2 + VCE (R2 = 1k)
  /// Returns { 'vce': double, 'icMa': double }
  static Map<String, double> solveOutputCircuit({
    required double vcc, // 0 to 15 V
    required double ibUa, // 4.3 uA or 10.0 uA
    double beta = nominalBeta,
  }) {
    if (vcc <= 0.0) {
      return {'vce': 0.0, 'icMa': 0.0};
    }

    // Target active collector current: IC_active = beta * IB
    final icActiveMa = (beta * ibUa) / 1000.0;

    // Load line: VCC = IC * R2 + VCE (R2 = 1k => IC in mA)
    // In saturation (low VCC), IC is limited by VCC / R2:
    // IC = min(IC_active * (1 - exp(-Vce/0.25)) * (1 + Vce/Va), VCC / R2)
    // We solve for operating point:
    double vceEst = 0.2;
    double icEst = 0.0;

    if (vcc < icActiveMa) {
      // Saturation region: transistor cannot pull more than external circuit supplies
      vceEst = 0.12 + 0.08 * (vcc / (icActiveMa + 0.1));
      icEst = math.max(0.0, (vcc - vceEst) / (outputR2Ohms / 1000.0));
    } else {
      // Active region: IC is determined by beta * IB with slight Early voltage slope
      vceEst = vcc - (icActiveMa * (outputR2Ohms / 1000.0));
      if (vceEst < 0.2) {
        vceEst = 0.2;
      }
      final earlyFactor = 1.0 + (vceEst / earlyVoltageVa);
      icEst = icActiveMa * earlyFactor;
      // Re-calculate actual Vce with collector resistor drop
      vceEst = math.max(0.2, vcc - (icEst * (outputR2Ohms / 1000.0)));
    }

    return {
      'vce': double.parse(vceEst.toStringAsFixed(2)),
      'icMa': double.parse(icEst.toStringAsFixed(2)),
    };
  }

  /// Calculates Dynamic Output Resistance: ro = dVce / dIc (in Ohms)
  static double calculateDynamicOutputResistance({
    required double vcc,
    required double ibUa,
  }) {
    const deltaV = 0.1;
    final r1 = solveOutputCircuit(vcc: math.max(0.0, vcc - deltaV), ibUa: ibUa);
    final r2 = solveOutputCircuit(vcc: vcc + deltaV, ibUa: ibUa);

    final dVce = r2['vce']! - r1['vce']!;
    final dIcA = (r2['icMa']! - r1['icMa']!) * 1e-3;

    if (dIcA <= 1e-7) return 999999.0;
    return dVce / dIcA;
  }

  /// DC Beta: beta_dc = IC / IB
  static double calculateBetaDc({required double icMa, required double ibUa}) {
    if (ibUa <= 0.01) return 0.0;
    return (icMa * 1000.0) / ibUa;
  }

  /// AC Beta: beta_ac = (ΔIC / ΔIB) at constant VCE
  /// Evaluated by comparing output curves at two nearby IB values
  static double calculateBetaAc({
    required double vcc,
    required double ibUa,
  }) {
    final deltaIb = 1.0; // 1 µA perturbation
    final ib1 = math.max(0.1, ibUa - deltaIb);
    final ib2 = ibUa + deltaIb;

    final sol1 = solveOutputCircuit(vcc: vcc, ibUa: ib1);
    final sol2 = solveOutputCircuit(vcc: vcc, ibUa: ib2);

    final dIcMa = sol2['icMa']! - sol1['icMa']!;
    final dIbUa = ib2 - ib1;

    if (dIbUa <= 0.0) return 0.0;
    // ΔIC (in µA) / ΔIB (in µA) = ΔIC_mA * 1000 / ΔIB_µA
    return (dIcMa * 1000.0) / dIbUa;
  }

  /// Generates the complete standard Result Table for Input Characteristics (Page 2)
  /// Vbb = 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5 V for VCE = 1V and VCE = 2V
  static List<InputLabReading> generateStandardInputTable({required double vce}) {
    const vbbSteps = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];
    return vbbSteps.map((vbb) {
      final res = solveInputCircuit(vbb: vbb, vce: vce);
      return InputLabReading(
        vbb: vbb,
        vce: vce,
        ibMa: res['ibMa']!,
        ibUa: res['ibUa']!,
        vbe: res['vbe']!,
      );
    }).toList();
  }

  /// Generates the complete standard Result Table for Output Characteristics (Page 3 & 4)
  /// Vcc = 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 V for IB = 10uA (470k) and IB = 4.3uA (1M)
  static List<OutputLabReading> generateStandardOutputTable({required double ibUa}) {
    const vccSteps = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
    return vccSteps.map((vcc) {
      final res = solveOutputCircuit(vcc: vcc, ibUa: ibUa);
      return OutputLabReading(
        vcc: vcc,
        ibUa: ibUa,
        vce: res['vce']!,
        icMa: res['icMa']!,
      );
    }).toList();
  }
}
