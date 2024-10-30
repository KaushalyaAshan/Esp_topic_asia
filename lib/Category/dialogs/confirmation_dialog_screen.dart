import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../paper_details/paper_detail_screen.dart';

class ConfirmationDialogScreen extends StatefulWidget {
  final String paperName;
  final String questionCount;
  final String duration;
  final String paperId;

  const ConfirmationDialogScreen({
    required this.paperName,
    required this.questionCount,
    required this.duration,
    required this.paperId,
    Key? key,
  }) : super(key: key);

  @override
  _ConfirmationDialogScreenState createState() => _ConfirmationDialogScreenState();
}

class _ConfirmationDialogScreenState extends State<ConfirmationDialogScreen> {
  bool _isLoading = false;

  Future<void> _fetchPaperDetails() async {
    final url = Uri.parse('https://epstopik.asia/api/get-paper/11');//${widget.paperId}

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(url);
      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final paperDetails = json.decode(response.body);

        if (paperDetails is List) {
          print('00000000000asdfghjkkjhgfdssdfghjklkjhgfdssdfghjklkjhfdssdfghjklkjhgfdsasdfghjk');
          // Assuming the list contains the questions directly
          List<dynamic> paperQuestions = paperDetails;
          Navigator.push(
            context,
            MaterialPageRoute(

              builder: (context) => PaperDetailScreen(
                paperName: widget.paperName,
                questions: paperQuestions.map((q) => Question.fromJson(q)).toList(),

              ),
            ),
          );
        } else if (paperDetails is Map && paperDetails.containsKey('questions')) {
          print('1234567asdfghjkkjhgfdssdfghjklkjhgfdssdfghjklkjhfdssdfghjklkjhgfdsasdfghjk');
          // If it’s a Map, access the 'questions' field directly
          List<dynamic> paperQuestions = paperDetails['questions'];
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
          print('Error: Unexpected response format.');
          throw Exception('Invalid response format');
        }
      } else {
        print('Error response body: ${response.body}');
        throw Exception('Failed to load paper details');
      }
    } catch (e) {
      print('Error fetching paper details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching paper details: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
                Navigator.of(context).pop();
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
                  ? null
                  : () async {
                await _fetchPaperDetails();
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
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
