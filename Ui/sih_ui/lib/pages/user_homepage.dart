import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sih/pages/busdetails.dart';
import 'package:sih/pages/coupons.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  _UserHomeScreenState createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();

  List<dynamic> buses = [];
  List<dynamic> routes = [];
  List<dynamic> stops = [];
  List<dynamic> schedules = [];
  List<Map<String, dynamic>> tableData = [];
  List<Map<String, dynamic>> filteredData = [];

  @override
  void initState() {
    super.initState();
    loadJsonData();
  }

  Future<void> loadJsonData() async {
    try {
      final String busesJson = await rootBundle.loadString('assets/buses.json');
      final String routesJson =
          await rootBundle.loadString('assets/routes.json');
      final String stopsJson = await rootBundle.loadString('assets/stops.json');
      final String schedulejson =
          await rootBundle.loadString('assets/schedule.json');

      setState(() {
        buses = json.decode(busesJson);
        routes = json.decode(routesJson);
        stops = json.decode(stopsJson);
        schedules = json.decode(schedulejson);
      });

      prepareTableData();
    } catch (e) {
      print('Error loading JSON data: $e');
    }
  }

  void prepareTableData() {
    List<Map<String, dynamic>> data = [];
    for (var bus in buses) {
      final route = routes.firstWhere((r) => r['routeId'] == bus['routeId'],
          orElse: () => null);
      if (route != null) {
        final schedule = schedules.firstWhere((s) => s['busId'] == bus['busId'],
            orElse: () => null);
        final routeStops = stops
            .where((stop) => stop['routeId'] == route['routeId'])
            .map((stop) => stop['stopName'])
            .toList();

        data.add({
          'busId': bus['busId'],
          'driverId': bus['driverId'],
          'status': bus['status'],
          'routeId': bus['routeId'],
          'routeName': route['routeName'],
          'source': route['startStop'],
          'destination': route['endStop'],
          'viaStops': routeStops,
          'startTime': schedule?['startTime'],
          'endTime': schedule?['endTime'],
          'delayTime': Text("-----"), // Custom logic for delay
        });
      }
    }
    setState(() {
      tableData = data;
      filteredData = data;
    });
  }

  void filterTableData() {
    String from = fromController.text.trim().toLowerCase();
    String to = toController.text.trim().toLowerCase();

    setState(() {
      filteredData = tableData.where((data) {
        final source = data['source'].toLowerCase();
        final destination = data['destination'].toLowerCase();
        final viaStops =
            data['viaStops'].map((stop) => stop.toLowerCase()).toList();

        bool matchesFrom =
            from.isEmpty || source.contains(from) || viaStops.contains(from);
        bool matchesTo =
            to.isEmpty || destination.contains(to) || viaStops.contains(to);

        if (from.isNotEmpty && to.isNotEmpty) {
          int fromIndex = viaStops.indexOf(from);
          int toIndex = viaStops.indexOf(to);

          return fromIndex != -1 &&
              toIndex != -1 &&
              fromIndex < toIndex; // Ensure "From" comes before "To"
        }

        return matchesFrom && matchesTo;
      }).toList();
    });
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
                Navigator.pushNamed(
                    context, '/user_home'); // Navigate to Home Page
              },
            ),
            ListTile(
              leading: Icon(Icons.local_offer),
              title: Text('coupons'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RewardsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Report bus Issues'),
              onTap: () {
                Navigator.pushNamed(
                    context, '/reportpage'); // Navigate to Report Page
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Navigator.pushNamed(
                    context, '/settings'); // Navigate to Settings Page
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Handle logout functionality
                Navigator.pushNamed(
                    context, '/login'); // Navigate to Settings Page
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
              onChanged: (value) {
                filterTableData(); // Filter data dynamically on input
              },
            ),
            TextField(
              controller: toController,
              decoration: InputDecoration(labelText: 'To'),
              onChanged: (value) {
                filterTableData(); // Filter data dynamically on input
              },
            ),
            SizedBox(height: 10),
            // Link to report issues
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context, '/reportpage'); // Navigate to report page
                },
                child: Text(
                  "Report any issue?",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Table with both vertical and horizontal scrollbars
            Expanded(
              child: Scrollbar(
                thumbVisibility: true, // Show scrollbar for vertical scrolling
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical, // Vertical scrolling
                  child: Scrollbar(
                    thumbVisibility:
                        true, // Show scrollbar for horizontal scrolling
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, // Horizontal scrolling
                      child: DataTable(
                        columns: [
                          DataColumn(label: Text('Bus ID')),
                          DataColumn(label: Text('Source')),
                          DataColumn(label: Text('Destination')),
                          DataColumn(label: Text('Via Stops')),
                        ],
                        rows: filteredData.map((data) {
                          return DataRow(
                            onSelectChanged: (selected) {
                              if (selected != null && selected) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BusDetailPage(
                                      busData: data,
                                      stops: stops, // Pass stops here
                                    ),
                                  ),
                                );
                              }
                            },
                            cells: [
                              DataCell(Text(data['busId'])),
                              DataCell(Text(data['source'])),
                              DataCell(Text(data['destination'])),
                              DataCell(Text(data['viaStops'].join(", "))),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }
}
