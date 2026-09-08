import 'package:flutter/material.dart';
import 'models/bjt_physics.dart';
import 'widgets/input_curve_painter.dart';
import 'widgets/output_curve_painter.dart';
import 'widgets/circuit_diagram.dart';
import 'widgets/observation_table.dart';
import 'screens/learn_tab.dart';
import 'screens/quiz_tab.dart';

void main() => runApp(const BjtLabApp());

class BjtLabApp extends StatelessWidget {
  const BjtLabApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Experiment 5: BJT Characteristics (BC547)',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xff3f6be0),
        brightness: Brightness.dark,
      ),
      fontFamily: 'Arial',
    ),
    home: const LabHome(),
  );
}

class LabHome extends StatefulWidget {
  const LabHome({super.key});

  @override
  State<LabHome> createState() => _LabHomeState();
}

class _LabHomeState extends State<LabHome> {
  int _page = 0;

  // Simulator Parameters aligned with Experiment 5:
  bool _isInputMode = true;

  // Input characteristics parameters:
  double _vbb = 2.0; // V1: 0 to 5 V (steps of 0.5V as in Procedure)
  double _inputVce = 1.0; // V2: 1.0 V or 2.0 V (as in Procedure step 2 & 4)

  // Output characteristics parameters:
  BaseResistorOption _baseResistor = BaseResistorOption.fourSeventyK; // 470k (10uA) or 1M (4.3uA)
  double _vcc = 5.0; // V2: 1 to 15 V (steps of 1V as in Procedure step 3)

  // Progress tracking
  bool _exploredInput = false;
  bool _exploredOutput = false;
  bool _recordedObservation = false;
  int _quizScore = 0;

  double get _progress {
    double p = 0.60; // 60% base
    if (_exploredInput) p += 0.10;
    if (_exploredOutput) p += 0.10;
    if (_recordedObservation) p += 0.10;
    if (_quizScore >= 3) p += 0.10;
    return p.clamp(0.60, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _exploredInput = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff09111f),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xff0d192b),
        indicatorColor: const Color(0xff233d73),
        selectedIndex: _page,
        onDestinationSelected: (value) => setState(() => _page = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          NavigationDestination(
            icon: Icon(Icons.quiz_outlined),
            selectedIcon: Icon(Icons.quiz),
            label: 'Quiz',
          ),
        ],
      ),
      body: SafeArea(
        child: _page == 0
            ? _buildExploreTab()
            : _page == 1
                ? const LearnTab()
                : QuizTab(
                    onQuizCompleted: (score) {
                      setState(() => _quizScore = score);
                    },
                  ),
      ),
    );
  }

  Widget _buildExploreTab() {
    // Current Input Circuit Solution
    final inputSol = BjtPhysics.solveInputCircuit(vbb: _vbb, vce: _inputVce);
    final currentVbe = inputSol['vbe']!;
    final currentIbMa = inputSol['ibMa']!;
    final currentIbUa = inputSol['ibUa']!;

    // Current Output Circuit Solution
    final outputSol = BjtPhysics.solveOutputCircuit(
      vcc: _vcc,
      ibUa: _baseResistor.nominalIbUa,
    );
    final currentOutputVce = outputSol['vce']!;
    final currentIcMa = outputSol['icMa']!;

    // Dynamic resistances
    final dynamicRi = BjtPhysics.calculateDynamicInputResistance(vbb: _vbb, vce: _inputVce);
    final dynamicRo = BjtPhysics.calculateDynamicOutputResistance(
      vcc: _vcc,
      ibUa: _baseResistor.nominalIbUa,
    );
    final betaDc = BjtPhysics.calculateBetaDc(
      icMa: currentIcMa,
      ibUa: _baseResistor.nominalIbUa,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xff2752cf),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.biotech_rounded, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXPERIMENT 5 · BJT LAB',
                    style: TextStyle(
                      letterSpacing: 2.2,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff9cb8eb),
                      fontSize: 10.5,
                    ),
                  ),
                  Text(
                    'Input & Output Characteristics',
                    style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xff182c50),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xff305088)),
              ),
              child: const Text(
                'BC547 (NPN)',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff89b2ff)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Progress Card (Starting at 60%, completing dynamically)
        _buildProgressCard(),
        const SizedBox(height: 20),

        // Characteristics Segmented Mode Selector
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            const Text(
              'CHARACTERISTICS PLOT',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.4,
                color: Color(0xff95a4c5),
                fontWeight: FontWeight.w700,
              ),
            ),
            SegmentedButton<bool>(
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              segments: const [
                ButtonSegment(value: true, label: Text('Input (IB vs VBE)')),
                ButtonSegment(value: false, label: Text('Output (IC vs VCE)')),
              ],
              selected: {_isInputMode},
              onSelectionChanged: (value) {
                setState(() {
                  _isInputMode = value.first;
                  if (_isInputMode) _exploredInput = true;
                  if (!_isInputMode) _exploredOutput = true;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Characteristics Graph Card
        _buildGraphCard(
          currentVbe: currentVbe,
          currentIbMa: currentIbMa,
          currentOutputVce: currentOutputVce,
          currentIcMa: currentIcMa,
          dynamicRi: dynamicRi,
          dynamicRo: dynamicRo,
        ),
        const SizedBox(height: 16),

        // Interactive Lab Controls (Aligned with manual procedure)
        _buildControlsCard(
          currentVbe: currentVbe,
          currentIbMa: currentIbMa,
          currentIbUa: currentIbUa,
          currentOutputVce: currentOutputVce,
          currentIcMa: currentIcMa,
          dynamicRi: dynamicRi,
          dynamicRo: dynamicRo,
          betaDc: betaDc,
        ),
        const SizedBox(height: 20),

        // Schematic matching Image 2 / Image 3
        CircuitDiagramWidget(
          isInputMode: _isInputMode,
          v1: _isInputMode ? _vbb : 5.0,
          v2: _isInputMode ? _inputVce : _vcc,
          vbe: _isInputMode ? currentVbe : 0.70,
          vce: _isInputMode ? _inputVce : currentOutputVce,
          ibMa: _isInputMode ? currentIbMa : (_baseResistor.nominalIbUa / 1000.0),
          ibUa: _isInputMode ? currentIbUa : _baseResistor.nominalIbUa,
          icMa: _isInputMode ? 0.0 : currentIcMa,
          baseResistor: _baseResistor,
        ),
        const SizedBox(height: 20),

        // Result Tables from Experiment 5
        ObservationTableWidget(
          isInputMode: _isInputMode,
          currentVbb: _vbb,
          currentVce: _inputVce,
          currentVcc: _vcc,
          currentIbUa: _isInputMode ? currentIbUa : _baseResistor.nominalIbUa,
          currentIbMa: _isInputMode ? currentIbMa : (_baseResistor.nominalIbUa / 1000.0),
          currentVbe: currentVbe,
          currentIcMa: currentIcMa,
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    final progressPercent = (_progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff162a52), Color(0xff122040)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xff2a487e)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.task_alt_rounded, color: Color(0xff88aaff), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Experiment 5 Completion Status',
                style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13.5),
              ),
              const Spacer(),
              Text(
                '$progressPercent%',
                style: const TextStyle(
                  color: Color(0xff92b2ff),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: const Color(0xff0c1730),
              valueColor: const AlwaysStoppedAnimation(Color(0xff5e88ff)),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _checkBadge('Input Exp (V1, V2)', _exploredInput),
              _checkBadge('Output Exp (470k, 1M)', _exploredOutput),
              _checkBadge('Result Tables Logged', true),
              _checkBadge('Lab Checkpoint Quiz', _quizScore >= 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _checkBadge(String label, bool done) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 13,
          color: done ? const Color(0xff67d7b4) : const Color(0xff5f769d),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: done ? const Color(0xffb5ccf2) : const Color(0xff7084a6),
            fontWeight: done ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildGraphCard({
    required double currentVbe,
    required double currentIbMa,
    required double currentOutputVce,
    required double currentIcMa,
    required double dynamicRi,
    required double dynamicRo,
  }) {
    final rStr = _isInputMode
        ? '${dynamicRi.toStringAsFixed(0)} Ω  (~${(dynamicRi / 1000).toStringAsFixed(2)} kΩ)'
        : '${(dynamicRo / 1000).toStringAsFixed(1)} kΩ';

    return Container(
      height: 330,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xff101c30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff233554)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isInputMode
                          ? 'Input Characteristics (Expected Graph - Image 3)'
                          : 'Output Characteristics (Expected Graph - Image 4)',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isInputMode
                          ? 'IB vs VBE  ·  VCE = ${_inputVce.toInt()}V fixed  ·  ri ≈ $rStr'
                          : 'IC vs VCE  ·  IB = ${_baseResistor.nominalIbUa.toStringAsFixed(1)}µA (${_baseResistor.label})  ·  ro ≈ $rStr',
                      style: const TextStyle(color: Color(0xff9aacca), fontSize: 11),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _isInputMode ? const Color(0x33f6ad55) : const Color(0x3367d7b4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _isInputMode ? 'VCE = ${_inputVce.toInt()}V' : 'R1 = ${_baseResistor.label}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _isInputMode ? const Color(0xfff6ad55) : const Color(0xff67d7b4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ClipRect(
              child: CustomPaint(
                painter: _isInputMode
                    ? InputCurvePainter(
                        selectedVce: _inputVce,
                        currentVbb: _vbb,
                        currentVbe: currentVbe,
                        currentIbMa: currentIbMa,
                      )
                    : OutputCurvePainter(
                        currentVcc: _vcc,
                        currentVce: currentOutputVce,
                        currentIcMa: currentIcMa,
                        selectedIbUa: _baseResistor.nominalIbUa,
                      ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard({
    required double currentVbe,
    required double currentIbMa,
    required double currentIbUa,
    required double currentOutputVce,
    required double currentIcMa,
    required double dynamicRi,
    required double dynamicRo,
    required double betaDc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff101c30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff233554)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: Color(0xff88aaff), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isInputMode
                      ? 'Input Experiment Controls (Procedure Steps 2 & 3)'
                      : 'Output Experiment Controls (Procedure Steps 2, 3 & 4)',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ==============================
          // INPUT CHARACTERISTICS CONTROLS
          // ==============================
          if (_isInputMode) ...[
            // Fixed Vce Setting: 1V vs 2V (Procedure 2 & 4)
            Row(
              children: [
                const Text(
                  'VCE (V2) Setting:',
                  style: TextStyle(color: Color(0xffcbd6ed), fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                SegmentedButton<double>(
                  style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                  segments: const [
                    ButtonSegment(value: 1.0, label: Text('1.0 V (Step 2)')),
                    ButtonSegment(value: 2.0, label: Text('2.0 V (Step 4)')),
                  ],
                  selected: {_inputVce},
                  onSelectionChanged: (v) => setState(() => _inputVce = v.first),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Variable V1 (Vbb) 0 - 5V in 0.5V steps (Procedure 3)
            Row(
              children: [
                const Text(
                  'Input Voltage V1 (Vbb):',
                  style: TextStyle(color: Color(0xffcbd6ed), fontSize: 12.5),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xff1f365c),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_vbb.toStringAsFixed(1)} V  (0.5V steps)',
                    style: const TextStyle(color: Color(0xfff6ad55), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            Slider(
              value: _vbb,
              min: 0.0,
              max: 5.0,
              divisions: 10, // 0.5V increments
              activeColor: const Color(0xfff6ad55),
              inactiveColor: const Color(0xff1d304f),
              label: '${_vbb.toStringAsFixed(1)} V',
              onChanged: (v) => setState(() => _vbb = v),
            ),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 15, color: Color(0xff8ea2c4)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Procedure 3: Vary input voltage V1 in steps of 0.5V from 0V to 5V and observe IB and Vbe.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xff9aacca)),
                  ),
                ),
              ],
            ),
          ]
          // ===============================
          // OUTPUT CHARACTERISTICS CONTROLS
          // ===============================
          else ...[
            // R1 Selection: 1M (4.3uA) vs 470k (10uA) (Procedure 2 & 4)
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                const Text(
                  'Base Resistor R1 Selection:',
                  style: TextStyle(color: Color(0xffcbd6ed), fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                SegmentedButton<BaseResistorOption>(
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: BaseResistorOption.oneMega,
                      label: Text('1 MΩ (4.3µA)'),
                    ),
                    ButtonSegment(
                      value: BaseResistorOption.fourSeventyK,
                      label: Text('470 kΩ (10µA)'),
                    ),
                  ],
                  selected: {_baseResistor},
                  onSelectionChanged: (v) => setState(() => _baseResistor = v.first),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Variable V2 (Vcc) 1 - 10V in 1V steps (Procedure 3)
            Row(
              children: [
                const Text(
                  'Collector Supply V2 (VCC):',
                  style: TextStyle(color: Color(0xffcbd6ed), fontSize: 12.5),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xff183c34),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${_vcc.toStringAsFixed(0)} V  (1V steps)',
                    style: const TextStyle(color: Color(0xff67d7b4), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            Slider(
              value: _vcc,
              min: 1.0,
              max: 10.0,
              divisions: 9, // 1V increments
              activeColor: const Color(0xff67d7b4),
              inactiveColor: const Color(0xff1d304f),
              label: '${_vcc.toStringAsFixed(0)} V',
              onChanged: (v) => setState(() => _vcc = v),
            ),
            const Row(
              children: [
                Icon(Icons.info_outline, size: 15, color: Color(0xff8ea2c4)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Procedure 3: Vary VCC in steps of 1V from 1V to 10V and note the corresponding IC & VCE.',
                    style: TextStyle(fontSize: 11.5, color: Color(0xff9aacca)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
