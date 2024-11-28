import 'package:asp_topic_asia/Menu%20bar/settings.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }
  Future<void> _fetchUserDetails() async {
    final url = Uri.parse('https://epstopik.asia/api/user-details');
    try {
      // Get the user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(
          "Device_id"); // Ensure the key is 'user_id'

      if (userId == null) {
        throw Exception('User ID not found in SharedPreferences');
      }
      print(userId);
      // Fetch user details from the API
      final response = await http.post(
        url,
        body: {"user_id": userId.toString()},
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        setState(() {
          _userData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch user details');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // Ensure text is readable on gradient
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.redAccent, Colors.blueAccent], // Gradient colors
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
        // Add slight shadow for depth
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.settings, color: Colors.white),
        //     onPressed: () {
        //       Navigator.push(
        //         context,
        //         MaterialPageRoute(builder: (context) => SettingsScreen()),
        //       );
        //     },
        //   ),
        // ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(
        child: Text(
          'No user data available',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _userData!['profile_picture'] != null
                        ? NetworkImage(_userData!['profile_picture'])
                        : const AssetImage(
                        'assets/team3.jfif') as ImageProvider,
                    backgroundColor: Colors.blue.shade100,
                  ),
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(
                            'Change Profile Picture Coming Soon!')),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Profile Details Box
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRowWithBox(
                        'Name:', _userData!['name'], Icons.person),
                    const Divider(thickness: 1, color: Colors.grey),
                    _buildDetailRowWithBox(
                        'Phone:', _userData!['Telephone'], Icons.phone),
                    const Divider(thickness: 1, color: Colors.grey),
                    _buildDetailRowWithBox(
                      'Payment Status:',
                      _userData!['payment'] == 1 ? 'Paid' : 'Pending',
                      Icons.payment,
                    ),
                    const Divider(thickness: 1, color: Colors.grey),
                    _buildDetailRowWithBox(
                        'Country:', _userData!['country'], Icons.flag),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // // Edit Profile Button
            // Center(
            //   child: ElevatedButton.icon(
            //     onPressed: () {
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text('Edit Profile Coming Soon!')),
            //       );
            //     },
            //     icon: const Icon(Icons.edit, size: 20),
            //     label: const Text(
            //       'Edit Profile',
            //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //     ),
            //     style: ElevatedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(
            //           vertical: 12, horizontal: 24),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(12),
            //       ),
            //       backgroundColor: Colors.blueAccent,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),

    );
  } // Helper method to build detail rows
  Widget _buildDetailRowWithBox(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blueAccent, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
//
//   Widget _buildEditableDetailRow(String label, String value, IconData icon, BuildContext context) {
//     return Row(
//       children: [
//         Icon(icon, color: Colors.blueAccent, size: 20),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.grey,
//                 ),
//               ),
//               Text(
//                 value,
//                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//         // IconButton(
//         //   icon: const Icon(Icons.edit, color: Colors.blueAccent, size: 20),
//         //   onPressed: () {
//         //     // Show an input dialog to edit the value
//         //     showDialog(
//         //       context: context,
//         //       builder: (context) {
//         //         final TextEditingController controller = TextEditingController(text: value);
//         //         return AlertDialog(
//         //           title: Text('Edit $label'),
//         //           content: TextField(
//         //             controller: controller,
//         //             decoration: InputDecoration(
//         //               hintText: 'Enter new $label',
//         //               border: const OutlineInputBorder(),
//         //             ),
//         //           ),
//         //           actions: [
//         //             TextButton(
//         //               onPressed: () => Navigator.pop(context),
//         //               child: const Text('Cancel'),
//         //             ),
//         //             TextButton(
//         //               onPressed: () {
//         //                 // Implement update logic
//         //                 ScaffoldMessenger.of(context).showSnackBar(
//         //                   const SnackBar(content: Text('Update functionality coming soon!')),
//         //                 );
//         //                 Navigator.pop(context);
//         //               },
//         //               child: const Text('Save'),
//         //             ),
//         //           ],
//         //         );
//         //       },
//         //     );
//         //   },
//         // ),
//       ],
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         Text(
//           value,
//           style: const TextStyle(fontSize: 16),
//         ),
//       ],
//     );
//   }
// }
//jjjh Ask afk
