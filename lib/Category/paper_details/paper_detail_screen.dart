import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

class PaperDetailScreen extends StatefulWidget {
  final String paperId;

  const PaperDetailScreen({
    required this.paperId,
    Key? key,
  }) : super(key: key);

  @override
  _PaperDetailScreenState createState() => _PaperDetailScreenState();
}

class _PaperDetailScreenState extends State<PaperDetailScreen> {
  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isAnswerSelected = false;
  int? _selectedAnswerIndex;
  double marks = 0.0; // Variable to track the score
 // int correctAnswer=0;
  //int selectedAnswer=10;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchPaper();
  }

  var obj;
  Future<void> fetchPaper() async {
    final url = Uri.parse('https://epstopik.asia/api/get-paper/${widget.paperId}');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          obj = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load papers');
      }
    } catch (e) {
      print('Error fetching papers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _nextQuestion() {
    if (_selectedAnswerIndex != null) {
      // Check if selected answer matches the correct answer
       String correctAnswer = obj[0]['Questions'][_currentQuestionIndex]['correct_answer'].toString();
       String selectedAnswer = obj[0]['Questions'][_currentQuestionIndex]['answers'][_selectedAnswerIndex!]['no'].toString();
      print(correctAnswer);
      print(selectedAnswer);
      if (correctAnswer == selectedAnswer) {
        marks =marks+ 2.5; // Add 2.5 marks if correct
        print('******************************************************* $marks');
      }
    }


    if (_currentQuestionIndex < obj[0]['Questions'].length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerSelected = false;
        _selectedAnswerIndex = null;
      });
    } else {
      // Show final score when all questions are completed
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          title: const Column(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.orangeAccent,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                'Final Score',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Your total marks: $marks%',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _isAnswerSelected = false;
        _selectedAnswerIndex = null;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playAudio(String url) async {
    try {
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      print('Audio error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play audio.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Paper ID: ${widget.paperId}')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (obj[0].isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Paper ID: ${widget.paperId}')),
        body: const Center(child: Text('No questions available.')),
      );
    }

    final currentQuestion = obj[0]['Questions'][_currentQuestionIndex];
    final questionText = currentQuestion['Questions_content'] ?? 'No question content available';
    final answers = currentQuestion['answers'] ?? [];
    final audio = currentQuestion['audio_track'] ?? '';
    final images = currentQuestion['image_url'];
    final FinalAudio = 'https://epstopik.asia/file/$audio';
    final ImageFinaly = images != null && images.isNotEmpty ? 'https://epstopik.asia/file/$images' : null;
    print(FinalAudio);
    print(ImageFinaly);
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam Paper - ${widget.paperId}'),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        actions: [
          // Display audio icon if available
          if (audio.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.play_circle_outline,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => _playAudio(FinalAudio),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display question text
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '(${_currentQuestionIndex + 1}) :  $questionText',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 20),
            // Display images only if available
            if (ImageFinaly != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(
                  ImageFinaly,
                  errorBuilder: (context, error, stackTrace) => Text('Could not load image'),
                ),
              ),

            const SizedBox(height: 20),

            // Display each answer option with index as a button
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _selectedAnswerIndex == index ? Colors.blueAccent : Colors.grey.shade300,
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: _selectedAnswerIndex == index ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          answer['Answer'] ?? 'No answer text available',
                          style: TextStyle(
                            fontSize: 16,
                            color: _selectedAnswerIndex == index ? Colors.blue : Colors.grey.shade800,
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _isAnswerSelected = true;
                            _selectedAnswerIndex = index;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Navigation buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _isAnswerSelected ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isAnswerSelected ? Colors.blueAccent : Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
