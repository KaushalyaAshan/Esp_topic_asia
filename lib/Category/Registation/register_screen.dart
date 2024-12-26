import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Home_screen.dart';
import '../esp_guids.dart';
import '../paper_details/paper_detail_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RegisterScreen(paperName: "Sample Paper", paperId: "12345"),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  final String paperName;
  final String paperId;

  const RegisterScreen({
    Key? key,
    required this.paperName,
    required this.paperId,
  }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  String? _userId;
  bool _isLoading = false;
  bool _isVerificationVisible = false;
  String _serverRef = "";
  String _serviceProvider = "";
  String _message = "";
  String _headerDescription = "";
  String _footerDescription = "";
  @override
  void initState() {
    super.initState();
    _loadUserId();
    _fetchMessages();
    _checkRegistration();
  }
  Future<int> _checkRegistration() async {
    // Get the user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString("Device_id"); // Ensure the key is 'user_id'
    final url = Uri.parse('https://epstopik.asia/api/user-details');

    try {
      // Send POST request with the user ID
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'user_id': userId}), // Assuming 'user_id' is the expected key
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('******************** ${data['payment']}');
        return data['payment'];
      } else {
        // Log response error for debugging
        print("Error: ${response.statusCode} - ${response.reasonPhrase}");
        return -1;
      }
    } catch (error) {
      // Log exception
      print("Error checking registration: $error");
      return -1;
    }
  }

  void _showNoMoneyAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // More rounded corners for a smooth, modern look
          ),
          backgroundColor: Colors.lightBlue, // Clean white background
          title: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1565C0), // A darker blue
                  Color(0xFF42A5F5), // A lighter blue
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25), // Match rounded corners
            ),
            padding: const EdgeInsets.all(16),
            child: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white, // White color for the icon
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'Insufficient Funds',
                  style: TextStyle(
                    fontSize: 24, // Slightly larger font size for the title
                    fontWeight: FontWeight.w600, // Bold for emphasis
                    color: Colors.white, // White text color for better contrast
                  ),
                ),
              ],
            ),
          ),
          content: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0), // More vertical padding for better spacing
            child: Text(
              'You do not have enough funds to proceed with this action. Please add funds to continue.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white, // Darker text for better readability
              ),
            ),
          ),
          actions: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0), // Add more padding at the bottom
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent, // Red button background
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Round button corners for consistency
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0), // More padding for a larger button
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("Device_id") ?? "UnknownUserID";
      //userId=prefs.getString("Device_id") ?? "UnknownUserID";
    });
  }

  Future<void> _fetchMessages() async {
    final url = Uri.parse('https://epstopik.asia/api/messages');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _headerDescription = data["header_description"] ?? "";
          _footerDescription = data["footer_description"] ?? "";
        });
      } else {
        print('Failed to fetch header and footer descriptions');
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _userId != null) {
      setState(() => _isLoading = true);

      final url = Uri.parse('https://epstopik.asia/api/register');
      try {
        final response = await http.post(
          url,
          body: {
            "name": _nameController.text,
            "telephone_no": _phoneController.text,
            "country": _countryController.text,
            "UserID": _userId!,
          },
        );

        setState(() => _isLoading = false);

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('')),
          );

          setState(() {
            _serverRef = responseData["referenceNo"];
            _serviceProvider = responseData["service_provider"];
            _isVerificationVisible = true;
          });
        } else {
          final responseData = json.decode(response.body);
          _message = responseData["message"];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration failed! $_message')),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred. Please try again.')),
        );
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.home,
            color: Colors.white, // Ensures the icon color is white
            size: 28, // Slightly larger icon for emphasis
          ),
          tooltip: 'Go to Home',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => EspGuidesScreen()),
            );
          },
        ),
        title: Text(
          _isVerificationVisible ? 'Verification' : 'Register',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white, // White color for the text to stand out against the gradient
          ),
        ),
        backgroundColor: Colors.transparent, // Make the background transparent to show the gradient
        elevation: 0, // Remove the default shadow for a cleaner look
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1565C0), // Darker blue
                Color(0xFF42A5F5), // Lighter blue
              ], // Blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),

      body:  Column(
          children: [
          if (_headerDescription.isNotEmpty)
        Container(
          width: MediaQuery.of(context).size.width * 1,
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.white54, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          padding: const EdgeInsets.all(15),
          child: Text(
            _headerDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black45,
            ),
          ),
        ),

         Expanded(
          child:_isVerificationVisible
           ? VerificationWidget(
            serverRef: _serverRef,
            serviceProvider: _serviceProvider,
            userId: _userId!,
            onVerified: () {
              Navigator.push(
              context,
              MaterialPageRoute(
              builder: (context) => PaperDetailScreen(
                paperName: widget.paperName,
                paperId: widget.paperId,
                userId: _userId!,

              ),
            ),
          );
        },
      )
          : Center(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
          ),
               child: Padding(
                padding: const EdgeInsets.all(16.0),
                 child: Form(
                   key: _formKey,
                   child: ListView(
                     shrinkWrap: true,
                     children: [
                     const SizedBox(height: 20),
                  // Logo Widget
                     Center(
                       child: Column(
                         children: [
                        Image.asset(
                          'assets/logo.png', // Path to your logo image
                          height: 100,
                          width: 200,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Welcome to Registration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                     const SizedBox(height: 30),
                  // Form Fields
                     _buildTextField(
                    _nameController,
                    'Name',
                    'Please enter your name',
                  ),
                     const SizedBox(height: 20),
                    _buildTextField(
                    _phoneController,
                    'Telephone No',
                    'Please enter a valid phone number',
                    keyboardType: TextInputType.phone,
                    validator: (value) => RegExp(r'^\+?\d{10,15}$').hasMatch(value ?? '')
                        ? null
                        : 'Enter a valid phone number',
                  ),
                     const SizedBox(height: 20),
                     _buildCountryDropdown(),
                     const SizedBox(height: 30),
                     _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
            if (_footerDescription.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white30, Colors.white54],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0, 4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: Text(
                  _footerDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                    height: 1.5, // Line height for better readability
                  ),
                ),
              ),
          ],
    ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String labelText,
      String validationMessage, {
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
    );
  }
  Widget _buildCountryDropdown() {
    final List<String> countries = [
      'Select Country', // Placeholder option
      'Sri Lanka',             // Sri Lanka
      'Bangladesh',     // Bangladesh
    ];

    return DropdownButtonFormField<String>(
      value: countries.first, // Default to 'Select Country'
      decoration: InputDecoration(
        labelText: 'Country',
        labelStyle: const TextStyle(
          color: Colors.blueAccent,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: Colors.blue.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
        ),
      ),
      items: countries
          .map((country) => DropdownMenuItem<String>(
        value: country,
        child: Text(country),
      ))
          .toList(),
      onChanged: (value) {
        setState(() {
          _countryController.text = value ?? ''; // Update the selected country
        });
      },
      validator: (value) {
        if (value == null || value == 'Select Country') {
          return 'Please select your country';
        }
        return null;
      },
    );
  }


  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 10),
          backgroundColor: Colors.transparent, // Makes the button background transparent
          shadowColor: Colors.blue.shade50,
          elevation: 5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: BorderSide.none, // Removes the border to allow gradient to show fully
        ).copyWith(
          backgroundColor: MaterialStateProperty.all(Colors.transparent),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1565C0), // Darker blue
                Color(0xFF42A5F5), // Lighter blue
                Colors.red, // Red color added
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
                : const Text(
              'Submit',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.white, // White text color
              ),
            ),
          ),
        ),
      ),
    );
  }
}
class VerificationWidget extends StatelessWidget {
  final String serverRef;
  final String serviceProvider;
  final String userId;
  final VoidCallback onVerified;

  VerificationWidget({
    required this.serverRef,
    required this.serviceProvider,
    required this.userId,
    required this.onVerified,
  });

  final TextEditingController _codeController = TextEditingController();
  String _message = "";
  int response_statusCode = 0;

  Future<bool> _verifyCode(String serverRef, String pin, String userId) async {
    final url = Uri.parse('https://epstopik.asia/api/verify-pin');
    try {
      final response = await http.post(
        url,
        body: {
          "pin": pin,
          "serverRef": serverRef,
          "service_provider": serviceProvider,
          "UserID": userId,
        },
      );
      print(pin);
      print(serverRef);
      print(serviceProvider);
      print(userId);
      print(response.statusCode);

      if (response.statusCode == 200) {
        print(response.statusCode);
        final responseData = json.decode(response.body);
        response_statusCode = response.statusCode;
        return responseData["statusCode"] == "S1000";
      } else {
        final responseData = json.decode(response.body);
        _message = responseData["message"];
        print(_message);
      }
    } catch (e) {
      _message = "An error occurred. Please try again.";
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(  // Wrap the entire body inside SingleChildScrollView
        child: Center(  // Center the form in the middle of the screen
          child: Card(
            elevation: 8,  // Slightly reduced elevation for a cleaner look
            margin: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),  // Rounded corners for the card
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Add Logo Image at the top of the form
                  Image.asset(
                    'assets/logo.png', // Your logo image path here
                    width: 220,  // Adjust width as needed
                    height: 120, // Adjust height as needed
                  ),
                  const SizedBox(height: 20), // Add space between the logo and the form

                  // Verification Code Input Field
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(6),  // Limit to 6 digits
                      FilteringTextInputFormatter.digitsOnly,  // Allow only digits
                    ],
                    textAlign: TextAlign.center,  // Center-align text
                    decoration: InputDecoration(
                      labelText: 'Enter Verification Code',
                      labelStyle: const TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                      filled: true,
                      fillColor: Colors.blue.shade50,  // Subtle background color for the field
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade200),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),  // Add padding for better spacing
                    ),
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 20),

                  // Verify Button with gradient background and no shadow
                  ElevatedButton(
                    onPressed: () async {
                      final isValid = await _verifyCode(serverRef, _codeController.text.trim(), userId);
                      if (response_statusCode == 200) {
                        onVerified();
                        response_statusCode = 0;
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _message,
                              style: const TextStyle(color: Colors.white),  // White text for better readability
                            ),
                            backgroundColor: Colors.redAccent,  // Red background for error messages
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,  // Transparent background for gradient
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 5),
                      elevation: 0,  // Set elevation to 0 to remove the shadow
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      backgroundColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF1565C0), // Darker blue
                            Color(0xFF42A5F5), // Lighter blue
                            Colors.red, // Red color
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text on the button
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
