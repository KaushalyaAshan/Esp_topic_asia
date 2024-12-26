import 'package:asp_topic_asia/Category/paper_details/Answer_Report_Page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For parsing JSON
import '../Menu bar/menu_bar.dart';
import './dialogs/confirmation_dialog_screen.dart';// Import the dialog screen
import 'package:shared_preferences/shared_preferences.dart';

class EspGuidesScreen extends StatefulWidget {
  @override
  _EspGuidesScreenState createState() => _EspGuidesScreenState();
}

class _EspGuidesScreenState extends State<EspGuidesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<dynamic> _papers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _fetchPapers(); // Fetch the papers when the widget is initialized
  }

  Future<void> _fetchPapers() async {
    final url = Uri.parse('https://epstopik.asia/api/get-all-eps-papers');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _papers = json.decode(response.body); // Parse the JSON response
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load papers');
      }
    } catch (e) {
      print('Error fetching papers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<dynamic>> _fetchAnswers() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(
        "Device_id"); // Ensure the key is 'user_id'

    if (userId == null) {
      throw Exception('User ID not found in SharedPreferences');
    }
    print(userId);
    final url = Uri.parse('https://epstopik.asia/api/get-all-answered-papers/$userId');
    print(userId);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return json.decode(response.body);// Return the parsed JSON response

      } else {
        throw Exception('Failed to load answers');
      }
    } catch (e) {
      print('Error fetching answers: $e');
      return [];
    }
  }

  // Future<void> fetchAnswerData(BuildContext context ,String marke_id,String paper_id) async {
  //   final response = await http.get(Uri.parse('https://epstopik.asia/api/get-answers/$marke_id'));
  //
  //   if (response.statusCode == 200) {
  //     // Parse the data if the response is successful
  //     var answerData = json.decode(response.body);
  //
  //     // Navigate to the Report page and pass the fetched data
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => AnswerReportPage(
  //           userAnswers: answerData['answers'], // Full list of answers
  //           paperId: paper_id,  // The selected paper ID
  //         ),
  //       ),
  //     );
  //   } else {
  //     // Handle error if response fails
  //     print('Failed to load answers');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final double buttonWidth = (MediaQuery.of(context).size.width * 0.9); // Button width is 90% of the screen width

    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        key: _scaffoldKey, // Assign the key to the Scaffold
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(200.0), // Increased height for the AppBar with TabBar
          child: ClipPath(
            clipper: DoubleCurvedAppBarClipper(),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/computer.png'), // Background image
                  fit: BoxFit.cover, // Ensure the image covers the entire AppBar area
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, left: 16.0, right: 16.0), // Adjust padding
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      // Distribute space evenly
                      crossAxisAlignment: CrossAxisAlignment.start,
                      // Align children at the top
                      children: [
                        IconButton(
                          icon: const Icon(Icons.menu, color: Colors.black, size: 30),
                          onPressed: () {
                            _scaffoldKey.currentState?.openDrawer(); // Open drawer
                          },
                        ),
                        Expanded(child: Container()),
                        // Spacer to push the logo to the right
                        Image.asset(
                          'assets/logo.png', // Replace with your logo path
                          width: 120, // Adjust the width of the logo
                          height: 60, // Adjust the height of the logo
                          fit: BoxFit.contain, // Maintain aspect ratio
                        ),
                      ],
                    ),
                  ),
                  // const TabBar(
                  //   labelColor: Colors.white, // Active tab text color
                  //   unselectedLabelColor: Colors.white60, // Dim inactive tab text color
                  //   indicatorColor: Colors.white, // White underline for the active tab
                  //   indicatorWeight: 3, // Thicker underline for active tab
                  //   tabs: [
                  //     Tab(
                  //       icon: Icon(Icons.library_books, color: Colors.white, size: 28),
                  //       child: Text(
                  //         "Papers",
                  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //       ),
                  //     ),
                  //     Tab(
                  //       icon: Icon(Icons.question_answer, color: Colors.white, size: 28),
                  //       child: Text(
                  //         "Answers",
                  //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
        drawer: AppDrawer(),
        body: Column(
            children: [
              const TabBar(
                labelColor: Colors.white, // Active tab text color
                unselectedLabelColor: Colors.white60, // Dim inactive tab text color
                indicatorColor: Colors.blue, // Blue underline for the active tab
                indicatorWeight: 3, // Thicker underline for active tab
                tabs: [
                  Tab(

                    icon: Icon(Icons.library_books, color: Colors.blue, size: 20),
                    child: Text(
                      "Papers",
                      style: TextStyle(fontSize: 18, color: Colors.blue,fontWeight: FontWeight.bold),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.question_answer, color: Colors.blue, size: 20),
                    child: Text(
                      "Answers",
                      style: TextStyle(fontSize: 18,color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : TabBarView(
                  children: [
                    _buildPapersTab(),
                    _buildAnswersTab(),
                  ],
                ),
              )
            ]
        )
      )
    );
  }
  Widget _buildPapersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Available Papers',
          //   style: TextStyle(
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.blueAccent,
          //   ),
          // ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _papers.length,
              itemBuilder: (context, index) {
                final paper = _papers[index];
                return _buildPaperRow(
                  context,
                  paper['paper_name'],
                  'assets/sample_paper.jpeg', // Replace with actual image if available
                  '${paper['questions']} Questions',
                  'Marks: ${paper['mark']} Marks',
                  paper['paper_id'].toString(), // Convert paperId to String here
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _displayPaperNames() {
    return ListView.builder(
      itemCount: _papers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_papers[index]['paper_name']), // Display paper name
        );
      },
    );
  }
  Widget _buildAnswersTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // const Text(
          //   'Paper Answers ',
          //   style: TextStyle(
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.blueAccent,
          //   ),
          // ),
          const SizedBox(height: 10),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchAnswers(), // Update this function to fetch user-specific data
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  final answers = snapshot.data!;

                  return ListView.builder(
                    itemCount: answers.length,
                    itemBuilder: (context, index) {
                      final answer = answers[index];
                      return Card(
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Left section: Text and details
                              Column(

                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [

                                  Text(

                                    'EPS-TOPIK MODAL PAPERS ${answer['paper_id']}' ?? 'Paper Name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Questions: ${answer['questions'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Score: ${answer['score']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                ],
                              ),
                              // Right section: Button
                              Container(
                                width: 95,  // Full width of the container
                                height: 35,  // Set button height
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF1565C0), // Darker blue
                                      Color(0xFF42A5F5), // Lighter blue
                                      Colors.redAccent,  // Add red color to the gradient
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12), // Rounded corners to match the button
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AnswerReportPage(
                                          paperId: "${answer['paper_id']}",
                                          markId: "${answer['mark_id']}",
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent, // Transparent to show gradient
                                    shadowColor: Colors.transparent, // No button shadow
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5), // Padding for better button appearance
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12), // Rounded corners for button
                                    ),
                                  ),
                                  child: const Text(
                                    'Details',
                                    style: TextStyle(
                                      fontSize:16, // Slightly larger font size for the button text
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // White text color
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(
                    child: Text(
                      'No answers available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperRow(BuildContext context, String paperName, String imagePath,
      String questionCount, String duration, String paperId) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    imagePath,
                    width: 60,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paperName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            questionCount,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            duration,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Show the dialog screen and pass paperId
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmationDialogScreen(
                                paperName: paperName,
                                questionCount: questionCount,
                                duration: duration,
                                paperId: paperId, // Pass paperId here
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                          shadowColor: Colors.black.withOpacity(0.2),
                          backgroundColor: Colors.transparent,
                        ).copyWith(
                          backgroundColor:
                          MaterialStateProperty.resolveWith<Color>(
                                (Set<MaterialState> states) {
                              if (states.contains(MaterialState.pressed)) {
                                return Colors.blueAccent;
                              }
                              return Colors.transparent;
                            },
                          ),
                        ),
                          child: Ink(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1565C0), // Darker blue
                                  Color(0xFF42A5F5), // Lighter blue
                                  Colors.redAccent,  // Red color
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              constraints: const BoxConstraints(
                                minWidth: 80,
                                minHeight: 35,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Start',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // White text color
                                ),
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
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
