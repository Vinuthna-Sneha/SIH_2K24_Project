const mongoose = require('mongoose');

const scheduleSchema = new mongoose.Schema({
  scheduleId: { type: String, required: true },
  startTime: { type: String, required: true },
  endTime: { type: String, required: true },
  routeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Route', required: true },
  busId: { type: mongoose.Schema.Types.ObjectId, ref: 'Bus', required: true },
});

module.exports = mongoose.model('Schedule', scheduleSchema);
