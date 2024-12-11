import 'package:flutter/material.dart';
import 'package:sih/widgets/location_service.dart';
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http; // For HTTP requests

class UserReportFormScreen extends StatefulWidget {
  const UserReportFormScreen({super.key});

  @override
  _UserReportFormScreenState createState() => _UserReportFormScreenState();
}

class _UserReportFormScreenState extends State<UserReportFormScreen> {
  TextEditingController routeIdController = TextEditingController();

  // Map for tracking checkbox selections
  Map<String, bool> problemOptions = {
    "Road Block": false,
    "Accident": false,
    "Heavy Traffic": false,
    "Malfunctioning of Vehicle": false,
  };

  final LocationService _locationService = LocationService(); // Instance of LocationService
  String? currentLocation; // To store current location as a string

  // Function to fetch the location
  Future<void> fetchLocation() async {
    final locationData = await _locationService.getLocation();
    if (locationData != null) {
      setState(() {
        currentLocation =
            "Latitude: ${locationData.latitude}, Longitude: ${locationData.longitude}";
      });
    } else {
      print("Unable to fetch location. Please enable location services.");
    }
    print(currentLocation);
  }

  // Function to send data to the backend
  Future<void> sendReportToBackend(Map<String, dynamic> reportData) async {
    try {
      var url = Uri.parse("http://your-backend-endpoint/api/report_issue"); // Replace with your backend URL
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reportData),
      );

      if (response.statusCode == 200) {
        print("Report submitted successfully: ${response.body}");
      } else {
        print("Failed to submit report: ${response.body}");
      }
    } catch (e) {
      print("Error submitting report: $e");
    }
  }

  // Submit function
  void submitReport() async {
    await fetchLocation(); // Fetch the location first

    // Prepare the data to be sent to the backend
    Map<String, dynamic> reportData = {
      "routeId": routeIdController.text,
      "problems": problemOptions.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
      "location": currentLocation ?? "Location not available",
    };

    print("Submitting report: $reportData");
    await sendReportToBackend(reportData); // Send the data to the backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report a Problem"),
        backgroundColor: Color(0xff0095FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Image at the top
              Container(
                height: 230,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/ur.png"), // Replace with your image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Form with Route ID input and checkboxes
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Route ID Input
                      TextField(
                        controller: routeIdController,
                        decoration: InputDecoration(
                          labelText: "Route ID",
                          hintText: "Enter Route ID",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[200],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Problem Checkboxes
                      Text(
                        "Select Problems to Report:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: problemOptions.keys.map((String key) {
                          return CheckboxListTile(
                            title: Text(key),
                            value: problemOptions[key],
                            onChanged: (bool? value) {
                              setState(() {
                                problemOptions[key] = value ?? false;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),

                      // Submit Button
                      Center(
                        child: ElevatedButton(
                          onPressed: submitReport,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff0095FF),
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Submit",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
