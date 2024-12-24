const mongoose = require('mongoose');

const busSchema = new mongoose.Schema({
  busId: { type: String, required: true },
  driverId: { type: String, required: true },
  status: { type: String, enum: ['active', 'inactive'], required: true },
  routeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Route', required: true },
});

module.exports = mongoose.model('Bus', busSchema);
