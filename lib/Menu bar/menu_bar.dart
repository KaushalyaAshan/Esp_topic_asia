import 'package:flutter/material.dart';
import 'PdfViewer.dart';
import 'Terms_&_condition.dart';
import 'privacy_policy.dart';
import 'settings.dart';
import 'about.dart';
import 'profile.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF1565C0), // A darker blue
                  Color(0xFF42A5F5), // A lighter blue for a gradient effect
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Align all content to the left
              mainAxisAlignment: MainAxisAlignment.start,  // Align content to the top
              children: [
                // Left-aligned logo
                Image.asset(
                  'assets/logo.png',
                  width: 180, // Reduced width
                  height: 50, // Reduced height
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 10), // Space between logo and title
                const Text(
                  'Epstopik Asia', // Title of the app
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18, // Reduced font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5), // Space between title and email
                const Text(
                  'Email: info@learneme.lk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutPage()));
            },
          ),
          // ListTile(
          //   leading: const Icon(Icons.picture_as_pdf),
          //   title: const Text('PDF Viewer'),
          //   onTap: () {
          //     Navigator.pop(context); // Close the drawer first
          //     Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //             builder: (context) => PdfViewerPage(
          //                 pdfUrl: 'http://eagri.org/eagri50/AENG252/lec01.pdf')));
          //   },
          // ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy & Policy'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PrivacyPolicyScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text('Terms & Conditions'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TermsConditionsScreen()));
            },
          ),
        ],
      ),
    );
  }
}
