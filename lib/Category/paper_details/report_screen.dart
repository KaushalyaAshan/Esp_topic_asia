import 'package:flutter/material.dart';
// Question Model
class Question {
  final String questionText;
  final String? questionImage; // Optional question image
  final String? questionAudio; // Optional question audio
  final List<String> answers;
  final int correctAnswerIndex;
  final bool isImageAnswer;

  Question({
    required this.questionText,
    this.questionImage,
    this.questionAudio,
    required this.answers,
    required this.correctAnswerIndex,
    this.isImageAnswer = false,
  });

  static fromJson(q) {}
}// Report Screen
class ReportScreen extends StatelessWidget {
  final List<Question> questions;
  final List<int?> userAnswers;

  ReportScreen({required this.questions, required this.userAnswers});

  @override
  Widget build(BuildContext context) {
    // Calculate the number of correct answers
    int correctAnswers = 0;
    for (int i = 0; i < questions.length; i++) {
      if (userAnswers[i] == questions[i].correctAnswerIndex) {
        correctAnswers++;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Quiz Report"),
        backgroundColor: Colors.blueAccent,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: Colors.blueAccent,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      "Your Performance",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "You answered $correctAnswers out of ${questions.length} questions correctly.",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detailed Report List
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  bool isCorrect = userAnswers[index] == questions[index].correctAnswerIndex;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Text
                          Text(
                            'Q${index + 1}: ${questions[index].questionText}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Answers Display
                          Column(
                            children: List.generate(questions[index].answers.length, (answerIndex) {
                              bool isSelectedAnswer = userAnswers[index] == answerIndex;
                              bool isCorrectAnswer = answerIndex == questions[index].correctAnswerIndex;

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5.0),
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: isCorrectAnswer
                                      ? Colors.green.withOpacity(0.3) // Highlight correct answer in green
                                      : isSelectedAnswer
                                      ? Colors.red.withOpacity(0.3) // Highlight wrong answer in red
                                      : Colors.white, // Normal background for other answers
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelectedAnswer
                                        ? isCorrectAnswer
                                        ? Colors.green
                                        : Colors.red
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: questions[index].isImageAnswer
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8.0),
                                        child: Image.asset(
                                          questions[index].answers[answerIndex],
                                          height: 80,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                          : Text(
                                        questions[index].answers[answerIndex],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isCorrectAnswer
                                              ? Colors.green
                                              : isSelectedAnswer
                                              ? Colors.red
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    if (isCorrectAnswer)
                                      const Icon(Icons.check_circle, color: Colors.green),
                                    if (isSelectedAnswer && !isCorrectAnswer)
                                      const Icon(Icons.cancel, color: Colors.red),
                                  ],
                                ),
                              );
                            }
                            ),
                          ),
                          const Divider(color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
