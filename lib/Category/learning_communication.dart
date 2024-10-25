import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing JSON
import 'dialogs/confirmation_dialog_screen.dart';
import '../Menu bar/menu_bar.dart';
class LearningCommunicationScreen extends StatefulWidget {
  @override
  _LearningCommunicationScreenState createState() => _LearningCommunicationScreenState();
}

class _LearningCommunicationScreenState extends State<LearningCommunicationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _papers = [];  // Store paper data
  bool _isLoading = true;  // Control loading state

  @override
  void initState() {
    super.initState();
    _fetchPapers();  // Fetch the data on initialization
  }
  Future<void> _fetchPapers() async {
    final url = Uri.parse('https://epstopik.asia/api/get-all-eps-papers');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          _papers = json.decode(response.body); // Parse the JSON response
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true, // Centers the title in the app bar
        title: const Text(
          'Learning Communication',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, // Slightly larger font for emphasis
            color: Colors.white, // White text for contrast
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white), // White icon for contrast
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer menu
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.redAccent], // Smooth gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 6, // Slightly higher elevation for a bolder shadow
        shadowColor: Colors.grey.withOpacity(0.5), // Softer shadow effect
        toolbarHeight: 55, // Taller toolbar for a more spacious look
      ),
      drawer: AppDrawer(), // The drawer for menu options
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Papers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _papers.length,
                itemBuilder: (context, index) {
                  final paper = _papers[index];
                  return _buildPaperRow(
                    context,
                    paper['paper_name'],
                    'assets/sample_paper.png',  // Replace with your actual image
                    '${paper['questions']} Questions',
                    'Duration: ${paper['mark']} Marks',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Method to build each paper row
  Widget _buildPaperRow(BuildContext context, String paperName, String imagePath, String questionCount, String duration) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Left column with image
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Middle column with paper name and info
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paperName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questionCount,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            duration,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Show the dialog screen
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmationDialogScreen(
                                paperName: paperName,
                                questionCount: questionCount,
                                duration: duration, paperId: '',
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.2),
                          backgroundColor: Colors.transparent,
                        ).copyWith(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.blueAccent;
                              }
                              return Colors.transparent;
                            },
                          ),
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.redAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Container(
                            constraints: const BoxConstraints(
                              minWidth: 80,
                              minHeight: 35,
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              'Start',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
