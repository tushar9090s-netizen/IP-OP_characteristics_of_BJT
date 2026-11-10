import 'package:flutter/material.dart';

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class QuizTab extends StatefulWidget {
  final Function(int correctCount) onQuizCompleted;

  const QuizTab({super.key, required this.onQuizCompleted});

  @override
  State<QuizTab> createState() => _QuizTabState();
}

class _QuizTabState extends State<QuizTab> {
  static const List<QuizQuestion> _questions = [
    QuizQuestion(
      question: 'In Experiment 5, what type of transistor is used for the laboratory study?',
      options: ['2N3904 PNP', 'BC547 NPN', 'IRFZ44N MOSFET', 'BD139 Power Transistor'],
      correctIndex: 1,
      explanation: 'BC547 is a popular general-purpose NPN bipolar junction transistor specified in the lab manual.',
    ),
    QuizQuestion(
      question: 'What is the typical cut-in (knee) voltage of the Silicon BC547 transistor in input characteristics?',
      options: ['0.2 V to 0.3 V', '0.6 V to 0.7 V', '1.2 V to 1.5 V', '5.0 V'],
      correctIndex: 1,
      explanation: 'Silicon P-N junctions have a barrier potential of approximately 0.7 V, below which base current is negligible.',
    ),
    QuizQuestion(
      question: 'In the output characteristics circuit, why is R1 selected as 1MΩ with a 5V supply?',
      options: [
        'To prevent transistor breakdown',
        'To set the base current IB precisely to 4.3 µA',
        'To maximize collector voltage',
        'To convert NPN into PNP',
      ],
      correctIndex: 1,
      explanation: 'With V1 = 5V and VBE ≈ 0.7V: IB = (5V - 0.7V) / 1MΩ = 4.3 µA, establishing the required constant base current.',
    ),
    QuizQuestion(
      question: 'How is the Dynamic Input Resistance (ri) mathematically calculated from the input curve?',
      options: [
        'ri = ΔVCE / ΔIC (at constant IB)',
        'ri = ΔVBE / ΔIB (at constant VCE)',
        'ri = VBE × IB',
        'ri = ΔIC / ΔIB',
      ],
      correctIndex: 1,
      explanation: 'Dynamic input resistance is the reciprocal of the slope of the input characteristic curve: ri = (ΔVBE / ΔIB) at constant VCE.',
    ),
    QuizQuestion(
      question: 'How is the AC Current Gain (βac) defined according to Experiment 5?',
      options: [
        'βac = IC / IB',
        'βac = (ΔIC / ΔIB) at constant VCE',
        'βac = IE / IB',
        'βac = ΔVCE / ΔIC',
      ],
      correctIndex: 1,
      explanation: 'As defined in the manual: βac = (ΔIC / ΔIB) at constant VCE, evaluated from the spacing between adjacent output curves.',
    ),
    QuizQuestion(
      question: 'In which region of the output characteristics does VCE drop below ~0.2V to 0.4V?',
      options: ['Cut-off Region', 'Active Region', 'Saturation Region', 'Breakdown Region'],
      correctIndex: 2,
      explanation: 'In the saturation region, both junctions are forward-biased, and IC rises steeply towards its external circuit limit.',
    ),
    QuizQuestion(
      question: 'In the common-emitter configuration, which terminal is shared by the input and output circuits?',
      options: ['Base', 'Collector', 'Emitter', 'None of them'],
      correctIndex: 2,
      explanation: 'In a common-emitter circuit, the emitter is the common reference terminal for both the base input and collector output circuits.',
    ),
    QuizQuestion(
      question: 'What happens to collector current in the active region when base current increases?',
      options: [
        'It decreases to zero',
        'It increases approximately in proportion to base current',
        'It stays fixed regardless of base current',
        'It becomes equal to the base current',
      ],
      correctIndex: 1,
      explanation: 'In the active region, collector current is approximately β times the base current, so increasing IB raises IC.',
    ),
    QuizQuestion(
      question: 'For a transistor operating in the active region, how are its base-emitter and base-collector junctions biased?',
      options: [
        'Both reverse-biased',
        'Both forward-biased',
        'Base-emitter forward-biased and base-collector reverse-biased',
        'Base-emitter reverse-biased and base-collector forward-biased',
      ],
      correctIndex: 2,
      explanation: 'Active operation uses a forward-biased base-emitter junction and a reverse-biased base-collector junction.',
    ),
    QuizQuestion(
      question: 'What does the spacing between output characteristic curves for different base currents represent?',
      options: [
        'Change in collector current as base current changes',
        'Change in base-emitter voltage as collector voltage changes',
        'The transistor cut-in voltage',
        'The collector-emitter breakdown voltage',
      ],
      correctIndex: 0,
      explanation: 'Each output curve corresponds to a different IB; their vertical separation shows how IC changes with IB at a given VCE.',
    ),
  ];

  final Map<int, int> _selectedAnswers = {};
  bool _submitted = false;

  int get _score {
    int score = 0;
    _selectedAnswers.forEach((qIndex, aIndex) {
      if (aIndex == _questions[qIndex].correctIndex) {
        score++;
      }
    });
    return score;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff131d31), Color(0xff0f172a)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xff1e293b)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xff1e3a8a),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.quiz_rounded, color: Colors.white),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CONCEPT CHECK',
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w800,
                        color: Color(0xff38bdf8),
                        fontSize: 11,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'BJT Checkpoint Quiz',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '10 questions · Test your understanding',
                      style: TextStyle(fontSize: 12, color: Color(0xffcbd5e1)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Score banner if submitted
        if (_submitted)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff131d31), Color(0xff0f172a)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xff1e293b)),
            ),
            child: Row(
              children: [
                Icon(
                  _score >= 8 ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: _score >= 8 ? const Color(0xff38bdf8) : const Color(0xff60a5fa),
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Score: $_score / ${_questions.length}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _score >= 8
                            ? 'Excellent! You have mastered BJT characteristics.'
                            : 'Review the theory tab and give it another try!',
                        style: const TextStyle(color: Color(0xffcbd5e1), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        ...List.generate(_questions.length, (index) => _buildQuestionCard(index)),

        const SizedBox(height: 14),
        if (!_submitted)
          ElevatedButton(
            onPressed: _selectedAnswers.length == _questions.length
                ? () {
                    setState(() => _submitted = true);
                    widget.onQuizCompleted(_score);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1e3a8a),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text(
              _selectedAnswers.length == _questions.length
                  ? 'Submit Quiz'
                  : 'Answer all ${ _questions.length - _selectedAnswers.length } remaining',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          )
        else
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _selectedAnswers.clear();
                _submitted = false;
              });
              widget.onQuizCompleted(0);
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retake Quiz'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff38bdf8),
              side: const BorderSide(color: Color(0xff1e293b)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
      ],
    );
  }

  Widget _buildQuestionCard(int qIndex) {
    final q = _questions[qIndex];
    final selectedOption = _selectedAnswers[qIndex];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff111827),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xff1e293b)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xff1e3a8a),
                child: Text(
                  '${qIndex + 1}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff93c5fd)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  q.question,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(q.options.length, (optIndex) {
            final isChosen = selectedOption == optIndex;
            final isCorrect = q.correctIndex == optIndex;

            Color borderColor = const Color(0xff334155);
            Color bgColor = const Color(0xff0f172a);

            if (_submitted) {
              if (isCorrect) {
                borderColor = const Color(0xff38a169);
                bgColor = const Color(0xff143622);
              } else if (isChosen) {
                borderColor = const Color(0xffe53e3e);
                bgColor = const Color(0xff3d1717);
              }
            } else if (isChosen) {
              borderColor = const Color(0xff38bdf8);
              bgColor = const Color(0xff172554);
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: _submitted
                    ? null
                    : () {
                        setState(() {
                          _selectedAnswers[qIndex] = optIndex;
                        });
                      },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isChosen ? const Color(0xff38bdf8) : const Color(0xff64748b),
                            width: 1.5,
                          ),
                          color: isChosen ? const Color(0xff38bdf8) : Colors.transparent,
                        ),
                        child: isChosen
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          q.options[optIndex],
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isChosen ? Colors.white : const Color(0xffcbd5e1),
                            fontWeight: isChosen ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (_submitted) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xff0f172a),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xff38bdf8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      q.explanation,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xffcbd5e1), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

