const mongoose = require('mongoose');

const stopSchema = new mongoose.Schema({
  stopId: { type: String, required: true },
  stopName: { type: String, required: true },
  sequenceNumber: { type: Number, required: true },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  routeName: { type: String, ref: 'Route', required: true },  // Changed from ObjectId to routeName
  passengerCount: { type: Number, default: 0 },
});


module.exports = mongoose.model('Stop', stopSchema);

