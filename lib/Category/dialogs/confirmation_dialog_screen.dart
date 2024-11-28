import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../paper_details/paper_detail_screen.dart';
import '../Registation/register_screen.dart'; // Import the RegisterScreen

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
  }) : super(key: key);
  Future<int> _checkRegistration() async {
    // Get the user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(
        "Device_id"); // Ensure the key is 'user_id'
    final url = Uri.parse('https://epstopik.asia/api/user-details');

    try {
      // Send POST request with the user ID
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}), // Assuming 'user_id' is the expected key
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
          print(data['payment']);
        // Check the 'payment' value
        // if (data['payment'] == 1) {
        //   return true; // Payment is valid
        // } else {
        //   return false; // Payment is invalid
        // }
        return 1;//data['payment'];
      } else {
        // Log response error for debugging
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
        return -1;
      }
    } catch (error) {
      // Log exception
      print("Error checking registration: $error");
      return -1;
    }
  }
  // Future<bool> _checkRegistration() async {
  //   final String userId = "unique_user_id"; // Replace with actual user ID logic
  //   final url = Uri.parse('https://epstopik.asia/api/register');
  //
  //   try {
  //     final response = await http.get(
  //       url,
  //       headers: {'Authorization': 'Bearer $userId'},
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       // Assume the API returns { "registered": true/false }
  //       return data['registered'] ?? false;
  //     } else {
  //       return false;
  //     }
  //   } catch (error) {
  //     print("Error checking registration: $error");
  //     return false;
  //   }
  // }
  void _showRegisterMessageBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade100, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.info_rounded,
                size: 50,
                color: Colors.white,
              ),
              const SizedBox(height: 15),
              const Text(
                'Registration Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'You need to register before starting the paper. Please complete your registration to proceed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterScreen(
                            paperName: paperName,
                            paperId: paperId,
                          ),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                    ),
                    child: const Text(
                      'Register Now',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  void _navigateToPaperDetailScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaperDetailScreen(
          paperName: paperName,
          paperId: paperId,
        ),
      ),
    );
  }
  void _showNoMoneyAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          backgroundColor: Colors.white, // Background color
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30), // Icon
              SizedBox(width: 10),
              Text(
                'No Money',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Title text color
                ),
              ),
            ],
          ),
          content: Text(
            'You do not have sufficient funds to proceed.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[800], // Subtle text color
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Button background color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Button shape
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white, // Button text color
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  void _handleStartButton(BuildContext context) async {
    final isRegistered = await _checkRegistration();

    if (isRegistered==1) {
      _navigateToPaperDetailScreen(context);
    } else if (isRegistered==0) {
      _showRegisterMessageBox(context);
    }
    else{
      //Navigator.of(context).pop();
      _showNoMoneyAlert(context);

    }

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade100, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.play_circle_fill_rounded,
                  size: 60,
                  color: Colors.white,
                ),

                const SizedBox(height: 15),
                const Text(
                  "Get Ready!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "* Do you want to start the $paperName? \n* You will have to complete $questionCount in $duration.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        "No",
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _handleStartButton(context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text(
                        "Yes, Start",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

