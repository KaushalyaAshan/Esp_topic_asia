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
          const DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 1), // Space between logo and title
                Text(
                  'Epstopik Asia', // Title of the app
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ), // Title style
                ),
                SizedBox(height: 5), // Space between title and email
                Text(
                  'Email: info@learneme.lk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ), // Email style
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
                  MaterialPageRoute(
                      builder: (context) =>ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('PDF'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>PdfViewerPage(pdfUrl: 'https://example.com/sample.pdf')));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context); // Close the drawer first
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AboutPage()));
            },
          ),
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
            title: const Text('Terms & ConditionsScreen'),
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
