import 'package:flutter/material.dart';
import 'package:sih/pages/viewmap.dart';

class BusDetailPage extends StatelessWidget {
  final Map<String, dynamic> busData;
  final List<dynamic> stops; // List of all stops from stops.json

  const BusDetailPage({super.key, required this.busData, required this.stops});

  @override
  Widget build(BuildContext context) {
    // Fetch latitudes and longitudes of via stops based on routeId
    List<Map<String, double>> coordinates =
        _getCoordinates(busData['routeId'], busData['viaStops']);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Details"),
        backgroundColor: const Color(0xff0095FF),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bus Details Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: const Color(0xffE3F2FD),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                  child:Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Bus Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff1565C0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _detailRow("Bus ID", busData['busId']),
                    _detailRow("Driver ID", busData['driverId']),
                    _detailRow("Status", busData['status']),
                    _detailRow("Route ID", busData['routeId']),
                    _detailRow("Route Name", busData['routeName']),
                    _detailRow("Start Stop", busData['source']),
                    _detailRow("End Stop", busData['destination']),
                    _detailRow(
                        "Via Stops", busData['viaStops']?.join("\n") ?? 'N/A'),
                  ],
                ),
              ),
            ),
            ),
            const SizedBox(height: 20),

            // Schedule Details Card
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: const Color(0xffFFF3E0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Schedule Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xffE65100),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _detailRow("Start Time", busData['startTime']),
                    _detailRow("End Time", busData['endTime']),
                    _detailRow(
                        "Delay Time", busData['delayTime'] ?? 'No Delay'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // View Map Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Viewmap(
                        routeId: busData['routeId'],
                        viaStops: busData['viaStops'],
                        coordinates: coordinates, // Pass coordinates here
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: const Color(0xff4CAF50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "View Map",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom row for displaying details
  Widget _detailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8), // Add space between label and value
          Text(
            value?.toString() ?? "N/A",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Function to fetch coordinates of via stops for the route
  List<Map<String, double>> _getCoordinates(
      String routeId, List<dynamic> viaStops) {
    final List<String> viaStopsStrings = viaStops.cast<String>();

    return stops
        .where((stop) =>
            stop['routeId'] == routeId &&
            viaStopsStrings
                .contains(stop['stopName'])) // Filter viaStops for routeId
        .map((stop) => {
              'latitude': (stop['latitude'] as num)
                  .toDouble(), // Explicitly cast to double
              'longitude': (stop['longitude'] as num)
                  .toDouble(), // Explicitly cast to double
            })
        .toList(); // Convert to a list
  }
}
