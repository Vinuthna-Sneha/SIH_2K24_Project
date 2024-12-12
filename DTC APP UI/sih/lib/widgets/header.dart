import 'package:flutter/material.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  final bool isDriver;

  const Header({super.key, required this.isDriver});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.blue,
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.black), // Menu icon on left side
        onPressed: () {
          _showMenuOverlay(context);
        },
      ),
      actions: [
        IconButton(
          icon: Image.asset("assets/headerlogo.png"), // Logo on right side
          onPressed: () {
            // Handle logo tap if needed
          },
        ),
      ],
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the text in the middle
        children: [
          Text(
            "Bunch Free", // Text in white
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuOverlay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
    backgroundColor: Colors.transparent, // Set background to transparent to show the gradient
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    ),
    builder: (context) {
      return Container(
        width: MediaQuery.of(context).size.width, // Full screen width
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Center the content
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.red), // Close button with color
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile'); // Navigate to profile page
              },
              child: CircleAvatar(
                radius: 80, // Increased size for the profile image
                backgroundImage: AssetImage("assets/profile.jpg"), // Profile image
                backgroundColor: Colors.blueAccent, // Background color
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Driver Name", // Display driver's name
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // Stylish color for the name
              ),
            ),
            SizedBox(height: 20),
            // Add a gradient effect to the list tiles
            _buildListTile(
              context,
              Icons.notifications,
              "Notifications",
              '/driver_notifications',
              const Color.fromARGB(255, 233, 9, 9),
            ),
            _buildListTile(
              context,
              Icons.edit,
              "Edit Profile",
              '/edit',
              Colors.blueAccent,
            ),
            _buildListTile(
              context,
              Icons.settings,
              "Settings",
              '/settings',
              Colors.green,
            ),
            _buildListTile(
              context,
              Icons.help,
              "Help",
              '/help',
              Colors.orange,
            ),
            _buildListTile(
              context,
              Icons.logout,
              "Logout",
              '/login',
              Colors.red,
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildListTile(BuildContext context, IconData icon, String title, String route, Color iconColor) {
  return Card(
    margin: EdgeInsets.symmetric(vertical: 8),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    ),
  );
}

@override
Size get preferredSize => Size.fromHeight(kToolbarHeight);}