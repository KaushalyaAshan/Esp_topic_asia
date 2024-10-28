import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Home_screen.dart';
import 'dart:io'; // For platform checks
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding and decoding
import 'package:device_info_plus/device_info_plus.dart'; // To get device ID
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
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Get device ID and post to API
    _getDeviceIdAndCheckStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Function to get device ID and check user status
  Future<void> _getDeviceIdAndCheckStatus() async {
    String? deviceId = await _getDeviceId();
    if (deviceId != null) {
      setState(() {
        _deviceId = deviceId;
      });
      await _postDeviceIdAndNavigate(deviceId);
    } else {
      print('Error: Unable to retrieve device ID');
    }
    // Navigate to HomeScreen after a delay
    _navigateToHome();
  }

  // Function to get device ID based on platform (Android or iOS)
  Future<String?> _getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Unique device ID for Android
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor; // Unique device ID for iOS
      }
    } catch (e) {
      print('Error fetching device ID: $e');
    }
    return null;
  }

  // Function to make the API call and navigate based on the response
  Future<void> _postDeviceIdAndNavigate(String deviceId) async {
    final url = Uri.parse('https://epstopik.asia/api/user-status-check');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'device_id': deviceId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          // Convert user_id to string to avoid type issues
          String userId = data['user_id'].toString();

          // Save user_id in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId);

          // Retrieve and print the stored user_id for confirmation
          String? storedUserId = prefs.getString('user_id');
          print('Stored user ID: $storedUserId'); // Print user ID for confirmation

          // Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          print('User is inactive or status is not success.');
        }
      } else {
        print('Failed to check user status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking user status: $e');
    }
  }

  // Navigate to HomeScreen after a delay
  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 5));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

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
