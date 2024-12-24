const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    match: /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  },
  psbBadge: {
    type: String,
    unique: true,
    sparse: true // Unique only for drivers who have a badge
  },
  routeNumber: {
    type: Number,
    min: 1,
    max: 9999,
    required: function () { return this.role === 'driver'; } // Only required for drivers
  },
  role: {
    type: String,
    enum: ['user', 'driver'],
    required: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  otp: {
    type: Number,
    min: 1000,
    max: 9999
  },
  otpExpires: {
    type: Date
  }
}, {
  timestamps: true
});

module.exports = mongoose.model('User', userSchema);
