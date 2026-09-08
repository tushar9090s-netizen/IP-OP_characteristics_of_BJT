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
        Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xff7742d4),
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
                      color: Color(0xffb799f2),
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    'BJT Checkpoint Quiz',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Score banner if submitted
        if (_submitted)
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _score >= 4
                    ? [const Color(0xff164d36), const Color(0xff0d2b1f)]
                    : [const Color(0xff4a2d16), const Color(0xff2d1b0c)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _score >= 4 ? const Color(0xff2e8b61) : const Color(0xffa15d2a),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _score >= 4 ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  color: _score >= 4 ? const Color(0xff67d7b4) : const Color(0xfff6ad55),
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
                        _score >= 4
                            ? 'Excellent! You have mastered BJT characteristics.'
                            : 'Review the theory tab and give it another try!',
                        style: const TextStyle(color: Color(0xffcbd7ea), fontSize: 12),
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
              backgroundColor: const Color(0xff3f6be0),
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
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retake Quiz'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff8fb2f5),
              side: const BorderSide(color: Color(0xff2d4c82)),
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
        color: const Color(0xff101c30),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xff233554)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xff1e3256),
                child: Text(
                  '${qIndex + 1}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xff9cb8ec)),
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

            Color borderColor = const Color(0xff233554);
            Color bgColor = const Color(0xff0d1728);

            if (_submitted) {
              if (isCorrect) {
                borderColor = const Color(0xff38a169);
                bgColor = const Color(0xff143622);
              } else if (isChosen) {
                borderColor = const Color(0xffe53e3e);
                bgColor = const Color(0xff3d1717);
              }
            } else if (isChosen) {
              borderColor = const Color(0xff4e7bff);
              bgColor = const Color(0xff182b52);
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
                            color: isChosen ? const Color(0xff6fa4ff) : const Color(0xff576e93),
                            width: 1.5,
                          ),
                          color: isChosen ? const Color(0xff3f6be0) : Colors.transparent,
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
                            color: isChosen ? Colors.white : const Color(0xffb0c2e0),
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
                color: const Color(0xff091424),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 16, color: Color(0xfff6ad55)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      q.explanation,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xff9eb4d8), height: 1.3),
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

