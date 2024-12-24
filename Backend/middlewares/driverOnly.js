// Middleware (middleware/driverOnly.js)
const driverOnlyMiddleware = (req, res, next) => {
    if (req.user && req.user.role === 'driver') {
      next();
    } else {
      return res.status(403).json({ message: 'Access denied. Drivers only.' });
    }
  };
  
  module.exports = driverOnlyMiddleware;