const Stop = require('../models/stop');

// Update passenger count for a stop
exports.updatePassengerCount = async (req, res) => {
  try {
    const { stopId, count } = req.body;

    if (!stopId || typeof count !== 'number') {
      return res.status(400).json({ message: 'Invalid stopId or count.' });
    }

    const stop = await Stop.findOne({ stopId });
    if (!stop) {
      return res.status(404).json({ message: 'Stop not found.' });
    }

    stop.passengerCount += count;
    await stop.save();

    res.status(200).json({ message: 'Passenger count updated successfully.', passengerCount: stop.passengerCount });
  } catch (error) {
    res.status(500).json({ message: 'Server error.', error: error.message });
  }
};
exports.getPassengerFraction = async (req, res) => {
    try {
      const { stopId } = req.params;
  
      const stops = await Stop.find({ routeId: req.body.routeId }); // Assuming routeId is passed in request body
      if (!stops || stops.length === 0) {
        return res.status(404).json({ message: 'Stops not found for the route.' });
      }
  
      const totalPassengers = stops.reduce((sum, stop) => sum + stop.passengerCount, 0);
      const stop = stops.find(s => s.stopId === stopId);
  
      if (!stop) {
        return res.status(404).json({ message: 'Stop not found.' });
      }
  
      const fraction = totalPassengers === 0 ? 0 : stop.passengerCount / totalPassengers;
  
      res.status(200).json({
        stopId,
        stopName: stop.stopName,
        passengerCount: stop.passengerCount,
        fraction,
      });
    } catch (error) {
      res.status(500).json({ message: 'Server error.', error: error.message });
    }
  };
  