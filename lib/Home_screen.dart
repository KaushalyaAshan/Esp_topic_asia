import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Category/Registation/register_screen.dart';
import 'Menu bar/menu_bar.dart'; // Import the renamed menu bar
import 'Category/esp_guids.dart'; // Import page for Eps Guide
import 'Category/korean_standard_book.dart'; // Import page for Korean Standard Book
import 'Category/category.dart'; // Import page for Category
import 'Category/learning_communication.dart'; // Import page for Learning Communication
import 'Category/korean_culture_info.dart'; // Import page for Korean Culture & Information
import 'Category/computer.dart'; // Import page for Computer
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<
      ScaffoldState>(); // Create a global key
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
        body: json.encode(
            {'user_id': userId}), // Assuming 'user_id' is the expected key
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

  _handleStartButton(BuildContext context) async {
    final isRegistered = await _checkRegistration();

    if (isRegistered == 1) {
      // _navigateToPaperDetailScreen(context);
      KoreanStandardBookScreen();
    } else if (isRegistered == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const RegisterScreen(
                paperName: "Sample Paper",
                paperId: '1',
              ),
        ),
      );
      //_showRegisterMessageBox(context);
    } else {
      _showNoMoneyAlert(context);
    }
  }

  void _showNoMoneyAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                25), // More rounded corners for a smooth, modern look
          ),
          backgroundColor: Colors.lightBlue,
          // Clean white background
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
                  color: Colors.white, // White color for the icon
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'Insufficient Funds',
                  style: TextStyle(
                    fontSize: 24, // Slightly larger font size for the title
                    fontWeight: FontWeight.w600, // Bold for emphasis
                    color: Colors.white, // White text color for better contrast
                  ),
                ),
              ],
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            // More vertical padding for better spacing
            child: Text(
              'You do not have enough funds to proceed with this action. Please add funds to continue.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Darker text for better readability
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              // Add more padding at the bottom
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Red button background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        12), // Round button corners for consistency
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0,
                      vertical: 14.0), // More padding for a larger button
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = (MediaQuery.of(context).size.width * 0.9); // Button width is 90% of the screen width

    return DefaultTabController(
        length: 2, // Number of tabs
        child: Scaffold(
          key: _scaffoldKey, // Assign the key to the Scaffold
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(250.0), // Increased height for the AppBar with TabBar
            child: ClipPath(
              clipper: DoubleCurvedAppBarClipper(),
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/computer.png'), // Background image
                    fit: BoxFit.cover, // Ensure the image covers the entire AppBar area
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 16.0, left: 16.0, right: 16.0), // Adjust padding
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        // Distribute space evenly
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Align children at the top
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                            onPressed: () {
                              _scaffoldKey.currentState?.openDrawer(); // Open drawer
                            },
                          ),
                          Expanded(child: Container()),
                          // Spacer to push the logo to the right
                          Image.asset(
                            'assets/logo.png', // Replace with your logo path
                            width: 120, // Adjust the width of the logo
                            height: 60, // Adjust the height of the logo
                            fit: BoxFit.contain, // Maintain aspect ratio
                          ),
                        ],
                      ),
                    ),
                    const TabBar(
                      labelColor: Colors.white, // Active tab text color
                      unselectedLabelColor: Colors.white60, // Dim inactive tab text color
                      indicatorColor: Colors.white, // White underline for the active tab
                      indicatorWeight: 3, // Thicker underline for active tab
                      tabs: [
                        Tab(
                          icon: Icon(Icons.library_books, color: Colors.white, size: 28),
                          child: Text(
                            "Papers",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Tab(
                          icon: Icon(Icons.question_answer, color: Colors.white, size: 28),
                          child: Text(
                            "Answers",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
    drawer: AppDrawer(),// Use the AppDrawer class from menu_bar.dart
      body: SingleChildScrollView( // Wrap the body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center content
            crossAxisAlignment: CrossAxisAlignment.stretch, // Ensure buttons span full width
            children: [
              // Button for EPS Model Papers
              Center(
                child: _buildCategoryButton(
                  context,
                  'Eps Model Papers',
                  'assets/eps_guide.png',
                  buttonWidth,
                  EspGuidesScreen(),
                ),
              ),
              const SizedBox(height: 20), // Equal spacing
              Center(
                child: _buildCategoryButton(
                  context,
                  'Korean Standard Book',
                  'assets/eps_guide.png',
                  buttonWidth,
                    KoreanStandardBookScreen(),
                ),
              ),
              const SizedBox(height: 20),

              // Button for Category
              Center(
                child: _buildCategoryButton(
                  context,
                  'Category',
                  'assets/category.png',
                  buttonWidth,
                  CategoryScreen(),
                ),
              ),
              const SizedBox(height: 20), // Equal spacing

              // Button for Learning Communication
              Center(
                child: _buildCategoryButton(
                  context,
                  'Learning Communication',
                  'assets/learning_communication.png',
                  buttonWidth,
                  LearningCommunicationScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    )
    );
  }

  // Build the category button with a professional design
  // Build the category button with an updated design
  Widget _buildCategoryButton(BuildContext context, String title,
      String imagePath, double width, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: width,
        height: 120, // Adjusted height for a more compact row layout
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Rounded corners for the button
          gradient: const LinearGradient(
            colors: [
              Color(0xFFE3F2FD), // Very light blue (near white)
              Color(0xFF90CAF9), // A slightly deeper soft blue
            ], // Gradient colors
            begin: Alignment.bottomLeft,
            end: Alignment.topLeft,
          ),
          border: Border.all(
            color: Colors.cyan.shade50, // Border color
            width: 2, // Border width
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Subtle shadow for depth
              blurRadius: 6, // Softer blur
              spreadRadius: 2,
              offset: const Offset(0, 3), // Slight elevation effect
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image in the first column
            Container(
              width: 60,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 12),
              // Add spacing around the image
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                // Rounded corners for the image
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6, // Softer blur
                    spreadRadius: 1,
                  ),
                ],
                border: Border.all(color: Colors.blue.withOpacity(0.3),
                    width: 2), // Border around the image
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                // Smooth corners for the image
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover, // Adjust image fit
                ),
              ),
            ),

            // Text in the second column
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Black text for better contrast
                ),
                textAlign: TextAlign.left, // Align text to the left
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Custom clipper for the double-sided curved AppBar
class DoubleCurvedAppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    // Start the path from the left
    path.lineTo(0, size.height - 40); // Line to bottom of the left side
    path.quadraticBezierTo(size.width / 4, size.height + 30, size.width / 2, size.height - 40); // Left curve

    // Right curve
    path.quadraticBezierTo(size.width * 3 / 4, size.height - 100, size.width, size.height - 40); // Right curve

    // Complete the path
    path.lineTo(size.width, 0); // Draw to the top right corner
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}