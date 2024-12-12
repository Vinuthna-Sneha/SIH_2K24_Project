import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  Future<void> submitSearch() async {
    final String from = fromController.text.trim();
    final String to = toController.text.trim();

    if (from.isEmpty || to.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in both fields."),
        ),
      );
      return;
    }

    try {
      print(from);
      print(to);
      final response = await http.post(
        Uri.parse('http://172.16.18.13:8000/api/getAllBuses'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'source': from,
          'destination': to,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle the response data as needed
        print("Response: $data");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to fetch results. Please try again."),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("An error occurred: $e"),
        ),
      );
    }
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Find Buses"),
        centerTitle: true,
        backgroundColor: Color(0xff0095FF),
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer(); // Open the drawer
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff0095FF),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage(
                        'assets/profile.jpg'), // Add your profile image path
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your Name',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pushNamed(context, '/user_home'); // Navigate to Home Page
              },
            ),
            ListTile(
              leading: Icon(Icons.local_offer),
              title: Text('coupons'),
              onTap: () {
                Navigator.pushNamed(context, '/coupons');
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report bus Issues'),
              onTap: () {
                Navigator.pushNamed(context, '/reportpage'); // Navigate to Report Page
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(context, '/settings'); // Navigate to Settings Page
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pushNamed(context, '/login'); // Navigate to Login Page
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input fields for filtering
            TextField(
              controller: fromController,
              decoration: InputDecoration(labelText: 'From'),
            ),
            TextField(
              controller: toController,
              decoration: InputDecoration(labelText: 'To'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: submitSearch,
              child: Text("Submit"),
            ),
            SizedBox(height: 20),
            // Placeholder for future functionality
            Expanded(
              child: Center(
                child: Text(
                  "No bus data to display.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
