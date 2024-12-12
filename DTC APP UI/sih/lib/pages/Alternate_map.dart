// File: alternate_route_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:sih/widgets/location_service.dart';

class AlternateRouteMap extends StatefulWidget {
  final List<Map<String, double>> coordinates; // List of Lat/Lng coordinates for the route

  const AlternateRouteMap({
    super.key,
    required this.coordinates,
  });

  @override
  _AlternateRouteMapState createState() => _AlternateRouteMapState();
}

class _AlternateRouteMapState extends State<AlternateRouteMap> {
  final LocationService _locationService = LocationService(); // LocationService for fetching user location
  final MapController _mapController = MapController(); // MapController to move map center
  LatLng? userLocation; // User's current location

  // Function to fetch the user's location and center the map
  Future<void> fetchLocation() async {
    final locationData = await _locationService.getLocation();
    if (locationData != null &&
        locationData.latitude != null &&
        locationData.longitude != null) {
      setState(() {
        userLocation = LatLng(locationData.latitude!, locationData.longitude!);
      });

      // Move the map center to the user's location
      _mapController.move(userLocation!, 14.0);

      // Show a message when user location is fetched
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "User Location: Lat ${locationData.latitude}, Long ${locationData.longitude}",
          ),
        ),
      );
    } else {
      // Show an error message if location is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Unable to fetch location. Please enable location services."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alternate Route Map'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController, // Attach MapController
            options: MapOptions(
              initialCenter: widget.coordinates.isNotEmpty
                  ? LatLng(
                      widget.coordinates.first['latitude']!,
                      widget.coordinates.first['longitude']!,
                    )
                  : LatLng(28.6139, 77.2090), // Default to a city if no coordinates are passed
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              MarkerLayer(
                markers: [
                  ...widget.coordinates.map(
                    (coord) => Marker(
                      point: LatLng(coord['latitude']!, coord['longitude']!),
                      width: 60.0,
                      height: 60.0,
                      child: const Icon(
                        Icons.location_on,
                        size: 40.0,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  if (userLocation != null)
                    Marker(
                      point: userLocation!,
                      width: 80.0,
                      height: 80.0,
                      child: const Icon(
                        Icons.person_pin_circle,
                        size: 50.0,
                        color: Colors.blue,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: fetchLocation, // Fetch user's location on button click
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
