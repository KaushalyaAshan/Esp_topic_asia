import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../paper_details/paper_detail_screen.dart'; // Import the screen you want to navigate to

class ConfirmationDialogScreen extends StatefulWidget {
  final String paperName;
  final String questionCount;
  final String duration;
  final String paperId; // Add the paper ID

  const ConfirmationDialogScreen({
    required this.paperName,
    required this.questionCount,
    required this.duration,
    required this.paperId, //Pass paper ID to the constructor
    Key? key,
  }) : super(key: key);

  @override
  _ConfirmationDialogScreenState createState() => _ConfirmationDialogScreenState();
}

class _ConfirmationDialogScreenState extends State<ConfirmationDialogScreen> {
  bool _isLoading = false; // To show loading indicator while fetching data

  // Function to fetch paper details
  // Function to fetch paper details
  Future<void> _fetchPaperDetails() async {
    final url = Uri.parse('https://epstopik.asia/api/get-paper/${widget.paperId}');

    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      final response = await http.get(url);
     //print(response);

      if (response.statusCode == 200) {
        final paperDetails = json.decode(response.body);
        List<dynamic> paperQuestions = paperDetails['questions'];
        // Navigate to the PaperDetailScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaperDetailScreen(
              paperName: widget.paperName,
              questions: paperQuestions.map((q) => Question.fromJson(q)).toList(),
            ),
          ),
        );
      } else {
        print('Response status code: ${response.statusCode}');
        print('Response body: ${response.body}'); // Log the response body
        throw Exception('Failed to load paper details');
      }
    } catch (e) {
      print('Error fetching paper details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching paper details: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Stop loading indicator
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Make the background transparent
      body: Center(
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: const Text(
            "Get Ready!",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Text(
            "* Do you want to start the ${widget.paperName}? \n * You will have to complete  ${widget.questionCount} in ${widget.duration} ",
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                "No",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: _isLoading
                  ? null // Disable the button while loading
                  : () async {
                await _fetchPaperDetails(); // Fetch paper details when "Yes, Start" is pressed
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white) // Show loading spinner while fetching
                  : const Text(
                "Yes, Start",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
