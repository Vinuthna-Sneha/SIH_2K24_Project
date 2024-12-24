const mongoose = require('mongoose');
const Stop = require('../models/stop');
const Route = require('../models/route');

// 1. Get all stops for a specific route



exports.getStopsForRoute = async (req, res) => {
  try {
    const { routeName } = req.body;  // Use routeName instead of routeId

    const stops = await Stop.find({ routeName }).sort({ sequenceNumber: 1 });

    if (!stops || stops.length === 0) {
      return res.status(404).json({ message: 'No stops found for this route.' });
    }

    res.status(200).json(stops);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Error fetching stops for the route.' });
  }
};


// 2. Increment the passenger count at a specific stop
exports.incrementPassengerCount = async (req, res) => {
    try {
      const { stopName, passengerCount } = req.body;
      const stop = await Stop.findOne({ stopName });
  
      if (!stop) {
        return res.status(404).json({ message: 'Stop not found.' });
      }
  
      stop.passengerCount += passengerCount;
      await stop.save();
  
      res.status(200).json({ message: 'Passenger count updated successfully.' });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error updating passenger count.' });
    }
  };
  

// 3. Get the fraction of participants who depart at a specific stop
exports.getPassengerFraction = async (req, res) => {
    try {
      const { routeName, stopName } = req.body;
  
      const stops = await Stop.find({ routeName });
  
      if (!stops || stops.length === 0) {
        return res.status(404).json({ message: 'No stops found for this route.' });
      }
  
      const totalPassengers = stops.reduce((total, stop) => total + stop.passengerCount, 0);
      const stop = stops.find(s => s.stopName === stopName);
  
      if (!stop) {
        return res.status(404).json({ message: 'Stop not found.' });
      }
  
      const fraction = totalPassengers > 0 ? (stop.passengerCount / totalPassengers) : 0;
      res.status(200).json({ fraction });
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Error fetching passenger fraction.' });
    }
  };