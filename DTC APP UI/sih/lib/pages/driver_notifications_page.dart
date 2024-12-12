import 'package:flutter/material.dart';
import '../widgets/header.dart';
import 'package:sih/widgets/app_scrollbar.dart';

class DriverNotificationScreen extends StatefulWidget {
  const DriverNotificationScreen({super.key});

  @override
  _DriverNotificationScreenState createState() =>
      _DriverNotificationScreenState();
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

  void deleteNotification(int index) {
    setState(() {
      notifications.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
          isDriver: true), // Use Header with isDriver set to true for Driver
      body: AppScrollbar(
        thumbVisibility: false,
        child: notifications.isEmpty
            ? const Center(
                child: Text(
                  "No Notifications",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(notifications[index]['message']),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    onDismissed: (direction) {
                      deleteNotification(index); // Delete notification
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Notification deleted'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: notifications[index]['isSeen']
                        ? const SizedBox.shrink() // If seen, hide the notification
                        : Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: ListTile(
                              title: Text(
                                notifications[index]['message'],
                                style: const TextStyle(fontSize: 18),
                              ),
                              leading: const Icon(Icons.notifications,
                                  color: Colors.blue),
                              tileColor: Colors.white,
                              trailing: IconButton(
                                icon: const Icon(Icons.check_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  markAsSeen(index); // Mark notification as seen
                                },
                              ),
                            ),
                          ),
                  );
                },
              ),
      ),
    );
  }
}

// Input field widget function
Widget inputFile(
    {required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    required TextEditingController controller}) {
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }

          return null;
        },
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
