import 'package:flutter/material.dart';
import '../paper_details/paper_detail_screen.dart';

class ConfirmationDialogScreen extends StatelessWidget {
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
  }) :
        super(key: key);

  void _navigateToPaperDetailScreen(BuildContext context) {
    // Navigate to PaperDetailScreen with only paperId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaperDetailScreen(
          paperId: paperId, // Pass only the paperId
        ),
      ),
    );
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
            "* Do you want to start the $paperName? \n* You will have to complete $questionCount in $duration",
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
              onPressed: () {
                _navigateToPaperDetailScreen(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
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
