const express = require('express');

const Bus = require('../models/bus');
const Route = require('../models/route');
const Schedule = require('../models/schedule');
const Driver = require('../models/user');

const router = express.Router();

// API endpoint to fetch upcoming buses and drivers' emails for a route
router.post('/upcoming-buses', async (req, res) => {
    const { routeId } = req.body;
    try {
        // Find the route using the routeId
        const route = await Route.findOne({ routeId });

        if (!route) {
            return res.status(404).json({ message: 'Route not found' });
        }

        // Find all active buses on the route using the route's _id
        const buses = await Bus.find({ routeId: route._id, status: 'active' });

        if (buses.length === 0) {
            return res.status(404).json({ message: 'No active buses found for this route' });
        }

        // Fetch drivers' emails for the buses with upcoming schedules
        const busDetails = await Promise.all(
            buses.map(async (bus) => {
                const schedule = await Schedule.findOne({ busId: bus._id, routeId: route._id });

                if (schedule) {
                    const driver = await User.findById(bus.driverId );
                    return {
                        busId: bus.busId,
                        driverEmail: driver ? driver.email : 'Email not found',
                    };
                }
                return null;
            })
        );

        // Filter out null results
        const filteredDetails = busDetails.filter(Boolean);

        if (filteredDetails.length === 0) {
            return res.status(200).json({ message: 'No upcoming buses found for this route' });
        }

        return res.json({ routeId, buses: filteredDetails });
    } catch (err) {
        console.error('Error fetching buses:', err);
        return res.status(500).json({ message: 'Internal server error' });
    }
});

module.exports = router