import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const SizedBox(height: 10),

          // Account Section
          _buildSectionTitle('Account'),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blueAccent),
            title: const Text('Profile', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Profile Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock, color: Colors.blueAccent),
            title: const Text('Change Password', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Change password functionality
            },
          ),
          const Divider(height: 40),

          // Notifications Section
          _buildSectionTitle('Notifications'),
          SwitchListTile(
            activeColor: Colors.blueAccent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: false, // Placeholder for notification setting
            title: const Text('Push Notifications', style: TextStyle(fontSize: 18)),
            onChanged: (value) {
              // Toggle notifications
            },
          ),
          SwitchListTile(
            activeColor: Colors.blueAccent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: true, // Placeholder for email notification setting
            title: const Text('Email Notifications', style: TextStyle(fontSize: 18)),
            onChanged: (value) {
              // Toggle email notifications
            },
          ),
          const Divider(height: 40),

          // Privacy Section
          _buildSectionTitle('Privacy'),
          ListTile(
            leading: const Icon(Icons.privacy_tip, color: Colors.blueAccent),
            title: const Text('Privacy Settings', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to Privacy Settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.redAccent),
            title: const Text('Delete Account', style: TextStyle(fontSize: 18)),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Delete account functionality
            },
          ),
          const Divider(height: 40),

          // General Section
          _buildSectionTitle('General'),
          SwitchListTile(
            activeColor: Colors.blueAccent,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            value: false, // Placeholder for dark mode setting
            title: const Text('Dark Mode', style: TextStyle(fontSize: 18)),
            onChanged: (value) {
              // Toggle dark mode
            },
          ),
          const SizedBox(height: 30),

          // Logout Button
          ElevatedButton.icon(
            onPressed: () {
              // Implement logout functionality
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout', style: TextStyle(fontSize: 18)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
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
}
