const axios = require('axios');
const Bus = require('../models/bus');

// Function to fetch delay times and update MongoDB
async function fetchDelayTimes() {
    try {
        // Fetch active buses
        const buses = await Bus.find({ status: 'active' }).select('busId driverId routeId');

        if (buses.length === 0) {
            console.log('No active buses found.');
            return;
        }

        // Prepare data for delay prediction
        const busData = buses.map(bus => ({
            busId: bus.busId,
            driverId: bus.driverId,
            time: new Date().toLocaleTimeString('en-US', { hour12: false }), // Current time (e.g., "10:00:00")
            trafficDensity: Math.floor(Math.random() * 10) + 1, // Random traffic density (1-10)
            speed: (Math.random() * 60 + 20).toFixed(2), // Random speed (20-80 km/h)
            weatherType: Math.floor(Math.random() * 3) + 1, // Random weather type (1, 2, 3)
        }));

        const response = await axios.post('http://localhost:5001/api/get-bus-delays', { buses: busData });

        const delayTimes = response.data.delayTimes;

        if (!delayTimes || delayTimes.length === 0) {
            console.log('No delay times received.');
            return;
        }

        // Update delay time for each bus in MongoDB
        for (const data of delayTimes) {
            const { busId, delayTime } = data;

            await Bus.findOneAndUpdate(
                { busId },
                { $set: { delayTime } },
                { new: true }
            );
            console.log(`Updated delay time for busId: ${busId}`);
        }
    } catch (error) {
        console.error('Error fetching delay times from Python:', error);
    }

}
module.exports = fetchDelayTimes 
