import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Menu bar/menu_bar.dart';
import './dialogs/confirmation_dialog_screen.dart';

class EspGuidesScreen extends StatefulWidget {
  @override
  _EspGuidesScreenState createState() => _EspGuidesScreenState();
}

class _EspGuidesScreenState extends State<EspGuidesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _papers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPapers();
  }

  Future<void> _fetchPapers() async {
    final url = Uri.parse('https://epstopik.asia/api/get-all-eps-papers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _papers = json.decode(response.body);
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
  }// Fetch answers for a specific paper

  Future<List<dynamic>> _fetchAnswers(String paperId) async {
    final url = Uri.parse('https://epstopik.asia/api/get-answers/$paperId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load answers');
      }
    } catch (e) {
      print('Error fetching answers: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Eps Guide',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.redAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6,
        shadowColor: Colors.grey.withOpacity(0.5),
        toolbarHeight: 55,
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select an Option',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AvailablePapersScreen(papers: _papers)),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text(
                'Available Papers',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final answers = await _fetchAnswers('55'); // Hardcoded example paper ID
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnswersScreen(answers: answers)),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.greenAccent,
              ),
              child: const Text(
                'Answers of Paper 55',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvailablePapersScreen extends StatelessWidget {
  final List<dynamic> papers;
  const AvailablePapersScreen({Key? key, required this.papers}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Papers')),
      body: ListView.builder(
        itemCount: papers.length,
        itemBuilder: (context, index) {
          final paper = papers[index];
          return ListTile(
            title: Text(paper['paper_name']),
            subtitle: Text('${paper['questions']} Questions'),
          );
        },
      ),
    );
  }
}

class AnswersScreen extends StatelessWidget {
  final List<dynamic> answers;

  const AnswersScreen({Key? key, required this.answers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Answers')),
      body: ListView.builder(
        itemCount: answers.length,
        itemBuilder: (context, index) {
          final answer = answers[index];
          return ListTile(
            title: Text('Answer ${answer['no']}'),
            subtitle: Text(answer['Answer']),
          );
        },
      ),
    );
  }
}
