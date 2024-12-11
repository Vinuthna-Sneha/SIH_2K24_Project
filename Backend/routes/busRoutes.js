const express = require('express');
const { getAllBuses, getBusDetails, getBusLocationById} = require('../controllers/busController');
const router = express.Router();

router.get('/getAllBuses', getAllBuses); // API 1: Fetch all buses for source & destination
router.get('/getBusDetails/:busId', getBusDetails);
router.get('/:busId/location',getBusLocationById); // API 2: Fetch details for a specific bus

module.exports = router;
