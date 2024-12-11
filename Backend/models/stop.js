const mongoose = require('mongoose');

const stopSchema = new mongoose.Schema({
  stopId: { type: String, required: true },
  stopName: { type: String, required: true },
  sequenceNumber: { type: Number, required: true },
  latitude: { type: Number, required: true },
  longitude: { type: Number, required: true },
  routeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Route', required: true },
  passengerCount: { type: Number, default: 0 }, // New field to track passenger count
});
module.exports = mongoose.model('Stop', stopSchema);