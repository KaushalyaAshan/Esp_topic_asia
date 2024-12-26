import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
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
    final userId = prefs.getString("Device_id"); // Ensure the key is 'user_id'
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

        print('******************** ${data['payment']}');
        return data['payment'];
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

  Future<String> _fetchUserDetails() async {
    final url = Uri.parse('https://epstopik.asia/api/user-details');
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("Device_id");

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }

      final response = await http.post(
        url,
        body: {"user_id": userId.toString()},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Telephone'] != null) {
          // Assuming `sentences` is a list of strings from the API response
          return (data['Telephone']);
        } else {
          throw Exception('Sentences not found in API response');
        }
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      debugPrint('Error fetching user details: $e');
      rethrow;
    }
  }


  void _showRegisterMessageBox(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)], // Updated colors
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

  Future<void> _navigateToPaperDetailScreen(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String userId = prefs.getString("Device_id").toString();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaperDetailScreen(
          paperName: paperName,
          paperId: paperId,
          userId: userId,
        ),
      ),
    );
  }

  void _showNoMoneyAlert(BuildContext context, String tele) {
    // Validate and handle a potential null or empty tele value
    String teleform = tele.isNotEmpty ? tele : 'නොදන්නා දුරකථන අංකය'; // Default message if tele is empty

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Smooth rounded corners
          ),
          backgroundColor: Colors.lightBlue, // Dialog background color
          title: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1565C0), // A darker blue
                  Color(0xFF42A5F5), // A lighter blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25), // Match rounded corners
            ),
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white, // Icon color
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'රැදී සිටින්න',
                  style: TextStyle(
                    fontSize: 20, // Adjusted font size for better balance
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text for contrast
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0), // Add padding for spacing
              decoration: BoxDecoration(
                color: Colors.blueAccent, // Inner container background
                borderRadius: BorderRadius.circular(15), // Rounded corners
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text left
                mainAxisSize: MainAxisSize.min, // Minimize unnecessary space
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0), // Space between rows
                    child: Text(
                      'මෙම EPSTOPIC Asia ඇප් එක එක සක්‍රිය කිරීමට ඔබගේ දුරකතනයේ ශේෂය ප්‍රමාණවත් නොවේ.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500, // Semi-bold text
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      '+$teleform ඔබගේ දුරකථන අංකය ට මුදල් දමන්න. (කාඩ් එකකින් හෝ රිලෝඩ් එකක් මගින්).',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Text(
                    'ඉන් පසුව ස්වංක්‍රියව EPSTOPIC Asia ඇප් එක සක්‍රිය වනු ඇත.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SizedBox(
                width: double.infinity, // Make button full-width
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // Round corners
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14.0), // Add vertical padding
                  ),
                  child: const Text(
                    'හරි',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Adjusted font size
                      fontWeight: FontWeight.bold,
                    ),
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


    if (isRegistered == 1) {
      _navigateToPaperDetailScreen(context);
    } else if (isRegistered == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterScreen(
            paperName: paperName,
            paperId: paperId,
          ),
        ),
      );
      //_showRegisterMessageBox(context);
    } else {
      final tele=await _fetchUserDetails();
      print(tele);
      _showNoMoneyAlert(context,tele);
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
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)], // Updated colors
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Replacing static icon with Lottie animation
                // Lottie.asset(
                //   'assets/Animation.json', // assets/Animation.json Path to the Lottie animation file
                //   width: 100,
                //   height: 100,
                //   fit: BoxFit.cover,
                // ),
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
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          side: const BorderSide(
                            color: Colors.white, // Set the border color here
                            width: 2, // Set the border width
                          ),
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
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // void _handleStartButton(BuildContext context) {
  //   // Add your logic for the Start button here
  //   Navigator.of(context).pop(); // Example: Close the dialog
  // }
}
