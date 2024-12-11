const express = require('express');
const axios = require('axios'); // Ensure axios is imported
const router = express.Router();

// Assuming you have configured and imported your Mongoose model for `Bus`
const Bus = require('../models/bus');

// Report API
router.post('/report', async (req, res) => {
    const {
        bus_id, // Added bus_id
        current_latitude,
        current_longitude,
        scheduled_latitude,
        scheduled_longitude,
        reported_by,
        report_type,
        report_location_latitude,
        report_location_longitude
    } = req.body;

    // Validate input
    if (
        !bus_id || !current_latitude || !current_longitude ||
        !scheduled_latitude || !scheduled_longitude || 
        !report_type || !reported_by ||
        !report_location_latitude || !report_location_longitude
    ) {
        return res.status(400).json({ error: 'Missing required fields' });
    }

    try {
        // Call Flask API
        const flaskResponse = await axios.post('http://localhost:5001/get-report-info', {
            current_latitude,
            current_longitude,
            scheduled_latitude,
            scheduled_longitude,
            reported_by,
            report_type,
            report_location_latitude,
            report_location_longitude
        });

        // Handle Flask API response
        const { estimated_delay_minutes, suggestions } = flaskResponse.data;

        // Update Bus document in the database
        const updateResult = await Bus.updateOne(
            { bus_id }, // Use the bus_id to find the specific bus
            { $set: { delayTime: estimated_delay_minutes } } // Update the delayTime
        );

        // Check if the update was successful
        if (updateResult.modifiedCount === 0) {
            return res.status(404).json({ error: 'Bus not found or no changes made' });
        }

        // Send the response back to the client
        res.status(200).json({ estimated_delay_minutes, suggestions });
    } catch (error) {
        console.error('Error fetching data from Flask:', error.message);
        res.status(500).json({ error: 'Error fetching report data' });
    }
});

module.exports = router;

