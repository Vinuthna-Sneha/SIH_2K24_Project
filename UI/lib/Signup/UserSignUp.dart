import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sih/pages/user_homepage.dart';
import 'package:sih/widgets/passwordinputfield.dart';
import 'package:sih/widgets/app_scrollbar.dart';
import 'package:http/http.dart' as http;

class UserSignupPage extends StatefulWidget {
  const UserSignupPage({super.key});

  @override
  _UserSignupPageState createState() => _UserSignupPageState();
}

class _UserSignupPageState extends State<UserSignupPage> {
  // Controllers for input fields
  final TextEditingController username = TextEditingController();
  final TextEditingController useremail = TextEditingController();
  final TextEditingController userpassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signupUser() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }
    print('Attempting signup with Email: ${useremail.text.trim()}');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('http://192.168.152.249:8000/api/signup/user'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': username.text.trim(),
          'email': useremail.text.trim(),
          'password': userpassword.text.trim(),
        }),
      );
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        print('Signup successful: $data');
        await sendEmailToBackend(useremail.text.trim());
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(email: useremail.text.trim()),
          ),
        );
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final errorData = json.decode(response.body);
        print('Signup failed with error: ${errorData['error']}');
        _showError(errorData['error'] ?? 'Invalid credentials');
      } else {
        print('Unexpected response: ${response.body}');
        _showError('Signup failed. Please try again later.');
      }
    } catch (error) {
      print('Error occurred: $error');
      _showError('An error occurred. Please check your connection.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> sendEmailToBackend(String email) async {
    try {
      final emailResponse = await http.post(
        Uri.parse('http://192.168.152.249:8000/api/sendotp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'email': email}),
      );

      if (emailResponse.statusCode == 200) {
        print('Email sent successfully: ${emailResponse.body}');
      } else {
        print('Failed to send email: ${emailResponse.body}');
      }
    } catch (error) {
      print('Error occurred while sending email: $error');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    username.dispose();
    useremail.dispose();
    userpassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Image.asset(
              'assets/headerlogo.png',
              width: 40,
              height: 40,
            ),
          ),
        ],
      ),
      body: AppScrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Lottie.asset(
                    'assets/animation1.json',
                    width: 250,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  inputFile(label: "Name", controller: username),
                  const SizedBox(height: 20),
                  inputFile(label: "Email", controller: useremail),
                  const SizedBox(height: 15),
                  PasswordInputField(
                    label: "Password",
                    controller: userpassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  PasswordInputField(
                    label: "Confirm Password",
                    controller: confirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != userpassword.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  MaterialButton(
                    minWidth: double.infinity,
                    height: 50,
                    onPressed: _signupUser,
                    color: const Color(0xff0095FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Signup",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget inputFile({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class OTPScreen extends StatefulWidget {
  final String email;

  const OTPScreen({required this.email, super.key});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();

  Future<void> sendOTPToBackend() async {
    try {
      String otp = otpController.text.trim();

      if (otp.isEmpty) {
        _showError('Please enter the OTP.');
        return;
      }

      final response = await http.post(
        Uri.parse('http://192.168.152.249:8000/api/verifyotp'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'otp': int.parse(otp), 'email': widget.email}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('OTP verification successful: $data');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UserHomeScreen(),
          ),
        );
      } else {
        final errorData = json.decode(response.body);
        _showError(errorData['error'] ?? 'Invalid OTP');
      }
    } catch (error) {
      _showError('An error occurred. Please check your connection.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.red),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("OTP Verification"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Enter the OTP sent to your email",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OTP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendOTPToBackend,
              child: const Text("Verify OTP"),
            ),
          ],
        ),
      ),
    );
  }
}
