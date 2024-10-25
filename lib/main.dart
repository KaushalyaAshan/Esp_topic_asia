import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'Home_screen.dart';
// import 'InactiveUserScreen.dart';
// import 'splash_screen.dart';
import 'dart:io'; // For platform checks
import 'package:http/http.dart' as http; // For making HTTP requests
import 'dart:convert'; // For JSON encoding and decoding
import 'package:device_info_plus/device_info_plus.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Exam App',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
      ),
      home: SplashScreen(), // Set the splash screen as the initial screen
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
  String? _deviceId; // Variable to hold the device ID.

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Duration for the fade-in animation
    );

    // Set up the fade animation
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();



    // Get device ID and post to API
    _getDeviceIdAndCheckStatus();
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the animation controller
    super.dispose();
  }

  // Function to get device ID and check user status
  Future<void> _getDeviceIdAndCheckStatus() async {

    // String? deviceId = await PlatformDeviceId.getDeviceId;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.device}');  // e.g. "Moto G (4)"



    print('++++++++++*********************************++++');
    // String deviceId = await getDeviceId(); // Fetch the device ID
    // setState(() {
    //   _deviceId = deviceId; // Update the device ID in the state
    // });
    // await _postDeviceIdAndNavigate(deviceId); // Post the device ID and navigate
    // // Navigate to HomeScreen after a delay
    // _navigateToHome();
  }

  // Function to get device ID based on the platform (Android or iOS)
  // Future<String> getDeviceId() async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin(); // Initialize the plugin
  //   String deviceId = "";
  //   if (Platform.isAndroid) {
  //     // Android-specific code
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     print('*****************$androidInfo');
  //     deviceId = androidInfo.id; // Correct field for Android
  //   } else if (Platform.isIOS) {
  //     // iOS-specific code
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     deviceId = iosInfo.identifierForVendor ?? "Unknown iOS ID"; // Fallback value
  //   }
  //   return deviceId; // Return the device ID
  // }

  // Function to make the API call and navigate based on the response
  Future<void> _postDeviceIdAndNavigate(String deviceId) async {
    final url = Uri.parse('https://epstopik.asia/api/user-status-check');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_id': deviceId, // Send the device ID in the API request
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Debugging: Print the API response to the console
        print('API Response: $data');

        // Assuming user_id is present in the response
        if (data['status'] == 'success') {
          String userId = data['user_id']; // Extract user ID from the response

          // Save user_id in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId); // Store the user_id

          // Navigate to HomeScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        } else {
          // Optionally handle inactive users
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => InactiveUserScreen()),
          // );
        }
      } else {
        print('Failed to check user status. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error checking user status: $e');
      // Optionally, navigate to an error screen or show a user-friendly message
    }
  }
  // Navigate to HomeScreen after a delay
  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4), () {}); // Total splash duration
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
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.redAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Center logo with fade-in animation
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/logo.png',
                    width: 180, // Logo size
                    height: 180,
                  ),
                  const SizedBox(height: 20),
                  // App Name (optional)
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
                  // Device ID (Display the device ID here)
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
