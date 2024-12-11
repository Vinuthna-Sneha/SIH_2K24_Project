import 'package:flutter/material.dart';
import '../widgets/header.dart'; // Ensure to import the Header widget

class DriverNotificationScreen extends StatefulWidget {
  const DriverNotificationScreen({super.key});

  @override
  _DriverNotificationScreenState createState() => _DriverNotificationScreenState();
}

class _DriverNotificationScreenState extends State<DriverNotificationScreen> {
  // Sample notification data with seen flag
  List<Map<String, dynamic>> notifications = [
    {"message": "You have a new route assignment!", "isSeen": false},
    {"message": "Your next stop has been updated.", "isSeen": false},
    {"message": "Traffic alert in your route area!", "isSeen": false},
    {"message": "Reminder: Break time in 30 minutes.", "isSeen": false},
  ];

  void markAsSeen(int index) {
    setState(() {
      notifications[index]['isSeen'] = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(isDriver: true), // Use Header with isDriver set to true for Driver
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          return notifications[index]['isSeen']
              ? SizedBox.shrink() // If seen, hide the notification
              : Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: ListTile(
                    title: Text(
                      notifications[index]['message'],
                      style: TextStyle(fontSize: 18),
                    ),
                    leading: Icon(Icons.notifications, color: Colors.blue),
                    tileColor: Colors.white,
                    trailing: IconButton(
                      icon: Icon(Icons.check_circle, color: Colors.green),
                      onPressed: () {
                        markAsSeen(index); // Mark notification as seen
                      },
                    ),
                  ),
                );
        },
      ),
    );
  }
}

// Input field widget function
Widget inputFile({required String label, bool obscureText = false, TextInputType? keyboardType, required TextEditingController controller}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        label,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      SizedBox(height: 5),
      TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
        ),
      ),
      SizedBox(height: 10),
    ],
  );
}
