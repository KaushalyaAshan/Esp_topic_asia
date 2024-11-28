import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 6,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo with Name
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logo.png', // Ensure to add a logo image in assets
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'LearnMe',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Empowering Learners Everywhere',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // About Us Section
            _buildSectionTitle('About Us'),
            const Text(
              'Our app is designed to provide comprehensive exam materials, learning guides, and other educational resources to help students excel in various subjects. Our platform combines cutting-edge technology with personalized learning experiences to make studying effective and enjoyable.',
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Mission Section
            _buildSectionTitle('Our Mission'),
            const Text(
              'We strive to empower students and learners worldwide with easy access to high-quality study materials, tailored learning solutions, and innovative tools to support lifelong education.',
              style: TextStyle(
                fontSize: 16,
                height: 1.8,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),

            // Meet the Team
            _buildSectionTitle('Meet the Team'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeamMember('Gayan', 'assets/team1.jfif'),
                _buildTeamMember('Sudaraka', 'assets/team2.jfif'),
                _buildTeamMember('Ashan', 'assets/team3.jfif'),
              ],
            ),
            const SizedBox(height: 30),

            // Contact Us
            _buildSectionTitle('Contact Us'),
            const ListTile(
              leading: Icon(Icons.email, color: Colors.blueAccent, size: 28),
              title: Text(
                'info@learneme.lk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.phone, color: Colors.blueAccent, size: 28),
              title: Text(
                '+94 77 468 2366',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 20),

            // Footer with App Version
            const Center(
              child: Column(
                children: [
                  Divider(color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'App Version 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Team Member Widget
  Widget _buildTeamMember(String name, String imagePath) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade400,
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imagePath), // Ensure the image exists in assets
          ),
        ),
        const SizedBox(height: 10),
        Text(
          name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


