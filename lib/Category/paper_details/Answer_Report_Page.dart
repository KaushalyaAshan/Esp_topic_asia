import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../../Homepage.dart';
class AnswerReportPage extends StatefulWidget {
  final String markId; // User's mark ID for answers
  final String paperId; // Paper ID to fetch questions

  const AnswerReportPage({
    Key? key,
    required this.markId,
    required this.paperId,
  }) : super(key: key);

  @override
  State<AnswerReportPage> createState() => _AnswerReportPageState();
}
class _AnswerReportPageState extends State<AnswerReportPage> {
  late Future<List<dynamic>> _paperQuestionsFuture;
  late Future<List<dynamic>> _userAnswersFuture;
  late AudioPlayer _audioPlayer;
  int? _playingIndex; // Tracks the currently playing audio's index

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _paperQuestionsFuture = fetchPaperQuestions();
    _userAnswersFuture = fetchAnswerData();
  }
  var data;
  Future<List<dynamic>> fetchPaperQuestions() async {
    final response = await http.get(
      Uri.parse('https://epstopik.asia/api/get-paper/${widget.paperId}'),
    );
    if (response.statusCode == 200) {
       data = json.decode(response.body);
      print(data[0]['Questions']);
      if (data[0]['Questions'] != null && data[0]['Questions'] is List) {
        return data[0]['Questions'];
        print(data[0]['Questions']);
      } else {
        throw Exception('Invalid data format for questions');
      }
    } else {
      throw Exception('Failed to load paper questions');
    }
  }
  Future<List<dynamic>> fetchAnswerData() async {
    final response = await http.get(
      Uri.parse('https://epstopik.asia/api/get-answers/${widget.markId}'),
    );
    if (response.statusCode == 200) {
      final answerData = json.decode(response.body);
      print(answerData['answers'][0]['answers']['answers']);
      if (answerData is Map<String, dynamic> && answerData['answers'] is List) {
        return answerData['answers'][0]['answers']['answers'];
      } else {
        throw Exception('Invalid answer data format');
      }
    } else {
      throw Exception('Failed to load answers');
    }
  }
  Future<void> _toggleAudio(String audioUrl, int index) async {
    if (_playingIndex == index) {
      await _audioPlayer.pause();
      setState(() => _playingIndex = null);
    } else {
      await _audioPlayer.setUrl(audioUrl);
      await _audioPlayer.play();
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
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.home,
              color: Colors.white,
              size: 28,
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
            'EPS-TOPIK MODAL PAPERS ${widget.paperId}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                ],
              ),
            ),
          ),
          elevation: 6,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _paperQuestionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading questions: ${snapshot.error}',
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No questions found for this paper.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }

          final paperQuestions = snapshot.data!;
          return FutureBuilder<List<dynamic>>(
            future: _userAnswersFuture,
            builder: (context, answerSnapshot) {
              if (answerSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (answerSnapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading answers: ${answerSnapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else if (!answerSnapshot.hasData || answerSnapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No answer data found.',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                );
              }

              final userAnswers = answerSnapshot.data!;
              return ListView.builder(
                itemCount: paperQuestions.length,
                itemBuilder: (context, index) {
                  final question = paperQuestions[index];
                  final questionNo = question['Questions_no']?.toString() ?? '';
                  final imageUrl = question['image_url'] ?? '';
                  final audioTrack = question['audio_track'] ?? '';
                  final audioUrl =
                  audioTrack.isNotEmpty ? 'https://epstopik.asia/file/$audioTrack' : null;
                  final imageFinal = imageUrl.isNotEmpty
                      ? 'https://epstopik.asia/file/$imageUrl'
                      : null;

                  final userAnswer = userAnswers.firstWhere(
                        (ans) => ans['questionNo']?.toString() == questionNo,
                    orElse: () => <String, dynamic>{},
                  );
print(userAnswer);
print( question['correct_answer']);
                  final isCorrect = userAnswer.isNotEmpty &&
                      userAnswer['answer']?.toString() ==
                          question['correct_answer']?.toString();

                  return Card(
                    margin: const EdgeInsets.all(12),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Question $questionNo: ${question['Questions_content'] ?? ''}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (imageFinal != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                imageFinal,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                          if (audioUrl != null) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () => _toggleAudio(audioUrl, index),
                              icon: Icon(
                                _playingIndex == index ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              label: Text(
                                _playingIndex == index ? 'Pause Audio' : 'Play Audio',
                                style: const TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[800],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(
                              question['answers'].length,
                                  (answerIndex) {
                                final answer = question['answers'][answerIndex];
                                final isSelected = userAnswer['answer']?.toString() ==
                                    answer['no']?.toString();
                                final isAnswerCorrect = question['correct_answer']
                                    ?.toString() ==
                                    answer['no']?.toString();
                                final answerImageUrl = answer['Answer_image_url'];
                                final indexLabel = (answerIndex + 1).toString();

                                return Container(
                                  width: (MediaQuery.of(context).size.width - 64) / 2,
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isAnswerCorrect
                                        ? Colors.green.withOpacity(0.25)
                                        : isSelected
                                        ? Colors.red.withOpacity(0.25)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isAnswerCorrect
                                          ? Colors.green
                                          : isSelected
                                          ? Colors.red
                                          : Colors.grey[200]!,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        indexLabel,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      if (answerImageUrl != null &&
                                          answerImageUrl.isNotEmpty)
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            'https://epstopik.asia/file/$answerImageUrl',
                                            fit: BoxFit.contain,
                                            height: 50,
                                          ),
                                        )
                                      else
                                        Text(
                                          answer['Answer'] ?? '',
                                          style: TextStyle(
                                            fontWeight: isAnswerCorrect
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

}
