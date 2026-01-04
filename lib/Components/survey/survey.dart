import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:khmerlearning/Components/auth/login/login.dart';

class SurveyScreen extends StatefulWidget {
  const SurveyScreen({super.key});

  @override
  State<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
  int currentQuestion = 0;
  final Map<int, dynamic> answers = {};

  final List<Map<String, dynamic>> questions = [
    {
      "type": "date",
      "question": "What is your birthday?",
    },
    {
      "type": "choice",
      "question": "What is your gender?",
      "options": ["Male", "Female", "Other"],
    },
    {
      "type": "choice",
      "question": "What grade are you in?",
      "options": ["Grade 1–6", "Grade 7–9", "Grade 10–12", "University"],
    },
    {
      "type": "choice",
      "question": "What is your favorite subject?",
      "options": ["Math", "Science", "English", "History"],
    },
    {
      "type": "choice",
      "question": "How often do you study?",
      "options": ["Rarely", "1–2 hrs", "2–4 hrs", "Everyday"],
    },
    {
      "type": "choice",
      "question": "Do you like online learning?",
      "options": ["Yes", "No", "Sometimes"],
    },
    {
      "type": "choice",
      "question": "Do you study alone or with friends?",
      "options": ["Alone", "With friends", "Both"],
    },
    {
      "type": "choice",
      "question": "What device do you use for learning?",
      "options": ["Phone", "Tablet", "Laptop", "Desktop"],
    },
  ];

  final DateTime maxDate = DateTime(2026, 1, 4); // Today’s date

  void _next() {
    if (currentQuestion < questions.length - 1) {
      setState(() => currentQuestion++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    // Check if Next button should be enabled
    final isNextEnabled = answers[currentQuestion] != null &&
        (q["type"] != "date" ||
            (answers[currentQuestion] as DateTime)
                .isBefore(maxDate.add(const Duration(days: 1))));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Survey"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff00a78e), Color(0xff00c3a5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                color: const Color(0xff00a78e),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              "Question ${currentQuestion + 1} of ${questions.length}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            Text(
              q["question"],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            // DATE PICKER
            if (q["type"] == "date")
              BirthdayPicker(
                value: answers[currentQuestion],
                maxDate: maxDate,
                onChanged: (date) {
                  setState(() => answers[currentQuestion] = date);
                },
              ),

            // OPTIONS
            if (q["type"] == "choice")
              ...q["options"].map<Widget>((opt) {
                final selected = answers[currentQuestion] == opt;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xff00a78e)
                          : Colors.grey.shade300,
                    ),
                    color: selected
                        ? const Color(0xff00a78e).withOpacity(0.08)
                        : Colors.white,
                  ),
                  child: RadioListTile(
                    value: opt,
                    groupValue: answers[currentQuestion],
                    onChanged: (v) =>
                        setState(() => answers[currentQuestion] = v),
                    activeColor: const Color(0xff00a78e),
                    title: Text(opt),
                  ),
                );
              }),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isNextEnabled ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff00a78e),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  currentQuestion == questions.length - 1
                      ? "Submit"
                      : "Next",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//////////////////////////////////////////////////////////////
/// BIRTHDAY PICKER (iOS STYLE)
//////////////////////////////////////////////////////////////

class BirthdayPicker extends StatefulWidget {
  final DateTime? value;
  final DateTime maxDate;
  final Function(DateTime) onChanged;

  const BirthdayPicker({
    super.key,
    required this.value,
    required this.maxDate,
    required this.onChanged,
  });

  @override
  State<BirthdayPicker> createState() => _BirthdayPickerState();
}

class _BirthdayPickerState extends State<BirthdayPicker> {
  late int day;
  late int month;
  late int year;

  final months = const [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  int get daysInMonth {
    final nextMonth = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1)).day;
  }

  @override
  void initState() {
    super.initState();
    final date = widget.value ?? widget.maxDate;
    day = date.day;
    month = date.month;
    year = date.year;
  }

  void _updateDate(int newDay, int newMonth, int newYear) {
    DateTime selected = DateTime(newYear, newMonth, newDay);

    // Clamp to maxDate
    if (selected.isAfter(widget.maxDate)) {
      selected = widget.maxDate;
    }

    setState(() {
      day = selected.day;
      month = selected.month;
      year = selected.year;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openPicker,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${day.toString().padLeft(2, '0')}/${months[month - 1]}/$year",
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    );
  }

  void _openPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: 320,
          child: Column(
            children: [
              // HEADER
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const Text(
                      "Select Birthday",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onChanged(DateTime(year, month, day));
                        Navigator.pop(context);
                      },
                      child: const Text("Done"),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: Stack(
                  children: [
                    // CENTER HIGHLIGHT
                    Center(
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    Row(
                      children: [
                        // MONTH
                        _picker(
                          items: months,
                          index: month - 1,
                          onChanged: (v) => _updateDate(day, v + 1, year),
                        ),

                        // DAY
                        _picker(
                          items: List.generate(
                            daysInMonth,
                            (i) => (i + 1).toString().padLeft(2, '0'),
                          ),
                          index: day - 1,
                          onChanged: (v) => _updateDate(v + 1, month, year),
                        ),

                        // YEAR
                        _picker(
                          items: List.generate(
                            70,
                            (i) => (1960 + i).toString(),
                          ),
                          index: year - 1960,
                          onChanged: (v) => _updateDate(day, month, 1960 + v),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _picker({
    required List<String> items,
    required int index,
    required Function(int) onChanged,
  }) {
    return Expanded(
      child: CupertinoPicker(
        itemExtent: 36,
        scrollController: FixedExtentScrollController(initialItem: index),
        onSelectedItemChanged: onChanged,
        children: items
            .map(
              (e) => Center(
                child: Text(
                  e,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
