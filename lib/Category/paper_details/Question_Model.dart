import 'package:flutter/foundation.dart';

// Answer model to represent each answer option
class Answer {
  final int no;
  final String? text;
  final String? imageUrl;

  Answer({
    required this.no,
    this.text,
    this.imageUrl,
  });

  // Factory constructor to create an Answer instance from JSON
  factory Answer.fromJson(Map<String, dynamic> json) {
    return Answer(
      no: json['no'] as int,
      text: json['Answer'] as String?,
      imageUrl: json['Answer_image_url'] as String?,
    );
  }
}

// Question model to represent each question
class Question {
  final int questionNo;
  final String content;
  final String? audioTrack;
  final String? imageUrl;
  final int correctAnswer;
  final List<Answer> answers;

  Question({
    required this.questionNo,
    required this.content,
    this.audioTrack,
    this.imageUrl,
    required this.correctAnswer,
    required this.answers,
  });

  // Factory constructor to create a Question instance from JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionNo: json['Questions_no'] as int,
      content: json['Questions_content'] as String,
      audioTrack: json['audio_track'] as String?,
      imageUrl: json['image_url'] as String?,
      correctAnswer: json['correct_answer'] as int,
      answers: (json['answers'] as List)
          .map((answerJson) => Answer.fromJson(answerJson))
          .toList(),
    );
  }
}
