import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sih/widgets/location_service.dart';

class Viewmap extends StatefulWidget {
  final String routeId;
  final List<dynamic> viaStops;
  final List<Map<String, double>> coordinates; // Latitudes and Longitudes of viaStops

  const Viewmap({
    super.key,
    required this.routeId,
    required this.viaStops,
    required this.coordinates,
  });

  @override
  _ViewmapState createState() => _ViewmapState();
}

class _ViewmapState extends State<Viewmap> {
  final LocationService _locationService = LocationService(); // Instance of LocationService
  final MapController _mapController = MapController(); // MapController to update map center
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

      // Center the map on the user's location
      _mapController.move(userLocation!, 14.0);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Centered on user location: Lat ${locationData.latitude}, Long ${locationData.longitude}",
          ),
        ),
      );
    } else {
      // Show an error message if unable to fetch location
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              const Text("Unable to fetch location. Please enable location services."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Route: ${widget.routeId}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.coordinates.isNotEmpty
                  ? LatLng(widget.coordinates.first['latitude']!, widget.coordinates.first['longitude']!)
                  : LatLng(28.6139, 77.2090), // Default center
              initialZoom: 12.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                  ),
                ],
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
              onPressed: fetchLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
