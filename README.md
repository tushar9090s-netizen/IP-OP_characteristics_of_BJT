# Experiment 5: Input and Output Characteristics of BJT (BC547)

An interactive, high-fidelity Flutter electronics laboratory application for studying the **Input and Output Characteristics of a Bipolar Junction Transistor (BJT)** in Common Emitter (CE) configuration, calibrated specifically for the **BC547 NPN** transistor according to laboratory curriculum standards.

---

## 📋 Objectives (From Lab Manual)
1. **Design the circuit diagram** for Input and Output characteristics.
2. **Take readings and draw the characteristics curves** ($I_B$ vs $V_{BE}$ and $I_C$ vs $V_{CE}$).
3. **Determine the input resistance ($r_i$) and output resistance ($r_o$)**, along with current gain ($\beta_{dc}$ and $\beta_{ac}$).

---

## ✨ Features

### 1. Interactive Characteristics Curves
- **Input Characteristics ($I_B$ vs $V_{BE}$)**:
  - Plots family of curves for $V_{CE} = 1.0\text{ V}$ and $V_{CE} = 2.0\text{ V}$.
  - Demonstrates the cut-in (knee) voltage ($V_\gamma \approx 0.68\text{ V}$) and forward conduction.
  - Models the Early effect / base-width modulation causing rightward curve shift at higher $V_{CE}$.
  - Animated Q-point tracker on the curve with live coordinate badge $(V_{BE}, I_B)$.
- **Output Characteristics ($I_C$ vs $V_{CE}$)**:
  - Plots curves across $V_{CE} \in [0, 20\text{ V}]$ with shaded **Saturation Region** ($0-2\text{ V}$) and **Active Region** ($2-20\text{ V}$).
  - Displays laboratory curves for $I_B = 4.3\text{ }\mu\text{A}$ ($R_1 = 1\text{ M}\Omega$) and $I_B = 10\text{ }\mu\text{A}$ ($R_1 = 470\text{ k}\Omega$), as well as higher reference curves ($50, 100, 150, 200, 250\text{ }\mu\text{A}$).
  - Live Q-point crosshair tracker showing $(V_{CE}, I_C)$.

### 2. Virtual Circuit Schematics & Live Digital Meters
Faithfully reproduces the two circuit diagrams from the laboratory manual:
- **Input Characteristics Circuit (Image 2)**:
  - Variable DC power supply $V_1$ ($0-5\text{ V DC}$).
  - Base series resistor $R_1 = 1\text{ k}\Omega$.
  - Series ammeter `(+) mA (-)`.
  - Transistor $Q_1$ (BC547 NPN) in Common Emitter setup.
  - Voltmeter `(+) V (-)` across base and emitter ($V_{BE}$).
  - Fixed DC supply $V_2 = 1\text{ V}, 2\text{ V}$ across collector and emitter.
- **Output Characteristics Circuit (Image 3)**:
  - Fixed DC power supply $V_1 = 5\text{ V DC}$.
  - Resistor $R_1 \in \{470\text{ k}\Omega, 1\text{ M}\Omega\}$.
  - Collector ammeter `(-) mA (+)`.
  - Collector series resistor $R_2 = 1\text{ k}\Omega$.
  - Voltmeter `(+) V (-)` across collector and emitter ($V_{CE}$).
  - Variable DC power supply $V_2$ ($0-15\text{ V DC}$).
- Displays live digital meter badges beneath the schematic.

### 3. Laboratory Result Tables (Images 2, 3 & 4)
- **Input Result Table**:
  - $V_{bb}$ ($0\text{ V}, 0.5\text{ V}, 1\text{ V}, 1.5\text{ V}, 2\text{ V}, 2.5\text{ V}, 3\text{ V}, 3.5\text{ V}, 4\text{ V}, 4.5\text{ V}, 5\text{ V}$) $\to$ $I_B$ (mA and $\mu\text{A}$) and $V_{be}$ for $V_{CE} = 1\text{ V}$ and $V_{CE} = 2\text{ V}$.
- **Output Result Table**:
  - $V_{CC}$ ($1\text{ V}, 2\text{ V}, 3\text{ V}, 4\text{ V}, 5\text{ V}, 6\text{ V}, 7\text{ V}, 8\text{ V}, 9\text{ V}, 10\text{ V}$) $\to$ $V_{CE}$ and $I_C$ for $I_B = 10\text{ }\mu\text{A}$ ($470\text{ k}\Omega$) and $I_B = 4.3\text{ }\mu\text{A}$ ($1\text{ M}\Omega$).
- **One-Touch Actions**:
  - **Record Active Reading**: Logs the active simulator slider values into the table.
  - **Auto-Fill Lab Sheet**: Fills the complete table with standard experimental readings.
  - **Clear**: Resets data table.

### 4. Dynamic Parameter Calculations
Calculates and presents the exact parameters specified in the manual:
- **Dynamic Input Resistance**:
  $$r_i = \left(\frac{\Delta V_{BE}}{\Delta I_B}\right)_{V_{CE} = \text{const}}$$
- **Dynamic Output Resistance**:
  $$r_o = \left(\frac{\Delta V_{CE}}{\Delta I_C}\right)_{I_B = \text{const}}$$
- **DC Current Gain**:
  $$\beta_{dc} = \frac{I_C}{I_B}$$
- **AC Current Gain**:
  $$\beta_{ac} = \left(\frac{\Delta I_C}{\Delta I_B}\right)_{V_{CE} = \text{const}}$$

### 5. Theory Guide & Checkpoint Quiz
- **Learn Tab**: Verbatim lab manual theory, apparatus requirements, terminal descriptions, and step-by-step procedures for both experiments.
- **Quiz Tab**: 6 concept checkpoint questions with instant feedback and comprehensive explanations.
- **Module Progress Tracker**: Dynamically tracks progress from baseline to 100% as the student conducts experiments, fills observation tables, and passes the quiz.

---

## 🧰 Apparatus & Components (Experiment 5)

| Equipment | Specification |
| :--- | :--- |
| **Transistor** | BC547 (Silicon NPN, nominal $h_{FE} \approx 200 - 300$) |
| **Resistors** | $1\text{ k}\Omega$, $470\text{ k}\Omega$, $1\text{ M}\Omega$ |
| **Power Supplies** | $0 - 5\text{ V DC}$ (Input $V_1$), $5\text{ V DC}$ (Output $V_1$), $0 - 15\text{ V DC}$ ($V_2$) |
| **Meters** | Microammeter ($\mu\text{A}$), Milliammeter ($\text{mA}$), Voltmeters ($V_{BE}, V_{CE}$) |
| **Prototyping** | Bread Board & Connecting wires |

---

## 📁 Project Structure

```
lib/
├── main.dart                  # Main application & interactive lab explorer
├── models/
│   └── bjt_physics.dart       # BC547 physics engine, circuit solvers, and result tables
├── widgets/
│   ├── circuit_diagram.dart   # Circuit schematics with live digital meters
│   ├── input_curve_painter.dart # CustomPainter for IB vs VBE input curve
│   ├── output_curve_painter.dart# CustomPainter for IC vs VCE output curve
│   └── observation_table.dart # Result tables & dynamic resistance calculations
└── screens/
    ├── learn_tab.dart         # Laboratory manual theory & procedures
    └── quiz_tab.dart          # Checkpoint quiz with scoring & explanations
test/
└── widget_test.dart           # Complete unit and widget test suite
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (v3.13 or newer)
- Dart SDK (v3.0 or newer)

### Running the App
```bash
# Get dependencies
flutter pub get

# Run on connected device or Chrome
flutter run
```

### Running Tests
```bash
# Run unit and widget tests
flutter test

# Run static analysis
flutter analyze
```

---

## 🧪 Verification
- `flutter analyze`: **0 issues found** (clean code, no warnings or lints).
- `flutter test`: **8/8 unit & widget tests passed** covering physics calculations, Early effect, circuit equations, result tables, and UI navigation.

