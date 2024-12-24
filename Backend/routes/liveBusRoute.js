const express = require('express');
const axios = require('axios');
const protobuf = require('protobufjs');
const router = express.Router();

// API Key and URL
const API_KEY = "cKslRjfjpiyMAcAdcBAJNCdTpeMaRzkC";
const URL = `https://otd.delhi.gov.in/api/realtime/VehiclePositions.pb?key=${API_KEY}`;

// GTFS Realtime Protobuf Schema URL
const protobufUrl = 'https://developers.google.com/gtfs-realtime/proto/vehicle_position.proto'; // Adjust this URL if needed

// Define the route to fetch real-time vehicle positions
router.get('/vehicle-positions', (req, res) => {
  axios.get(URL)
    .then(response => {
      // Load the protobuf schema and parse the data
      protobuf.load(protobufUrl, (err, root) => {
        if (err) {
          return res.status(500).json({ error: 'Error loading protobuf schema', details: err });
        }

        // Get the FeedMessage type from the loaded schema
        const FeedMessage = root.lookupType('feed.GTFSRealtime.FeedMessage');

        // Decode the response content (protobuf binary data)
        const feed = FeedMessage.decode(new Uint8Array(response.data));

        // Create an array of vehicles with their ID and location
        const vehicles = feed.entity
          .filter(entity => entity.vehicle) // Filter entities with vehicles
          .map(entity => ({
            vehicleId: entity.vehicle.id,
            latitude: entity.vehicle.position.latitude,
            longitude: entity.vehicle.position.longitude
          }));

        // Return the vehicle data in the response
        res.json(vehicles);
      });
    })
    .catch(error => {
      console.error('Error fetching data:', error);
      res.status(500).json({ error: 'Error fetching vehicle positions', details: error.message });
    });
});


module.exports = router;