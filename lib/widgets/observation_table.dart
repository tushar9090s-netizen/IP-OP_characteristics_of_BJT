import 'package:flutter/material.dart';
import '../models/bjt_physics.dart';

class ObservationTableWidget extends StatefulWidget {
  final bool isInputMode;
  final double currentVbb;
  final double currentVce;
  final double currentVcc;
  final double currentIbUa;
  final double currentIbMa;
  final double currentVbe;
  final double currentIcMa;
  final VoidCallback? onRecordingMade;

  const ObservationTableWidget({
    super.key,
    required this.isInputMode,
    required this.currentVbb,
    required this.currentVce,
    required this.currentVcc,
    required this.currentIbUa,
    required this.currentIbMa,
    required this.currentVbe,
    required this.currentIcMa,
    this.onRecordingMade,
  });

  @override
  State<ObservationTableWidget> createState() => _ObservationTableWidgetState();
}

class _ObservationTableWidgetState extends State<ObservationTableWidget> {
  // Input tables data: Map<Vce, Map<Vbb, InputLabReading>>
  final Map<double, Map<double, InputLabReading>> _inputRecords = {
    1.0: {},
    2.0: {},
  };

  // Output tables data: Map<IbUa, Map<Vcc, OutputLabReading>>
  final Map<double, Map<double, OutputLabReading>> _outputRecords = {
    10.0: {},
    4.3: {},
  };

  double _selectedInputVce = 1.0;
  double _selectedOutputIb = 10.0;

  @override
  void initState() {
    super.initState();
    _populateDefaultTables();
  }

  void _populateDefaultTables() {
    for (final vce in [1.0, 2.0]) {
      final list = BjtPhysics.generateStandardInputTable(vce: vce);
      for (final item in list) {
        _inputRecords[vce]![item.vbb] = item;
      }
    }
    for (final ib in [10.0, 4.3]) {
      final list = BjtPhysics.generateStandardOutputTable(ibUa: ib);
      for (final item in list) {
        _outputRecords[ib]![item.vcc] = item;
      }
    }
  }

  void _recordCurrentPoint() {
    setState(() {
      if (widget.isInputMode) {
        final vceKey = (widget.currentVce - 1.0).abs() < 0.5 ? 1.0 : 2.0;
        final vbbKey = (widget.currentVbb * 2).round() / 2.0;
        _inputRecords[vceKey]![vbbKey] = InputLabReading(
          vbb: vbbKey,
          vce: vceKey,
          ibMa: widget.currentIbMa,
          ibUa: widget.currentIbUa,
          vbe: widget.currentVbe,
        );
      } else {
        final ibKey = (widget.currentIbUa - 4.3).abs() < 2.5 ? 4.3 : 10.0;
        final vccKey = widget.currentVcc.roundToDouble().clamp(1.0, 10.0);
        _outputRecords[ibKey]![vccKey] = OutputLabReading(
          vcc: vccKey,
          ibUa: ibKey,
          vce: widget.currentVce,
          icMa: widget.currentIcMa,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isInputMode
              ? 'Logged reading at Vbb = ${widget.currentVbb.toStringAsFixed(1)}V, Vce = ${widget.currentVce.toStringAsFixed(0)}V'
              : 'Logged reading at Vcc = ${widget.currentVcc.toStringAsFixed(0)}V, IB = ${widget.currentIbUa.toStringAsFixed(1)}µA',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xff3d2c0a),
      ),
    );
    widget.onRecordingMade?.call();
  }

  void _fillAllTables() {
    setState(() {
      _populateDefaultTables();
    });
    widget.onRecordingMade?.call();
  }

  void _clearTables() {
    setState(() {
      _inputRecords[1.0]!.clear();
      _inputRecords[2.0]!.clear();
      _outputRecords[10.0]!.clear();
      _outputRecords[4.3]!.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xff1e293b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.table_view_rounded, color: Color(0xff38bdf8), size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Lab Result Tables (Experiment 5)',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xfff1f5f9)),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xff1e293b),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.isInputMode ? 'Input Result Table' : 'Output Result Table',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: widget.isInputMode ? const Color(0xff38bdf8) : const Color(0xff34d399),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Action Toolbar
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: _recordCurrentPoint,
                icon: const Icon(Icons.add_task_rounded, size: 16),
                label: const Text('Record Active Reading', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff2563eb),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _fillAllTables,
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('Auto-Fill Lab Sheet', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff38bdf8),
                  side: const BorderSide(color: Color(0xff334155)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              TextButton.icon(
                onPressed: _clearTables,
                icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xfff87171)),
                label: const Text('Clear', style: TextStyle(fontSize: 12, color: Color(0xfff87171))),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Sub-table Selector Segment
          if (widget.isInputMode) ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                const Text('Select VCE Setting:', style: TextStyle(color: Color(0xff94a3b8), fontSize: 12)),
                SegmentedButton<double>(
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  segments: const [
                    ButtonSegment(value: 1.0, label: Text('VCE = 1V')),
                    ButtonSegment(value: 2.0, label: Text('VCE = 2V')),
                  ],
                  selected: {_selectedInputVce},
                  onSelectionChanged: (v) => setState(() => _selectedInputVce = v.first),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildInputTable(_selectedInputVce),
          ] else ...[
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: [
                const Text('Select Base Current (IB):', style: TextStyle(color: Color(0xff94a3b8), fontSize: 12)),
                SegmentedButton<double>(
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  segments: const [
                    ButtonSegment(value: 10.0, label: Text('10 µA (470k)')),
                    ButtonSegment(value: 4.3, label: Text('4.3 µA (1M)')),
                  ],
                  selected: {_selectedOutputIb},
                  onSelectionChanged: (v) => setState(() => _selectedOutputIb = v.first),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildOutputTable(_selectedOutputIb),
          ],

          const SizedBox(height: 16),
          // Calculations from Result Table (ri, ro, beta_dc, beta_ac)
          _buildCalculationsCard(),
        ],
      ),
    );
  }

  Widget _buildInputTable(double vce) {
    const vbbSteps = [0.0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0];
    final records = _inputRecords[vce] ?? {};

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff0f172a),
          border: Border.all(color: const Color(0xff1e293b)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xff1e293b)),
            horizontalMargin: 16,
            columnSpacing: 28,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff93c5fd),
              fontSize: 12,
            ),
            dataTextStyle: const TextStyle(fontSize: 11.5, color: Color(0xffcbd5e1)),
            columns: [
              const DataColumn(label: Text('Vbb (V1)')),
              DataColumn(label: Text('IB (mA)')),
              DataColumn(label: Text('IB (µA)')),
              DataColumn(label: Text('Vbe (V)')),
              const DataColumn(label: Text('Status')),
            ],
            rows: vbbSteps.map((vbb) {
              final reading = records[vbb];
              final isCurrent = (widget.currentVbb - vbb).abs() < 0.25 &&
                  (widget.currentVce - vce).abs() < 0.5 &&
                  widget.isInputMode;

              return DataRow(
                color: isCurrent
                    ? WidgetStateProperty.all(const Color(0xff1e293b))
                    : null,
                cells: [
                  DataCell(Text(vbb == 0.0 ? '0V' : '${vbb.toStringAsFixed(1)}V')),
                  DataCell(Text(
                    reading != null ? '${reading.ibMa.toStringAsFixed(3)} mA' : '--',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
                  DataCell(Text(reading != null ? '${reading.ibUa.toStringAsFixed(0)} µA' : '--')),
                  DataCell(Text(
                    reading != null ? '${reading.vbe.toStringAsFixed(3)} V' : '--',
                    style: const TextStyle(color: Color(0xff38bdf8), fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(
                    reading == null
                        ? 'Pending'
                        : reading.vbe < 0.65
                            ? 'Cut-off'
                            : 'Conduction',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: reading == null
                          ? const Color(0xff64748b)
                          : reading.vbe < 0.65
                              ? const Color(0xff94a3b8)
                              : const Color(0xff38bdf8),
                    ),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildOutputTable(double ibUa) {
    const vccSteps = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0];
    final records = _outputRecords[ibUa] ?? {};

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff0f172a),
          border: Border.all(color: const Color(0xff1e293b)),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(const Color(0xff1e293b)),
            horizontalMargin: 16,
            columnSpacing: 28,
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xff6ee7b7),
              fontSize: 12,
            ),
            dataTextStyle: const TextStyle(fontSize: 11.5, color: Color(0xffcbd5e1)),
            columns: const [
              DataColumn(label: Text('VCC (V)')),
              DataColumn(label: Text('VCE (V)')),
              DataColumn(label: Text('IC (mA)')),
              DataColumn(label: Text('Region')),
            ],
            rows: vccSteps.map((vcc) {
              final reading = records[vcc];
              final isCurrent = (widget.currentVcc - vcc).abs() < 0.5 &&
                  (widget.currentIbUa - ibUa).abs() < 2.5 &&
                  !widget.isInputMode;

              return DataRow(
                color: isCurrent
                    ? WidgetStateProperty.all(const Color(0xff1e293b))
                    : null,
                cells: [
                  DataCell(Text('${vcc.toInt()}V')),
                  DataCell(Text(
                    reading != null ? '${reading.vce.toStringAsFixed(2)} V' : '--',
                    style: const TextStyle(color: Color(0xff34d399), fontWeight: FontWeight.bold),
                  )),
                  DataCell(Text(
                    reading != null ? '${reading.icMa.toStringAsFixed(2)} mA' : '--',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  )),
                  DataCell(Text(
                    reading == null
                        ? 'Pending'
                        : reading.vce < 0.3
                            ? 'Saturation'
                            : 'Active',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: reading == null
                          ? const Color(0xff64748b)
                          : reading.vce < 0.3
                              ? const Color(0xff60a5fa)
                              : const Color(0xff34d399),
                    ),
                  )),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildCalculationsCard() {
    // Dynamic resistances and Beta calculations from current operating point
    final ri = BjtPhysics.calculateDynamicInputResistance(
      vbb: widget.currentVbb,
      vce: widget.currentVce,
    );
    final ro = BjtPhysics.calculateDynamicOutputResistance(
      vcc: widget.currentVcc,
      ibUa: widget.currentIbUa,
    );
    final betaDc = BjtPhysics.calculateBetaDc(
      icMa: widget.currentIcMa,
      ibUa: widget.currentIbUa,
    );
    final betaAc = BjtPhysics.calculateBetaAc(
      vcc: widget.currentVcc,
      ibUa: widget.currentIbUa,
    );

    final riStr = ri >= 99999
        ? '> 100 kΩ (Cut-off)'
        : '${ri.toStringAsFixed(0)} Ω  (~${(ri / 1000).toStringAsFixed(2)} kΩ)';
    final roStr = ro >= 999999
        ? '> 1 MΩ (Near zero IC)'
        : '${(ro / 1000).toStringAsFixed(1)} kΩ';
    final betaDcStr = betaDc <= 0.1
        ? '-- (Cut-off)'
        : '${betaDc.toStringAsFixed(0)} (at VCE=${widget.currentVce.toStringAsFixed(1)}V)';
    final betaAcStr = betaAc <= 0.1
        ? '--'
        : '${betaAc.toStringAsFixed(0)} (local slope)';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xff0f172a),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xff1e293b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_outlined, color: Color(0xff38bdf8), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Calculations & Parameters (Experiment 5 Objective 3)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xfff1f5f9)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _calcRow(
            symbol: 'ri (Input Resistance)',
            formula: 'ri = (ΔVBE / ΔIB) | VCE=const',
            value: riStr,
            color: const Color(0xff38bdf8),
          ),
          const Divider(color: Color(0xff1e293b), height: 14),
          _calcRow(
            symbol: 'ro (Output Resistance)',
            formula: 'ro = (ΔVCE / ΔIC) | IB=const',
            value: roStr,
            color: const Color(0xff34d399),
          ),
          const Divider(color: Color(0xff1e293b), height: 14),
          _calcRow(
            symbol: 'βdc (DC Current Gain)',
            formula: 'βdc = IC / IB',
            value: betaDcStr,
            color: const Color(0xff60a5fa),
          ),
          const Divider(color: Color(0xff1e293b), height: 14),
          _calcRow(
            symbol: 'βac (AC Current Gain)',
            formula: 'βac = (ΔIC / ΔIB) | VCE=const',
            value: betaAcStr,
            color: const Color(0xff818cf8),
          ),
        ],
      ),
    );
  }

  Widget _calcRow({
    required String symbol,
    required String formula,
    required String value,
    required Color color,
  }) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(symbol, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xfff1f5f9))),
            Text(formula, style: const TextStyle(fontSize: 10, color: Color(0xff94a3b8), fontFamily: 'Courier')),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ],
    );
  }
}
