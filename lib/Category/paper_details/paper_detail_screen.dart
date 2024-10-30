import 'package:flutter/material.dart';
import '../../Menu bar/menu_bar.dart';

class Question {
  final String questionText;
  final List<String> answers;
  final int correctAnswerIndex;
  final String? questionImage; // For image answers
  final String? questionAudio; // For audio questions
  final bool isImageAnswer; // To check if the answer is an image

  Question({
    required this.questionText,
    required this.answers,
    required this.correctAnswerIndex,
    this.questionImage,
    this.questionAudio,
    this.isImageAnswer = false,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['question_text'],
      answers: List<String>.from(json['answers']),
      correctAnswerIndex: json['correct_answer_index'],
      questionImage: json['question_image'],
      questionAudio: json['question_audio'],
      isImageAnswer: json['is_image_answer'] ?? false,
    );
  }
}
// Main Quiz Screen
class PaperDetailScreen extends StatefulWidget {
  final String paperName;
  final List<Question> questions; // Accept questions list

  PaperDetailScreen({required this.paperName, required this.questions});

  @override
  _PaperDetailScreenState createState() => _PaperDetailScreenState();
}
class _PaperDetailScreenState extends State<PaperDetailScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int currentQuestionIndex = 0;
  int? selectedAnswerIndex; // Tracks the selected answer by the user
  List<int?> userAnswers = []; // Stores the user's answers
  void _nextQuestion() {
    setState(() {
      userAnswers.add(selectedAnswerIndex); // Save the user's answer
      selectedAnswerIndex = null; // Reset for the next question

      if (currentQuestionIndex < widget.questions.length - 1) {
        currentQuestionIndex++;
      } else {
        // Show the report when all questions are completed
        _showReport();
      }
    });
  }
  void _showReport() {
    // Logic to show results after quiz completion (e.g., navigate to report screen)
  }

  @override
  Widget build(BuildContext context) {
    final Question currentQuestion = widget.questions[currentQuestionIndex];

    return Scaffold(
      key: _scaffoldKey, // Assign the GlobalKey to Scaffold
      appBar: AppBar(
        title: Text(
          widget.paperName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2, // Slight letter spacing for a modern look
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 10.0,
        shadowColor: Colors.black45,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop(); // Navigate back
          },
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20.0),
          ),
        ),
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Text(
                'Question ${currentQuestionIndex + 1}: ${currentQuestion.questionText}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),
            // Display question image if available
            if (currentQuestion.questionImage != null)
              Image.network(
                currentQuestion.questionImage!,
                height: 200,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 20),
            // Display answers
            ...currentQuestion.answers.asMap().entries.map((entry) {
              int idx = entry.key;
              String answer = entry.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedAnswerIndex = idx; // Update the selected answer
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: selectedAnswerIndex == idx
                        ? Colors.blueAccent // Highlight selected answer
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    answer,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedAnswerIndex == null ? null : _nextQuestion, // Disable if no answer selected
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'Next Question',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';

class Question {
  final String questionText;
  final List<Answer> answers;
  final int correctAnswerIndex;
  final String? questionImage;
  final String? questionAudio;

  Question({
    required this.questionText,
    required this.answers,
    required this.correctAnswerIndex,
    this.questionImage,
    this.questionAudio,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionText: json['Questions_content'] ?? '',
      correctAnswerIndex: int.parse(json['correct_answer']) - 1,
      questionImage: json['image_url'],
      questionAudio: json['audio_track'],
      answers: (json['answers'] as List)
          .map((answer) => Answer.fromJson(answer))
          .toList(),
    );
  }
}

class Answer {
  final String text;
  final String? imageUrl;

  Answer({required this.text, this.imageUrl});

  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      text: json['Answer'] ?? '',
      imageUrl: json['Answer_image_url'],
    );
  }
}

class PaperDetailScreen extends StatefulWidget {
  final String paperName;
  final List<Question> questions;

  PaperDetailScreen({required this.paperName, required this.questions});

  @override
  _PaperDetailScreenState createState() => _PaperDetailScreenState();
}

class _PaperDetailScreenState extends State<PaperDetailScreen> {
  int currentQuestionIndex = 0;
  int? selectedAnswerIndex;
  List<int?> userAnswers = [];

  void _nextQuestion() {
    setState(() {
      userAnswers.add(selectedAnswerIndex);
      selectedAnswerIndex = null;

      if (currentQuestionIndex < widget.questions.length - 1) {
        currentQuestionIndex++;
      } else {
        _showReport();
      }
    });
  }

  void _showReport() {
    // Show results or navigate to another screen
  }

  @override
  Widget build(BuildContext context) {
    final Question currentQuestion = widget.questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paperName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Question ${currentQuestionIndex + 1}: ${currentQuestion.questionText}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (currentQuestion.questionImage != null)
              Image.network(currentQuestion.questionImage!),
            if (currentQuestion.questionAudio != null)
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  // Play audio functionality here
                },
              ),
            ...currentQuestion.answers.asMap().entries.map((entry) {
              int idx = entry.key;
              Answer answer = entry.value;
              return GestureDetector(
                onTap: () => setState(() {
                  selectedAnswerIndex = idx;
                }),
                child: Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  color: selectedAnswerIndex == idx ? Colors.blue : Colors.white,
                  child: answer.imageUrl != null
                      ? Image.network(answer.imageUrl!)
                      : Text(answer.text),
                ),
              );
            }).toList(),
            ElevatedButton(
              onPressed: selectedAnswerIndex == null ? null : _nextQuestion,
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}

 */