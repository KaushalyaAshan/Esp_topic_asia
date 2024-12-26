import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';
import '../../Homepage.dart';

class ReportScreen extends StatefulWidget {
  final List<dynamic> correctAnswers;
  final List<dynamic> selectedAnswers;
  final String paperName;
  final double marks;
  final String paperId;

  const ReportScreen({
    required this.correctAnswers,
    required this.selectedAnswers,
    required this.paperName,
    required this.marks,
    required this.paperId,
    Key? key,
  }) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  List<dynamic> _questions = [];
  bool _isLoading = true;
  late AudioPlayer _audioPlayer;
  int? _playingIndex; // Track the currently playing audio's index

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    fetchPaper();
  }

  Future<void> fetchPaper() async {
    final url = Uri.parse('https://epstopik.asia/api/get-paper/${widget.paperId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _questions = jsonDecode(response.body)[0]['Questions'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load paper');
      }
    } catch (e) {
      print('Error fetching papers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleAudio(String audioUrl, int index) async {
    if (_playingIndex == index) {
      await _audioPlayer.pause();
      setState(() => _playingIndex = null);
    } else {
      await _audioPlayer.setUrl(audioUrl);
      _audioPlayer.play();
      setState(() => _playingIndex = index);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.paperName}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.paperName}')),
        body: const Center(child: Text('No questions available.')),
      );
    }
    double abc=widget.marks;
    double ans=abc/2.5;
    return Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.home,
          color: Colors.white, // Ensures the icon color is white
          size: 28, // Slightly larger icon for emphasis
        ),
        tooltip: 'Go to Home',
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => EspGuidesScreen()),
          );
        },
      ),
      title: Text(
        'Exam Report - ${widget.paperName}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          shadows: [
            Shadow(
              blurRadius: 5.0,
              color: Colors.black26,
              offset: Offset(1.5, 1.5),
            ),
          ],
        ),
      ),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1565C0), // A darker blue
              Color(0xFF42A5F5), // A lighter blue
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 3),
              blurRadius: 5.0,
            ),
          ],
        ),
      ),
      elevation: 4,
      actions: [
        // Add your icons or buttons here if needed
      ],
    ),

    body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Marks Display Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                     Text(
                      "Total Marks = ${widget.marks}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Correct Answer = ${ans.toInt()}', // Display total marks with formatting
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Questions List
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    final questionText = question['Questions_content'] ?? 'No question content available';
                    final imageUrl = question['image_url'] ?? '';
                    final audioTrack = question['audio_track'] ?? '';
                    final answers = question['answers'] ?? [];
                    final correctAnswer = widget.correctAnswers[index];
                    final selectedAnswer = widget.selectedAnswers[index];
                    final finalAudio = 'https://epstopik.asia/file/$audioTrack';
                    final imageFinal = imageUrl.isNotEmpty ? 'https://epstopik.asia/file/$imageUrl' : null;
                    final isCorrect = correctAnswer == selectedAnswer;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Question ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                questionText,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(imageFinal!, fit: BoxFit.cover),
                                ),
                              if (audioTrack.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: GestureDetector(
                                    onTap: () => _toggleAudio(finalAudio, index),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.blueAccent.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Icon(
                                        _playingIndex == index ? Icons.pause : Icons.play_arrow,
                                        color: Colors.blueAccent,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 12),
                              // Grid layout for answers
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                ),
                                itemCount: answers.length,
                                itemBuilder: (context, answerIndex) {
                                  final answer = answers[answerIndex];
                                  final isSelected = selectedAnswer.toString() == answer['no'].toString();
                                  final isAnswerCorrect = correctAnswer.toString() == answer['no'].toString();
                                  final answerImageUrl = answer['Answer_image_url'];
                                  final indexLabel = (answerIndex + 1).toString();

                                  return Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: isAnswerCorrect
                                          ? Colors.green.withOpacity(0.25)
                                          : isSelected
                                          ? Colors.red.withOpacity(0.25)
                                          : Colors.transparent,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '$indexLabel',
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueGrey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          if (answerImageUrl != null && answerImageUrl.isNotEmpty)
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                'https://epstopik.asia/file/$answerImageUrl',
                                                fit: BoxFit.contain,
                                                height: 50,
                                              ),
                                            )
                                          else
                                            Expanded(
                                              child: Text(
                                                answer['Answer'] ?? '',
                                                style: TextStyle(
                                                  color: isAnswerCorrect
                                                      ? Colors.green
                                                      : isSelected
                                                      ? Colors.red
                                                      : Colors.black,
                                                  fontWeight: isAnswerCorrect
                                                       ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        )
    );
  }
}
