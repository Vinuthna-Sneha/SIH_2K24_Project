const mongoose = require('mongoose');

const busLocationSchema = new mongoose.Schema({
    locationId: { type: String, required: true },
    busId: { type: String, required: true }, // Add reference to busId
    latitude: { type: Number, required: true },
    longitude: { type: Number, required: true },
    timestamp: { type: Date, required: true },
    nearestStopId: { type: mongoose.Schema.Types.ObjectId, ref: 'Stop', required: true },
    scheduleId: { type: mongoose.Schema.Types.ObjectId, ref: 'Schedule', required: true },
    delayTime: { type: Number, default: 0 },
    startTime: { type: String, required: true },
});

module.exports = mongoose.model('BusLocation', busLocationSchema);
