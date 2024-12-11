var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
require('dotenv').config();
var mongoose = require("mongoose"); 
const busRoutes = require('./routes/busRoutes');
// const consumer = require("./setup/delaykafka") ; 
// const locconsumer = require('./setup/locationkafka') ; 
const fetchDelayTimes  = require('./utils/delayconsumer'); 
const fetchBusLocations = require('./utils/locationconsumer')
 // Use mongoose for MongoDB connection
const uri =process.env.MONGODB_URI;
console.log(uri);
const kafka = require('kafka-node');
var loginRouter = require('./routes/login');
var stopsRouter = require('./routes/stopRoutes');
var SignupRouter = require('./routes/signup') ; 
var SendOtpRouter = require('./routes/sendotp')
var VerifyOtpRouter = require('./routes/verifyotp');
var reportRouter = require('./routes/reportRoutes') ; 
// var liveLocationRouter = require('./routes/liveBusRoute') ; 


var app = express();
// // Kafka Client Configuration
// const client = new kafka.KafkaClient({ kafkaHost: 'localhost:9092' });

// // Kafka Consumers for multiple topics
// const topics = [
//   { topic: 'bus-delays', partition: 0 },
//   { topic: 'vehicle_locations', partition: 0 }
// ];

// const consumer = new kafka.Consumer(client, topics, { autoCommit: true });
// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');



app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/api', SignupRouter );
app.use('/api', loginRouter) ; 
app.use('/api',SendOtpRouter) ; 
app.use('/api',VerifyOtpRouter) ; 
// app.use('/api' , liveLocationRouter); 
app.use('/api' , reportRouter ) ;
app.use('/api/stopRoutes',stopsRouter);
// app.use('/api' , reporterRouter) ;  


app.use('/api/bus', busRoutes);
// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});


mongoose
  .connect(process.env.MONGODB_URI)
  .then(() => {
    console.log('MongoDb is connected');
  })
  .catch((err) => {
    console.log(err);
  });
  console.log("testing2");

//   setInterval(fetchDelayTimes, 1 * 60 * 1000); // 2 minutes

//   // Kafka consumer for delay times
//   consumer.on('message', async (message) => {
//       try {
//           const data = JSON.parse(message.value);
//           const { busId, delayTime } = data;
  
//           // Update delay time in MongoDB
//           await Bus.findOneAndUpdate(
//               { busId },
//               { $set: { delayTime } },
//               { new: true }
//           );
//           console.log(`Updated delay time for busId: ${busId}`);
//       } catch (error) {
//           console.error('Error updating MongoDB:', error);
//       }
//   });
  
//   consumer.on('error', (err) => {
//       console.error('Kafka Consumer error:', err);
//   });


// // Kafka topic to consume
// locconsumer.subscribe(['vehicle_locations']);

// // Consume messages from Kafka
// locconsumer.on('message', async (message) => {
//   const vehicleData = JSON.parse(message.value);

//   const busLocation = new BusLocation({
//     locationId: `location_${vehicleData.vehicle_id}`,
//     busId: vehicleData.vehicle_id,
//     driverId: vehicleData.driver_id,
//     latitude: vehicleData.latitude,
//     longitude: vehicleData.longitude,
//     timestamp: new Date(vehicleData.timestamp * 1000), // Convert to Date object
//     nearestStopId: null, // Add logic for nearest stop if needed
//     scheduleId: null, // Add logic for schedule if needed
//     startTime: new Date().toISOString()
//   });

//   try {
//     // Save the bus location data to MongoDB
//     await busLocation.save();
//     console.log(`Saved location data for vehicle ${vehicleData.vehicle_id}`);
//   } catch (error) {
//     console.error('Error saving location:', error);
//   }
// });

// // Error handling
// consumer.on('error', (err) => {
//   console.error('Kafka Consumer Error:', err);
// });
  
// Consumer for bus delays
// Run fetchDelayTimes every 2 minutes
// setInterval(fetchDelayTimes, 2 * 60 * 1000);

// Run fetchBusLocations every 5 minutes
//


// Handle messages
// consumer.on('message', async (message) => {
//   try {
//     const data = JSON.parse(message.value);

//     if (message.topic === 'bus-delays') {
//       // Handle bus delay messages
//       await Bus.findOneAndUpdate(
//         { busId: data.busId },
//         { delayTime: data.delayTime, lastUpdated: new Date(data.timestamp) },
//         { upsert: true, new: true }
//       );
//       console.log(`Updated delay time for busId: ${data.busId}`);
//     } else if (message.topic === 'vehicle_locations') {
//       // Handle vehicle location messages
//       const location = new BusLocation({
//         busId: data.bus_id,
//         latitude: data.latitude,
//         longitude: data.longitude,
//         timestamp: new Date(data.timestamp * 1000)
//       });

//       await location.save();
//       console.log(`Saved location for busId: ${data.bus_id}`);
//     }
//   } catch (err) {
//     console.error(`Error processing message from topic ${message.topic}:`, err);
//   }
// });

// Error handling
//consumer.on('error', (err) => console.error('Kafka Consumer Error:', err));


module.exports = app;


