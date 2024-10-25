import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // App Banner or Logo
          Center(
            child: Image.asset(
              'assets/logo.png', // Ensure to add a logo image in assets
              height: 150,
            ),
          ),
          const SizedBox(height: 20),

          // About Us Section
          _buildSectionTitle('About Us'),
          const Text(
            'Our app is designed to provide comprehensive exam materials, learning guides, and other educational resources to help students excel in various subjects.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 20),

          // Mission Section
          _buildSectionTitle('Our Mission'),
          const Text(
            'We strive to empower students and learners worldwide with easy access to high-quality study materials and personalized learning experiences.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 20),

          // Team Section
          _buildSectionTitle('Meet the Team'),
          Row(
            children: [
              _buildTeamMember('Gayan ', 'assets/team1.jfif'),
              _buildTeamMember('Sudaraka ', 'assets/team2.jfif'),
              _buildTeamMember('Ashan', 'assets/team3.jfif'),
            ],
          ),
          const SizedBox(height: 20),

          // Contact Section
          _buildSectionTitle('Contact Us'),
          const Row(
            children: [
              Icon(Icons.email, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text(
                'info@learneme.lk',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.phone, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text(
                '+94 77 468 2366',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Footer with App Version
          const Center(
            child: Text(
              'App Version 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
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

  // Helper function to build team member widget
  Widget _buildTeamMember(String name, String imagePath) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage(imagePath), // Ensure images are in assets
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
