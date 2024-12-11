// Routes (routes/stopRoutes.js)
const express = require('express');
const { updatePassengerCount, getPassengerFraction } = require('../controllers/stopController');
const authMiddleware = require('../middlewares/authMiddleware');
const driverOnlyMiddleware = require('../middlewares/driverOnly');

const router = express.Router();

router.post('/updatePassengerCount', authMiddleware, driverOnlyMiddleware, updatePassengerCount);
router.get('/getPassengerFraction/:stopId', authMiddleware, driverOnlyMiddleware, getPassengerFraction);

module.exports = router;