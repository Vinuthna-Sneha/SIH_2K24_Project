const Bus = require('../models/bus');
const Route = require('../models/route');
const Stop = require('../models/stop');
const Schedule = require('../models/schedule');
const BusLocation = require('../models/busLocation');


// Fetch all buses for a given source and destination
exports.getAllBuses = async (req, res) => {
  const { source, destination } = req.body
  console.log(source);
  console.log(destination);
  

  try {
    // Find routes that start at the source and end at the destination
    const routes = await Route.find({ startStop: source, endStop: destination });

    if (routes.length === 0) { 
      return res.status(404).json({ message: 'No routes found for the given source and destination.' });
    }

    // Find all buses assigned to these routes
    const buses = await Bus.find({ routeId: { $in: routes.map(route => route._id) }, status: 'active' });
    console.log(buses.length);

    res.status(200).json({ buses });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Fetch details of a specific bus
exports.getBusDetails = async (req, res) => {
  const { busId } = req.params;
  console.log(busId) 
  try {
    const bus = await Bus.findOne({ busId }).populate('routeId');
    if (!bus) {
      return res.status(404).json({ message: 'Bus not found.' });
    }

    // Fetch schedule and location details
    const schedule = await Schedule.findOne({ busId: bus._id });
    const location = await BusLocation.findOne({ scheduleId: schedule._id });

    res.status(200).json({ bus, schedule, location });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};


// Controller to fetch the location of a bus by its ID
exports.getBusLocationById = async (req, res) => {
    try {
        const { busId } = req.params;

        // Validate input
        if (!busId) {
            return res.status(400).json({ message: 'Bus ID is required' });
        }

        // Check if the bus exists in the database
        const bus = await Bus.findOne({ busId });
        if (!bus) {
            return res.status(404).json({ message: 'Bus not found' });
        }

        // Fetch the latest location of the bus from the BusLocation collection
        const busLocation = await BusLocation.findOne({ busId })
            .sort({ timestamp: -1 }) // Sort by timestamp to get the most recent entry
            .populate('nearestStopId', 'name') // Populate nearest stop details if needed
            .populate('scheduleId', 'scheduleDetails'); // Populate schedule details if needed

        if (!busLocation) {
            return res.status(404).json({ message: 'Location not found for the specified bus' });
        }

        // Respond with the bus location details
        return res.status(200).json({
            busId: bus.busId,
            location: {
                latitude: busLocation.latitude,
                longitude: busLocation.longitude,
                timestamp: busLocation.timestamp,
                nearestStop: busLocation.nearestStopId,
                schedule: busLocation.scheduleId,
            },
        });
    } catch (error) {
        console.error('Error fetching bus location:', error);
        return res.status(500).json({ message: 'Internal server error' });
    }
};



