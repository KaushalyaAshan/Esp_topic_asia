import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;

  @override
  void initState() {
    super.initState();
    downloadAndSavePdf();
  }

  Future<void> downloadAndSavePdf() async {
    final url = widget.pdfUrl;
    final filename = url.split('/').last;
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$filename';

    final response = await http.get(Uri.parse(url));
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    setState(() {
      localPath = filePath;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PDF Viewer",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20, // Adjust font size
            color: Colors.white, // Set text color to white
          ),
        ),
        centerTitle: true, // Align the title text to the center
        backgroundColor: Colors.transparent, // Make background transparent for gradient
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
        elevation: 4, // Add a shadow for a subtle effect
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back, // Arrow icon for navigating back
            color: Colors.white, // Set icon color to white
          ),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous screen
          },
        ),
      ),
      body: localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
        filePath: localPath,
      ),
    );
  }
}
