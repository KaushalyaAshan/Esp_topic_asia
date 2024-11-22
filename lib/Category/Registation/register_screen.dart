import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userId = prefs.getString("Device_id") ?? "UnknownUserID";
    });
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
              colors: [Colors.blueAccent, Colors.redAccent], // Red + Blue gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: _isVerificationVisible
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
              ),
            ),
          );
        },
      )
          : Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
                 //const SizedBox(height: 20),
                  // if (_userId != null)
                  //   Container(
                  //     padding: const EdgeInsets.all(12),
                  //     decoration: BoxDecoration(
                  //       color: Colors.blue.shade50,
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //     child: Text(
                  //       'User ID: $_userId',
                  //       style: const TextStyle(
                  //         fontSize: 16,
                  //         fontWeight: FontWeight.bold,
                  //         color: Colors.blueAccent,
                  //       ),
                  //     ),
                  //   )
                  // else
                  //   const Text(
                  //     'Loading user ID...',
                  //     style: TextStyle(color: Colors.red),
                  //     textAlign: TextAlign.center,
                  //   ),
                  const SizedBox(height: 30),
                  _buildSubmitButton(),
                ],
              ),
            ),
          ),
        ),
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
      'Select Country',
      'Sri Lanka',
      'Bangladesh',
      'Canada',
      'United Kingdom',
      'Australia',
      'Others',
    ];
    return DropdownButtonFormField<String>(
      value: countries.first,
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
          _countryController.text = value ?? '';
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
              colors: [Colors.blueAccent, Colors.redAccent],
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
  int response_statusCode=0;
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
      print(response.statusCode );
      if (response.statusCode == 200) {
        print(response.statusCode );
        final responseData = json.decode(response.body);
        response_statusCode=response.statusCode;
        return responseData["statusCode"] == "S1000";
      } else {
        final responseData = json.decode(response.body);
         _message = responseData["message"];
        // response_statusCode=response.statusCode;
       // response_statusCode=200;

        print( _message);
      }
    } catch (e) {
      _message = "An error occurred. Please try again.";
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(  // Center the form in the middle of the screen
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
                        colors: [Colors.blueAccent, Colors.redAccent],  // Blue + Red gradient
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
                          color: Colors.white,  // White text on the button
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
    );
  }

}
