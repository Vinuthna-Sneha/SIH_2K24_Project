<<<<<<<< HEAD:Ui/sih_ui/lib/pages/Driver_homepage.dart
import 'package:flutter/material.dart';
import '../widgets/header.dart';
import 'package:sih/widgets/app_scrollbar.dart';
import 'package:sih/pages/Alternate_map.dart';

class DelayFromDriverScreen extends StatefulWidget {
  const DelayFromDriverScreen({super.key});

  @override
  _DelayFromDriverScreenState createState() => _DelayFromDriverScreenState();
}

class _DelayFromDriverScreenState extends State<DelayFromDriverScreen> {
  
  bool showSuggestions = false;

  Map<String, bool> delayReasons = {
    "Road Block": false,
    "Heavy Traffic": false,
    "Road Accident": false,
    "Overcrowd": false,
  };

  TextEditingController previousBusDelayController = TextEditingController();
  TextEditingController presentBusDelayController = TextEditingController();
  TextEditingController nextBusDelayController = TextEditingController();
  TextEditingController otherReasonController = TextEditingController();
  TextEditingController delayTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPreviousBusDelay(); // Fetch delay for the previous bus on load
  }

  Future<void> fetchPreviousBusDelay() async {
    await Future.delayed(
        Duration(seconds: 2)); // Replace with actual backend call
    String fetchedDelay = "5 min"; // Example delay fetched from backend
    setState(() {
      previousBusDelayController.text = fetchedDelay;
    });
  }

  void submitDelayInfo() {
    print("Previous Bus Delay: ${previousBusDelayController.text}");
    print("Present Bus Delay: ${presentBusDelayController.text}");
    print("Next Bus Delay: ${nextBusDelayController.text}");
    print("Other Reason: ${otherReasonController.text}");
    print("Delay Time: ${delayTimeController.text}");

    delayReasons.forEach((reason, isSelected) {
      if (isSelected) {
        print("Selected Reason: $reason");
      }
    });

    if (otherReasonController.text.isNotEmpty) {
      print("Other Specified Reason: ${otherReasonController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(
            isDriver: true), // Use Header with isDriver set to true for Driver
        body: AppScrollbar(
          thumbVisibility: false,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[ 
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text("Delay of the Previous Bus: "),
                              Expanded(
                                child: TextField(
                                  controller: previousBusDelayController,
                                  decoration: InputDecoration(
                                    hintText: "Fetching...",
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: true, 
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text("Delay of the Present Bus  : "),
                              Expanded(
                                child: TextField(
                                  controller: presentBusDelayController,
                                  decoration: InputDecoration(
                                    hintText: "Enter delay in minutes",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text("Delay of the Next Bus        : "),
                              Expanded(
                                child: TextField(
                                  controller: nextBusDelayController,
                                  decoration: InputDecoration(
                                    hintText: "Enter delay in minutes",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Toggle for suggestions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Suggestions for Next Bus",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Switch(
                                value: showSuggestions,
                                onChanged: (bool value) {
                                  setState(() {
                                    showSuggestions = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          if (showSuggestions) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: delayReasons.keys.map((String key) {
                                return CheckboxListTile(
                                  title: Text(key),
                                  value: delayReasons[key],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      delayReasons[key] = value ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            TextField(
                              controller: otherReasonController,
                              decoration: InputDecoration(
                                labelText: "Other Reason",
                                hintText: "Specify other reason for delay",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 15),
                            TextField(
                              controller: delayTimeController,
                              decoration: InputDecoration(
                                labelText: "Delay Duration",
                                hintText: "Enter delay in minutes",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: submitDelayInfo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff0095FF),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // Alternate Route Button
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlternateRouteMap(coordinates: [ ],) 
                                    ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Alternate Route",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
        ));
  }
}
========
import 'package:flutter/material.dart';
import '../widgets/header.dart';
import 'package:sih/widgets/app_scrollbar.dart';
import 'package:sih/pages/Alternate_map.dart';
import 'package:sih/pages/tickets.dart';
class DelayFromDriverScreen extends StatefulWidget {
  const DelayFromDriverScreen({super.key});

  @override
  _DelayFromDriverScreenState createState() => _DelayFromDriverScreenState();
}

class _DelayFromDriverScreenState extends State<DelayFromDriverScreen> {
  
  bool showSuggestions = false;

  Map<String, bool> delayReasons = {
    "Road Block": false,
    "Heavy Traffic": false,
    "Road Accident": false,
    "Overcrowd": false,
  };

  TextEditingController previousBusDelayController = TextEditingController();
  TextEditingController presentBusDelayController = TextEditingController();
  TextEditingController nextBusDelayController = TextEditingController();
  TextEditingController otherReasonController = TextEditingController();
  TextEditingController delayTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPreviousBusDelay(); // Fetch delay for the previous bus on load
  }

  Future<void> fetchPreviousBusDelay() async {
    await Future.delayed(
        Duration(seconds: 2)); // Replace with actual backend call
    String fetchedDelay = "5 min"; // Example delay fetched from backend
    setState(() {
      previousBusDelayController.text = fetchedDelay;
    });
  }

  void submitDelayInfo() {
    print("Previous Bus Delay: ${previousBusDelayController.text}");
    print("Present Bus Delay: ${presentBusDelayController.text}");
    print("Next Bus Delay: ${nextBusDelayController.text}");
    print("Other Reason: ${otherReasonController.text}");
    print("Delay Time: ${delayTimeController.text}");

    delayReasons.forEach((reason, isSelected) {
      if (isSelected) {
        print("Selected Reason: $reason");
      }
    });

    if (otherReasonController.text.isNotEmpty) {
      print("Other Specified Reason: ${otherReasonController.text}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: Header(
            isDriver: true), // Use Header with isDriver set to true for Driver
        body: AppScrollbar(
          thumbVisibility: false,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[ 
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: [
                              Text("Delay of the Previous Bus: "),
                              Expanded(
                                child: TextField(
                                  controller: previousBusDelayController,
                                  decoration: InputDecoration(
                                    hintText: "Fetching...",
                                    border: OutlineInputBorder(),
                                  ),
                                  readOnly: true, 
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text("Delay of the Present Bus  : "),
                              Expanded(
                                child: TextField(
                                  controller: presentBusDelayController,
                                  decoration: InputDecoration(
                                    hintText: "Enter delay in minutes",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              Text("Delay of the Next Bus        : "),
                              Expanded(
                                child: TextField(
                                  controller: nextBusDelayController,
                                  decoration: InputDecoration(
                                    hintText: "Enter delay in minutes",
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Toggle for suggestions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Suggestions for Next Bus",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Switch(
                                value: showSuggestions,
                                onChanged: (bool value) {
                                  setState(() {
                                    showSuggestions = value;
                                  });
                                },
                              ),
                            ],
                          ),

                          if (showSuggestions) ...[
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: delayReasons.keys.map((String key) {
                                return CheckboxListTile(
                                  title: Text(key),
                                  value: delayReasons[key],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      delayReasons[key] = value ?? false;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            TextField(
                              controller: otherReasonController,
                              decoration: InputDecoration(
                                labelText: "Other Reason",
                                hintText: "Specify other reason for delay",
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(height: 15),
                            TextField(
                              controller: delayTimeController,
                              decoration: InputDecoration(
                                labelText: "Delay Duration",
                                hintText: "Enter delay in minutes",
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: submitDelayInfo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff0095FF),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Submit",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AlternateRouteMap(coordinates: [ ],) 
                                    ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Alternate Route",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StopTrackerPage() 
                                    ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Text(
                                "Tickets",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
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
        ));
  }
}
>>>>>>>> 987a5fac30be042ca57dee5b0ec046ab6cf23aa8:DTC APP UI/sih/lib/pages/Driver_homepage.dart
