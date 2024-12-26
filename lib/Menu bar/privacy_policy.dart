import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://epstopik.asia/privacy-policy')); // Replace with your URL
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, // Font size for title
            color: Colors.white, // Set text color to white
          ),
        ),
        centerTitle: true, // Align title text to the center
        backgroundColor: Colors.transparent, // Make the background transparent
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1565C0), // A darker blue
                Color(0xFF42A5F5), // A lighter blue
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4, // Add shadow for depth
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Back arrow icon
            color: Colors.white, // Set icon color to white
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),

      body: WebViewWidget(controller: _controller),
    );
  }
}
