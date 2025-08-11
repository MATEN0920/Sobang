import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/user_points.dart';

class QuizMissionScreen extends StatefulWidget {
  const QuizMissionScreen({super.key});

  @override
  State<QuizMissionScreen> createState() => _QuizMissionScreenState();
}

class _QuizMissionScreenState extends State<QuizMissionScreen> {
  List<Map<String, dynamic>> quizList = [];
  int currentIndex = 0;
  int score = 0;
  int? selectedOption;

  @override
  void initState() {
    super.initState();
    loadQuizData();
  }

  Future<void> loadQuizData() async {
    final String response = await rootBundle.loadString('assets/quiz.json');
    setState(() {
      quizList = List<Map<String, dynamic>>.from(json.decode(response));
    });
  }

  void _checkAnswer(int index) {
    setState(() {
      selectedOption = index;
      if (index == quizList[currentIndex]['answerIndex']) {
        score++;
      }
    });
  }

  void _nextQuestion() {
    setState(() {
      currentIndex++;
      selectedOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentIndex >= quizList.length) {
      // 결과 화면
      UserPoints.add(100); // 퀴즈 미션 완료 시 100포인트 지급
      return Scaffold(
        appBar: AppBar(title: Text("퀴즈 결과")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("총 점수: $score / ${quizList.length}", style: TextStyle(fontSize: 24)),
              const SizedBox(height: 16),
              Text("미션 완료! +100P 지급", style: TextStyle(fontSize: 18, color: Colors.green)),
            ],
          ),
        ),
      );
    }

    final quiz = quizList[currentIndex];
    return Scaffold(
      appBar: AppBar(title: Text("안전 퀴즈 미션")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Q${currentIndex + 1}. ${quiz['question']}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 24),
            ...List.generate(quiz['options'].length, (i) {
              return ListTile(
                title: Text(quiz['options'][i]),
                leading: Radio<int>(
                  value: i,
                  groupValue: selectedOption,
                  onChanged: selectedOption == null ? (val) => _checkAnswer(i) : null,
                ),
                tileColor: selectedOption != null
                  ? (i == quiz['answerIndex']
                      ? Colors.green.withOpacity(0.2)
                      : (i == selectedOption ? Colors.red.withOpacity(0.2) : null))
                  : null,
              );
            }),
            SizedBox(height: 24),
            if (selectedOption != null)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: Text(currentIndex < quizList.length - 1 ? "다음 문제" : "결과 보기"),
              ),
          ],
        ),
      ),
    );
  }
}