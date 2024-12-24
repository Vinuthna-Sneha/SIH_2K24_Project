const axios = require('axios');
const Bus = require('../models/bus');
const BusLocation = require('../models/busLocation');

// Function to fetch bus locations and update MongoDB
async function fetchBusLocations() {
    try {
        // Fetch active buses
        const buses = await Bus.find({ status: 'active' }).select('busId driverId');

        if (!buses.length) {
            console.log('No active buses found.');
            return;
        }

        const busData = buses.map(bus => ({
            busId: bus.busId,
            driverId: bus.driverId,
        }));

        // Call the external API
        const response = await axios.post('http://localhost:5001/api/send-vehicle-locations', {
            buses: busData,
        });
        if(response.data.message === 'No matching vehicle locations found'){
            console.log('No matching vehicle locations found')
            return ; 
        }
        if (response.status !== 200 ) {
            console.error('Invalid response from API');
            return;
        }

        for (const location of response.data) {
            const { busId, latitude, longitude, timestamp, nearestStopId, scheduleId } = location;

            if (!busId || !latitude || !longitude || !timestamp) {
                console.log(`Incomplete location data for busId: ${busId || 'unknown'}`);
                continue;
            }

            // Upsert location details
            await BusLocation.findOneAndUpdate(
                { busId },
                {
                    $set: {
                        latitude,
                        longitude,
                        timestamp: new Date(timestamp * 1000),
                        nearestStopId: nearestStopId || null,
                        scheduleId: scheduleId || null,
                        startTime: new Date().toISOString(),
                    },
                },
                { upsert: true, new: true }
            );

            console.log(`Updated location for busId: ${busId}`);
        }
    } catch (error) {
        console.error('Error fetching bus locations:', error.message);
    }
}

module.exports = fetchBusLocations;
