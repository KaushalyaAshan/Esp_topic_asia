import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsConditionsScreen extends StatefulWidget {
  @override
  _TermsConditionsScreenState createState() => _TermsConditionsScreenState();
}
class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();
    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://epstopik.asia/tc')); // Replace with your Terms and Conditions URL
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms and Conditions',
          style: TextStyle(
            fontSize: 22, // Font size for title
            fontWeight: FontWeight.bold, // Bold text style
            color: Colors.white, // Set text color to white
          ),
        ),
        centerTitle: true, // Center-align the title
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
        elevation: 4, // Shadow for depth
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Back arrow icon
            color: Colors.white, // Icon color is white
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
      ),

      body: WebViewWidget(controller: _controller),
    );
  }
}
