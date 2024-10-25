import 'package:flutter/material.dart';
import 'Menu bar/menu_bar.dart'; // Import the renamed menu bar
import 'Category/esp_guids.dart'; // Import page for Eps Guide
import 'Category/korean_standard_book.dart'; // Import page for Korean Standard Book
import 'Category/category.dart'; // Import page for Category
import 'Category/learning_communication.dart'; // Import page for Learning Communication
import 'Category/korean_culture_info.dart'; // Import page for Korean Culture & Information
import 'Category/computer.dart'; // Import page for Computer

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Create a global key

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = (MediaQuery.of(context).size.width / 2) - 24; // Ensure buttons are the same width

    return Scaffold(
      key: _scaffoldKey, // Assign the key to the Scaffold
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(180.0), // Height for the AppBar
        child: ClipPath(
          clipper: DoubleCurvedAppBarClipper(),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue, // Start with blue
                  Colors.red, // Add red
                ], // Gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Full AppBar background color
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.lightBlue, // Blue background
                ),
                // Row for the menu icon and logo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                        onPressed: () {
                          _scaffoldKey.currentState?.openDrawer(); // Use the global key to open the drawer
                        },
                      ),
                      // Logo image
                      Container(
                        width: 120, // Set width for the logo
                        height: 120, // Set height for the logo
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            // Your logo image
                            fit: BoxFit.contain, // Keep aspect ratio
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: AppDrawer(), // Use the AppDrawer class from menu_bar.dart
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Row 1
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Even spacing
              children: [
                _buildCategoryButton(context, 'Eps Guide', 'assets/eps_guide.png', buttonWidth, EspGuidesScreen()),
                _buildCategoryButton(context, 'Korean Standard Book', 'assets/korean_standard_book.png', buttonWidth, KoreanStandardBookScreen()),
              ],
            ),
            const SizedBox(height: 20),
            // Row 2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Even spacing
              children: [
                _buildCategoryButton(context, 'Category', 'assets/category.png', buttonWidth, CategoryScreen()),
                _buildCategoryButton(context, 'Learning Communication', 'assets/learning_communication.png', buttonWidth, LearningCommunicationScreen()),
              ],
            ),
            const SizedBox(height: 20),
            // Row 3
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Even spacing
              children: [
                _buildCategoryButton(context, 'Korean Culture & Info', 'assets/korean_culture_info.png', buttonWidth, KoreanCultureInfoScreen()),
                _buildCategoryButton(context, 'Computer', 'assets/computer.png', buttonWidth, ComputerScreen()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build the category button with a professional design
  Widget _buildCategoryButton(BuildContext context, String title, String imagePath, double width, Widget screen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        width: width,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16), // Rounded corners
          gradient: const LinearGradient(
            colors: [Colors.white, Colors.white],
            // Gradient background
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Subtle shadow for depth
              blurRadius: 10, // Soft blur
              spreadRadius: 3,
              offset: const Offset(0, 5), // Slight elevation effect
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Button Icon/Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Button Label
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // White text for contrast
              ),
              textAlign: TextAlign.center,
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
