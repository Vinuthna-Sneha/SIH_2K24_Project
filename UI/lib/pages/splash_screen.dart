import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package
import 'package:sih/pages/Homepage.dart'; // Import the HomePages screen
import 'package:sih/widgets/app_scrollbar.dart'; // Import the AppScrollbar widget
import 'package:sih/widgets/location_service.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocationService _locationService = LocationService();
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePages(isDriver: false),
        ),
      );
    });
    _fetchLocationAndNavigate();
  }
   Future<void> _fetchLocationAndNavigate() async {
    await _locationService.getLocation();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/driver_home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Set your splash screen background color
      body: AppScrollbar(
        thumbVisibility: false, // Set to true if you want the scrollbar thumb to be visible
        child: Center(
          child: Column(
            children: [
              Spacer(), // Push content to the center
              Lottie.asset(
                'assets/Animation.json', // Replace with the path to your animation file
                height: 300, // Adjust height as needed
              ),
              Spacer(), // Add space below the first animation
              Lottie.asset(
                'assets/animation2.json', // Replace with the path to your second animation file
                height: 200, // Adjust height as needed
              ),
              SizedBox(height: 20), // Add space after the second animation
            ],
          ),
        ),
      ),
    );
  }
}
