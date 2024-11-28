import 'package:asp_topic_asia/Category/paper_details/report_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:just_audio/just_audio.dart';

class PaperDetailScreen extends StatefulWidget {
  final String paperId;
  final String paperName;

  const PaperDetailScreen({
    required this.paperId,
    required this.paperName,
    Key? key,
  }) : super(key: key);

  @override
  _PaperDetailScreenState createState() => _PaperDetailScreenState();
}

extension ListFiller<T> on List<T?> {
  void setOrFill(int index, T value) {
    if (index >= this.length) {
      this.addAll(List<T?>.filled(index - this.length + 1, null));
    }
    this[index] = value;
  }
}

extension ListFiller1<T> on List<T?> {
  void setAnswer(int index, T value) {
    if (index >= this.length) {
      this.addAll(List<T?>.filled(index - this.length + 1, null));
    }
    this[index] = value;
  }
}

class _PaperDetailScreenState extends State<PaperDetailScreen> {
  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isAnswerSelected = false;
  int? _selectedAnswerIndex;
  double marks = 0.0;
  int count_question = 0;
  final player = AudioPlayer();
  List<String?> myAnswer = [];
  List<String?> currectAnswers = [];
  bool _isPlaying = false;

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

  void _nextQuestion() async {
    if (_selectedAnswerIndex != null) {
      String correctAnswer = obj[0]['Questions'][_currentQuestionIndex]['correct_answer'].toString();
      String selectedAnswer = obj[0]['Questions'][_currentQuestionIndex]['answers'][_selectedAnswerIndex!]['no'].toString();

      myAnswer.setOrFill(count_question, selectedAnswer);
      currectAnswers.setAnswer(count_question, correctAnswer);
      count_question += 1;
      double mark = obj[0]["mark"];
      if (correctAnswer == selectedAnswer) {
        marks += mark;
      }
    }

    // Stop audio playback before moving to the next question
    if (_isPlaying) {
      await player.stop();
      setState(() {
        _isPlaying = false;
      });
    }

    if (_currentQuestionIndex < obj[0]['Questions'].length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _isAnswerSelected = false;
        _selectedAnswerIndex = null;
      });
    } else {
      _showResults();
    }
  }

  void _previousQuestion() async {
    if (_isPlaying) {
      await player.stop();
      setState(() {
        _isPlaying = false;
      });
    }

    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _isAnswerSelected = false;
        _selectedAnswerIndex = null;
      });
    }
  }

  Future<void> _toggleAudio(String url) async {
    try {
      if (_isPlaying) {
        await player.pause();
      } else {
        await player.setUrl(url);
        await player.play();
      }
      setState(() {
        _isPlaying = !_isPlaying;
      });
    } catch (e) {
      print('Audio error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not play audio.')),
      );
    }
  }

  void _showResults() {
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
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReportScreen(
                    paperName: widget.paperName,
                    correctAnswers: currectAnswers,
                    selectedAnswers: myAnswer,
                    marks: marks,
                    paperId: widget.paperId,
                  ),
                ),
              );
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

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
  // Future<void> _toggleAudio(String url) async {
  //   try {
  //     if (_isPlaying) {
  //       await player.pause();
  //     } else {
  //       await player.setUrl(url);
  //       await player.play();
  //     }
  //     setState(() {
  //       _isPlaying = !_isPlaying;
  //     });
  //   } catch (e) {
  //     print('Audio error: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Could not play audio.')),
  //     );
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.paperName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.0,
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
                colors: [Colors.blueAccent, Colors.cyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 4,
          shadowColor: Colors.black54,
          actions: [
            IconButton(
              icon: Icon(Icons.share),
              color: Colors.white,
              onPressed: () {
                // Implement share functionality
              },
            ),
            IconButton(
              icon: Icon(Icons.save_alt),
              color: Colors.white,
              onPressed: () {
                // Implement save or download functionality
              },
            ),
          ],
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(16.0),
            ),
          ),
        ),

        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (obj[0].isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.paperName}'),
          backgroundColor: Colors.blueAccent,
        ),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 6,
        title: Text(
          '${widget.paperName}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          if (audio.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(
                onTap: () => _toggleAudio(FinalAudio),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Highlighted Box for Question
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                '(${_currentQuestionIndex + 1}) : $questionText',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[900],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Image Section for Question
            if (ImageFinaly != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(
                  ImageFinaly,
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('Could not load image'),
                ),
              ),
            const SizedBox(height: 20),

            // Highlighted Box for Answers
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  final answer = answers[index];
                  final answerImage = answer['Answer_image_url'] != null
                      ? 'https://epstopik.asia/file/${answer['Answer_image_url']}'
                      : null;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Card(
                      color: _selectedAnswerIndex == index
                          ? Colors.lightBlue.shade100
                          : Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _selectedAnswerIndex == index
                              ? Colors.blueAccent
                              : Colors.grey.shade300,
                          child: Text(
                            (index + 1).toString(),
                            style: TextStyle(
                              color: _selectedAnswerIndex == index
                                  ? Colors.white
                                  : Colors.blueGrey,
                            ),
                          ),
                        ),


                        title: Text(
                          answer['Answer'] ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey[800],
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            _selectedAnswerIndex = index;
                            _isAnswerSelected = true;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Buttons for Next and Previous
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ElevatedButton(
                  onPressed: _isAnswerSelected ? _nextQuestion : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

    );
  }
}
