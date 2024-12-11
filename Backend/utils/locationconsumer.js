const axios = require('axios');
const Bus = require('../models/bus');
const BusLocation = require('../models/busLocation');

// Function to fetch bus locations and update MongoDB
async function fetchBusLocations() {
    try {
        // Fetch active buses
        const buses = await Bus.find({ status: 'active' }).select('busId driverId');

        if (buses.length === 0) {
            console.log('No active buses found.');
            return;
        }

        for (const bus of buses) {
            const { busId, driverId } = bus;

            const response = await axios.post('http://localhost:5001/api/send-vehicle-locations', {
                busId,
                driverId,
            });

            const { latitude, longitude, timestamp, nearestStopId, scheduleId } = response.data;

            if (!latitude || !longitude || !timestamp) {
                console.log(`Incomplete location data for busId: ${busId}`);
                continue;
            }

            // Update or insert location details in MongoDB
            await BusLocation.findOneAndUpdate(
                { busId },
                {
                    $set: {
                        latitude,
                        longitude,
                        timestamp: new Date(timestamp * 1000), // Convert timestamp to Date
                        nearestStopId,
                        scheduleId,
                        startTime: new Date().toISOString(),
                    },
                },
                { upsert: true, new: true }
            );

            console.log(`Updated location for busId: ${busId}`);
        }
    } catch (error) {
        console.error('Error fetching bus locations:', error);
    }
}

module.exports  = fetchBusLocations