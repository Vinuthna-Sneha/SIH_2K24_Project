const mongoose = require('mongoose');

const routeSchema = new mongoose.Schema({
  routeId: { type: String, required: true },
  routeName: { type: String, required: true },
  startStop: { type: String, required: true },
  endStop: { type: String, required: true },
  condition : { type : Boolean , default : false } , 
});

module.exports = mongoose.model('Route', routeSchema);
