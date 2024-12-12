import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StopTrackerPage extends StatefulWidget {
  const StopTrackerPage({Key? key}) : super(key: key);

  @override
  State<StopTrackerPage> createState() => _StopTrackerPageState();
}

class _StopTrackerPageState extends State<StopTrackerPage> {
  final List<String> allStops = ["Stop A", "Stop B", "Stop C", "Stop D", "Stop E"];
  String? currentStop;
  Map<String, int> stopCounts = {};

  @override
  void initState() {
    super.initState();
    // Initialize all counts to 0
    for (var stop in allStops) {
      stopCounts[stop] = 0;
    }
  }

  List<String> getUpcomingStops() {
    if (currentStop == null) return [];
    int index = allStops.indexOf(currentStop!);
    return allStops.sublist(index + 1);
  }

  void sendCountToBackend(String stop, int count) async {
    try {
      var url = Uri.parse("http://your-backend-endpoint/api/update_stop_count");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"stop": stop, "count": count}),
      );

      if (response.statusCode == 200) {
        print("Successfully updated count for $stop: $count");
      } else {
        print("Failed to update count for $stop: ${response.body}");
      }
    } catch (e) {
      print("Error sending count to backend: $e");
    }
  }

  void submitAllCounts() async {
    print("Submitting all stop counts:");
    stopCounts.forEach((stop, count) {
      print("$stop: $count");
    });

    // Optionally, send all data to the backend in one request
    try {
      var url = Uri.parse("http://your-backend-endpoint/api/submit_all_counts");
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(stopCounts),
      );

      if (response.statusCode == 200) {
        print("Successfully submitted all counts");
      } else {
        print("Failed to submit all counts: ${response.body}");
      }
    } catch (e) {
      print("Error submitting all counts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stop Tracker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              hint: const Text("Select Current Stop"),
              value: currentStop,
              isExpanded: true,
              items: allStops.map((stop) {
                return DropdownMenuItem<String>(
                  value: stop,
                  child: Text(stop),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  currentStop = value;
                });
              },
            ),
            const SizedBox(height: 20),
            Text(
              "Upcoming Stops:",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: getUpcomingStops().length,
                itemBuilder: (context, index) {
                  String stop = getUpcomingStops()[index];
                  return Card(
                    child: ListTile(
                      title: Text(stop),
                      subtitle: Text("Number of People: ${stopCounts[stop] ?? 0}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (stopCounts[stop]! > 0) {
                                  stopCounts[stop] = stopCounts[stop]! - 1;
                                  sendCountToBackend(stop, stopCounts[stop]!);
                                }
                              });
                              print("Decreased count for $stop: ${stopCounts[stop]}");
                            },
                            icon: const Icon(Icons.remove, color: Colors.red),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                stopCounts[stop] = stopCounts[stop]! + 1;
                                sendCountToBackend(stop, stopCounts[stop]!);
                              });
                              print("Increased count for $stop: ${stopCounts[stop]}");
                            },
                            icon: const Icon(Icons.add, color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitAllCounts,
                child: const Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
