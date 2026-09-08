import 'package:flutter/material.dart';

class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        // Lab Header
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff183260), Color(0xff12213e)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xff2d4c82)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xff2955b5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'EXPERIMENT 5',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 1.5),
                    ),
                  ),
                  const Spacer(),
                  const Text('ECE Laboratory Manual', style: TextStyle(color: Color(0xff92b4f2), fontSize: 11)),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Input and Output Characteristics of BJT',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              const SizedBox(height: 6),
              const Text(
                'Study of NPN Transistor (BC547) in Common Emitter (CE) Configuration',
                style: TextStyle(fontSize: 12.5, color: Color(0xffb7ccee)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Section 1: Objective, Equipments, Components
        _sectionCard(
          title: 'Objective & Apparatus',
          icon: Icons.checklist_rounded,
          accentColor: const Color(0xff88aaff),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Objective:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 6),
              _bulletPoint('1. Design the circuit diagram.'),
              _bulletPoint('2. Take the reading and draw the characteristics curve.'),
              _bulletPoint('3. Determine the input and output resistance.'),
              const Divider(color: Color(0xff233554), height: 20),
              const Text(
                'Equipment\'s Required:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 6),
              _bulletPoint('1) Voltmeter\n2) Ammeter\n3) Bread Board\n4) 0 - 30 V DC power supply'),
              const SizedBox(height: 10),
              const Text(
                'Components Required:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 6),
              _bulletPoint('1) Resistors: 1kΩ, 470kΩ, 1MΩ\n2) Transistor: (BC547 NPN)'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section 2: Theory
        _sectionCard(
          title: 'Theory',
          icon: Icons.menu_book_rounded,
          accentColor: const Color(0xfff6ad55),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'A BJT is a three terminal electronic device consisting of either two n-type or one p-type layers of material or two p-type and one n-type layers of material. The former is called an NPN transistor and the latter is called PNP transistor. The three terminals are Emitter (E), Collector (C) and Base (B).\n\n'
                'The Common Emitter (CE) configuration is most frequently encountered configuration. In this the emitter is common or reference to both the input and output terminals (in this case common to both the base and collector terminals). Two sets of characteristics are necessary to describe fully the behavior of the CE configuration: input and output characteristics.\n\n'
                '• Input characteristics: The plot of base current IB versus the voltage VBE across its base and emitter for different values of voltage, VCE.\n\n'
                '• Output characteristics: The plot of collector current IC versus the voltage VCE across its collector and emitter for different values of base current IB.',
                style: TextStyle(color: Color(0xffb5c7e6), fontSize: 12.8, height: 1.45),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xff0b1526),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xff1d3356)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Current Gain Definitions (From Manual):', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xff88aaff), fontSize: 12)),
                    const SizedBox(height: 8),
                    _mathRow('DC Mode Current Gain:', 'βdc = IC / IB'),
                    const SizedBox(height: 6),
                    _mathRow('AC Current Gain:', 'βac = (ΔIC / ΔIB) | VCE = constant'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section 3: Procedures
        _sectionCard(
          title: 'Laboratory Procedures',
          icon: Icons.format_list_numbered_rounded,
          accentColor: const Color(0xff67d7b4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _procedureBlock(
                title: 'Procedure: Input Characteristics (Image 2)',
                steps: [
                  '1. Set up the circuit as shown in the diagram (V1 = 0-5V DC, R1 = 1k, ammeter in series, voltmeter across base-emitter, V2 = 1V, 2V).',
                  '2. VCE (V2) is set at 1V.',
                  '3. Vary the input voltage V1 in steps of 0.5V (from 0V to 5V) and note the corresponding IB and Vbe.',
                  '4. Repeat for VCE (V2) = 2V.',
                  '5. Plot the input characteristics curve with VBE on x-axis and IB on y-axis.',
                ],
                color: const Color(0xfff6ad55),
              ),
              const SizedBox(height: 14),
              _procedureBlock(
                title: 'Procedure: Output Characteristics (Image 3)',
                steps: [
                  '1. Set up the circuit as shown in the diagram (V1 = 5V DC, Q1 = BC547, R2 = 1k, ammeter in collector, V2 = 0-15V DC).',
                  '2. R1 is taken 1M ohm so that IB is set at 4.3µA.',
                  '3. Vary VCC (V2) in steps of 1V (from 1V to 10V) and note the corresponding IC & VCE.',
                  '4. Repeat for IB = 10µA, by replacing R1 by 470 kilo Ohm.',
                  '5. Plot the output characteristics curve with VCE on x-axis and IC on y-axis.',
                ],
                color: const Color(0xff67d7b4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Section 4: Formula & Calculations
        _sectionCard(
          title: 'Formulas for Determining Resistance',
          icon: Icons.calculate_rounded,
          accentColor: const Color(0xffb799f2),
          child: Column(
            children: [
              _formulaTile(
                title: 'Dynamic Input Resistance (ri)',
                formula: 'ri = (ΔVBE / ΔIB) | VCE = constant',
                explanation: 'Determined from the inverse slope of the input characteristics curve above the cut-in knee (~0.7V). Typical range: 800 Ω to 3 kΩ for BC547.',
              ),
              const SizedBox(height: 10),
              _formulaTile(
                title: 'Dynamic Output Resistance (ro)',
                formula: 'ro = (ΔVCE / ΔIC) | IB = constant',
                explanation: 'Determined from the slope of the output characteristics curve in the active region. Typical range: 30 kΩ to 100 kΩ.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff101c30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xff233554)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(color: Color(0xffb5c7e6), fontSize: 12.5, height: 1.4),
      ),
    );
  }

  Widget _mathRow(String label, String formula) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xff8ea2c4))),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xff162744),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            formula,
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Color(0xff9cc1ff)),
          ),
        ),
      ],
    );
  }

  Widget _procedureBlock({required String title, required List<String> steps, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff0a1526),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
          const SizedBox(height: 8),
          ...steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(step, style: const TextStyle(color: Color(0xffb5c7e6), fontSize: 12, height: 1.35)),
              )),
        ],
      ),
    );
  }

  Widget _formulaTile({required String title, required String formula, required String explanation}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xff0a1526),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12.5)),
          const SizedBox(height: 4),
          Text(formula, style: const TextStyle(fontFamily: 'Courier', fontWeight: FontWeight.bold, color: Color(0xff88aaff), fontSize: 12)),
          const SizedBox(height: 4),
          Text(explanation, style: const TextStyle(color: Color(0xff8ea2c4), fontSize: 11.5)),
        ],
      ),
    );
  }
}
