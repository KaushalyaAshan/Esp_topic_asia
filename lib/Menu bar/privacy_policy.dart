import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  @override
  _PrivacyPolicyScreenState createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  late final WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        elevation: 6.0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3366FF), Color(0xFF00CCFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: WebView(
        initialUrl: 'https://your-privacy-policy-url.com', // Replace with your privacy policy URL
        //javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        navigationDelegate: (NavigationRequest request) {
          if (request.url.startsWith('https://')) {
            return NavigationDecision.navigate;
          } else {
            return NavigationDecision.prevent;
          }
        },
        onPageStarted: (String url) {
          debugPrint('Page started loading: $url');
        },
        onPageFinished: (String url) {
          debugPrint('Page finished loading: $url');
        },
      ),
    );
  }

  WebView({required String initialUrl, required Null Function(dynamic controller) onWebViewCreated, required NavigationDecision Function(NavigationRequest request) navigationDelegate, required Null Function(String url) onPageStarted, required Null Function(String url) onPageFinished}) {}
}
