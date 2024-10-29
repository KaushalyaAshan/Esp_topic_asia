import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_screen.dart';
import 'package:android_id/android_id.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding and decoding

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Exam App',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  String? _deviceId;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Get device ID and check user status
    _getDeviceIdAndCheckStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to get device ID and check user status
  Future<void> _getDeviceIdAndCheckStatus() async {
    const androidIdPlugin = AndroidId();
    final String? androidId = await androidIdPlugin.getId();

    setState(() {
      _deviceId = androidId; // Set the device ID state
    });

    if (androidId != null) {
      // Post device ID to API after retrieval
      await _postDeviceIdAndNavigate(androidId);
    } else {
      print('Failed to retrieve Android ID');
      // Optionally handle the case where the ID retrieval fails
    }
  }

  Future<void> _postDeviceIdAndNavigate(String androidId) async {
    final url = Uri.parse('https://epstopik.asia/api/user-status-check');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"Device_id": androidId}),
      );

      print('Response: ${response.body}');
      print('Android ID: $androidId');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Assuming 'user_id' field now contains the actual device ID
          String androidDeviceId = data['user_id'].toString();

          // Save device_id in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString("Device_id", androidDeviceId);

          // Retrieve and print the stored device_id for confirmation
          String? storedDeviceId = prefs.getString("Device_id");
          print('Stored User: $storedDeviceId'); // Confirm device ID storage

          // Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          print('User is inactive or status is not success.');
          // Optionally navigate to a different screen or show an error
        }
      } else {
        print('Failed to check user status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking user status: $e');
    }
  }

  // Function to make the API call and navigate based on the response
//   Future<void> _postDeviceIdAndNavigate(String androidId) async {
//     final url = Uri.parse('https://epstopik.asia/api/user-status-check');
//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'device_id': androidId}),
//       );
//       print('******************************************************************$response');
//       print('******************************************************************$androidId');
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         print('****************************************************8888888888888888888888888888888888888888888$data');
//         if (data['status'] == 'success') {
//           // Convert user_id to string to avoid type issues
//           String userId = data['user_id'].toString();
//
//           // Save user_id in SharedPreferences
//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString('user_id', userId);
//
//           // Retrieve and print the stored user_id for confirmation
//           String? storedUserId = prefs.getString('user_id');
//           print('Stored user ID: $storedUserId'); // Print user ID for confirmation
//
//           // Navigate to HomeScreen
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => HomeScreen()),
//           );
//         }
//         else {
//           print('User is inactive or status is not success.');
//           // Optionally navigate to a different screen or show an error
//         }
//       } else {
//         print('Failed to check user status. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error checking user status: $e');
//     }
//   }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.redAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 180,
                    height: 180,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Esp_Topic_Asia",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _deviceId != null ? 'Device ID: $_deviceId' : 'Fetching device ID...',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
