const mongoose = require('mongoose');
const { faker } = require('@faker-js/faker');
const Bus = require('../models/bus');
const Route = require('../models/route');
const Stop = require('../models/stop');
const Schedule = require('../models/schedule');
const BusLocation = require('../models/busLocation');

// MongoDB connection string
const mongoUri = 'mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+2.3.3';

// Connect to MongoDB
mongoose.connect(mongoUri)
  .then(() => console.log('Connected to MongoDB successfully.'))
  .catch((err) => {
    console.error('Failed to connect to MongoDB:', err.message);
    process.exit(1); // Exit if the connection fails
  });
faker.number.int({ min: 100, max: 999 })


// Ensure all models (Bus, Route, Stop, Schedule, BusLocation) are correctly imported

const generateRandomData = async () => {
  try {
    console.log("Clearing existing data...");
    await Promise.all([
      Bus.deleteMany({}),
      Route.deleteMany({}),
      Stop.deleteMany({}),
      Schedule.deleteMany({}),
      BusLocation.deleteMany({}),
    ]);
    console.log("Data cleared successfully.");

    console.log("Seeding random data...");

    // Generate random routes
    const routes = [];
    for (let i = 0; i < 5; i++) {
      const route = await Route.create({
        routeId: `R${faker.number.int({ min: 100, max: 999 })}`,
        routeName: faker.address.street(),
        startStop: faker.address.city(),
        endStop: faker.address.city(),
      });
      routes.push(route);
    }

    // Generate random stops
    const stops = [];
    for (let i = 0; i < 15; i++) {
      const route = faker.helpers.arrayElement(routes);
      const stop = await Stop.create({
        stopId: `S${faker.number.int({ min: 100, max: 999 })}`,
        stopName: faker.address.street(),
        sequenceNumber: faker.number.int({ min: 1, max: 10 }),
        latitude: faker.location.latitude(),
        longitude: faker.location.longitude(),
        routeId: route._id,
      });
      stops.push(stop);
    }

    // Generate random buses
    const buses = [];
    for (let i = 0; i < 10; i++) {
      const route = faker.helpers.arrayElement(routes);
      const bus = await Bus.create({
        busId: `B${faker.number.int({ min: 100, max: 999 })}`,
        driverId: `D${faker.number.int({ min: 100, max: 999 })}`,
        status: faker.helpers.arrayElement(["active", "inactive"]),
        routeId: route._id,
      });
      buses.push(bus);
    }

    // Generate random schedules
    const schedules = [];
    for (let i = 0; i < 10; i++) {
      const route = faker.helpers.arrayElement(routes);
      const bus = faker.helpers.arrayElement(buses);
      const startTime = faker.date.recent();
      const endTime = faker.date.soon(1, startTime);

      const schedule = await Schedule.create({
        scheduleId: `SCH${faker.number.int({ min: 100, max: 999 })}`,
        startTime,
        endTime,
        routeId: route._id,
        busId: bus._id,
      });
      schedules.push(schedule);
    }

    // Generate random bus locations
    for (let i = 0; i < 20; i++) {
      const schedule = faker.helpers.arrayElement(schedules);
      const stop = faker.helpers.arrayElement(stops);
      await BusLocation.create({
        locationId: `LOC${faker.number.int({ min: 100, max: 999 })}`,
        busId: schedule.busId,
        latitude: faker.location.latitude(),
        longitude: faker.location.longitude(),
        timestamp: faker.date.recent(),
        nearestStopId: stop._id,
        scheduleId: schedule._id,
        startTime: schedule.startTime,
        delayTime: faker.number.int({ min: 0, max: 60 }),
      });
    }

    console.log("Random data added successfully.");
  } catch (error) {
    console.error("Error adding random data:", error.message);
  } finally {
    mongoose.connection.close();
  }
};

generateRandomData()