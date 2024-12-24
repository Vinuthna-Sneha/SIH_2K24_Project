const kafka = require('kafka-node');

// Kafka Client Configuration
const client = new kafka.KafkaClient({ kafkaHost: 'localhost:9092' });

// Kafka Consumers
const locationConsumer = new kafka.Consumer(
    client,
    [{ topic: 'vehicle_locations', partition: 0 }],
    { autoCommit: true }
);

const delayConsumer = new kafka.Consumer(
    client,
    [{ topic: 'bus-delays', partition: 0 }],
    { autoCommit: true }
);

// Export both consumers
module.exports = {
    locationConsumer,
    delayConsumer
};
