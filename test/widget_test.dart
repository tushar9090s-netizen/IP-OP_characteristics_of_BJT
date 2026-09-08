import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bjt_characteristics/main.dart';
import 'package:bjt_characteristics/models/bjt_physics.dart';

void main() {
  group('Experiment 5 BjtPhysics Unit Tests', () {
    test('Input circuit solves Vbe and Ib for cut-off vs conduction', () {
      final subCutin = BjtPhysics.solveInputCircuit(vbb: 0.5, vce: 1.0);
      final conduction = BjtPhysics.solveInputCircuit(vbb: 2.0, vce: 1.0);

      // At Vbb = 0.5V (< 0.65V), IB is negligible
      expect(subCutin['ibMa']!, lessThan(0.01));
      expect(subCutin['vbe']!, equals(0.5));

      // At Vbb = 2.0V, IB is around 1.3 mA with Vbe around 0.7V
      expect(conduction['ibMa']!, greaterThan(1.0));
      expect(conduction['vbe']!, greaterThan(0.65));
      expect(conduction['vbe']!, lessThan(0.80));
    });

    test('Input circuit exhibits Early effect: Vce = 2V shifts curve slightly right', () {
      final solVce1 = BjtPhysics.solveInputCircuit(vbb: 2.0, vce: 1.0);
      final solVce2 = BjtPhysics.solveInputCircuit(vbb: 2.0, vce: 2.0);

      // At higher Vce, Vbe is slightly higher (curve shifted right), so IB is slightly lower
      expect(solVce2['vbe']!, greaterThanOrEqualTo(solVce1['vbe']!));
    });

    test('Output circuit correctly simulates 4.3uA and 10uA base currents', () {
      final sol43 = BjtPhysics.solveOutputCircuit(vcc: 5.0, ibUa: 4.3);
      final sol10 = BjtPhysics.solveOutputCircuit(vcc: 5.0, ibUa: 10.0);

      // IC for 10uA should be roughly double IC for 4.3uA
      expect(sol10['icMa']!, greaterThan(sol43['icMa']!));
      expect(sol43['icMa']!, greaterThan(0.7));
      expect(sol10['icMa']!, greaterThan(1.8));
    });

    test('Dynamic Input Resistance and Output Resistance calculations', () {
      final ri = BjtPhysics.calculateDynamicInputResistance(vbb: 2.0, vce: 1.0);
      final ro = BjtPhysics.calculateDynamicOutputResistance(vcc: 5.0, ibUa: 10.0);

      expect(ri, greaterThan(10.0));
      expect(ri, lessThan(5000.0));
      expect(ro, greaterThan(10000.0));
    });

    test('Standard Result Tables generation', () {
      final inputTable1V = BjtPhysics.generateStandardInputTable(vce: 1.0);
      expect(inputTable1V.length, equals(11)); // 0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5

      final outputTable10uA = BjtPhysics.generateStandardOutputTable(ibUa: 10.0);
      expect(outputTable10uA.length, equals(10)); // 1 to 10 V
    });
  });

  group('Experiment 5 BjtLabApp Widget Tests', () {
    testWidgets('Renders Experiment 5 Lab Simulator with Input Characteristics', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const BjtLabApp());
      await tester.pumpAndSettle();

      // Check titles matching Experiment 5
      expect(find.text('EXPERIMENT 5 · BJT LAB'), findsOneWidget);
      expect(find.text('Input & Output Characteristics'), findsOneWidget);
      expect(find.text('BC547 (NPN)'), findsOneWidget);

      // Check input mode controls
      expect(find.text('Input (IB vs VBE)'), findsOneWidget);
      expect(find.text('Output (IC vs VCE)'), findsOneWidget);
      expect(find.text('VCE (V2) Setting:'), findsOneWidget);
      expect(find.text('1.0 V (Step 2)'), findsOneWidget);
      expect(find.text('2.0 V (Step 4)'), findsOneWidget);

      // Check schematic title
      expect(find.text('Input Characteristics Circuit Diagram'), findsOneWidget);

      // Check Result Tables
      expect(find.text('Lab Result Tables (Experiment 5)'), findsOneWidget);
      expect(find.text('Record Active Reading'), findsOneWidget);
      expect(find.text('Auto-Fill Lab Sheet'), findsOneWidget);
    });

    testWidgets('Toggling between Input and Output modes updates controls and diagrams', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const BjtLabApp());
      await tester.pumpAndSettle();

      // Switch to Output mode
      final outputBtn = find.text('Output (IC vs VCE)');
      await tester.tap(outputBtn);
      await tester.pumpAndSettle();

      // Check Output mode controls and diagram
      expect(find.text('Output Characteristics Circuit Diagram'), findsOneWidget);
      expect(find.text('Base Resistor R1 Selection:'), findsOneWidget);
      expect(find.text('1 MΩ (4.3µA)'), findsOneWidget);
      expect(find.text('470 kΩ (10µA)'), findsOneWidget);
      expect(find.text('Collector Supply V2 (VCC):'), findsOneWidget);
    });

    testWidgets('Navigation to Learn and Quiz tabs works seamlessly', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const BjtLabApp());
      await tester.pumpAndSettle();

      // Navigate to Learn tab
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await tester.pumpAndSettle();

      expect(find.text('EXPERIMENT 5'), findsOneWidget);
      expect(find.text('Objective & Apparatus'), findsOneWidget);
      expect(find.text('Laboratory Procedures'), findsOneWidget);

      // Navigate to Quiz tab
      await tester.tap(find.byIcon(Icons.quiz_outlined));
      await tester.pumpAndSettle();

      expect(find.text('CONCEPT CHECK'), findsOneWidget);
      expect(find.text('BJT Checkpoint Quiz'), findsOneWidget);
    });
  });
}
