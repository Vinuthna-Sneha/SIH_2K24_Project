const express = require('express');
const router = express.Router();
const stopController = require('../controllers/stopController');
// const authMiddleware = require('../middleware/authMiddleware');
// const driverOnlyMiddleware = require('../middleware/driverOnly');

// 1. Get all stops for a specific route
router.post('/stops', stopController.getStopsForRoute);

// 2. Increment the passenger count at a specific stop
router.post('/stops/incrementPassengerCount', stopController.incrementPassengerCount);

// 3. Get the fraction of participants who depart at a specific stop
router.post('/stops/fraction', stopController.getPassengerFraction);

module.exports = router;