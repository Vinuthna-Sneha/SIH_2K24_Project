import numpy as np
from tensorflow.keras.models import load_model # type: ignore
from kafka import KafkaProducer
import json
from datetime import datetime
from tensorflow.keras.models import load_model # type: ignore
from tensorflow.keras.losses import MeanAbsoluteError   # type: ignore
try:
    loaded_model = load_model(
    "models/delay_suggestion_model.h5",
    custom_objects={'mae': MeanAbsoluteError}  
)
    # model = load_model("models/route_optimization_results.h5")
    # print("Model loaded successfully.")
except Exception as e:
    print(f"Error: {str(e)}")


producer = KafkaProducer(
    bootstrap_servers='localhost:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)
def time_to_float(time_str):
    try:
      time_obj = datetime.strptime(time_str, '%H:%M:%S')
      return time_obj.hour + time_obj.minute / 60.0 + time_obj.second / 3600.0
    except ValueError:
      print(f"Invalid time format: {time_str}")
      return None
# Function to generate delay times
def generate_delay_time(bus_id, driver_id, time, traffic_density, bus_speed, weather_type):
    input_data = np.array([[
        float(time_to_float(time)),
        float(traffic_density),
        float(bus_speed),
        float(weather_type),
        0  # Add a dummy value if the model expects 5 features
    ]], dtype=np.float32)

    # Reshape input data to match the expected shape (batch_size, 1, 5)
    input_data = input_data.reshape(1, 1, -1)
    prediction = loaded_model.predict(input_data)
    delay_time = float(prediction[0][0])
    print(prediction[0][0])
    message = {
        "busId": bus_id,
        "driverId": driver_id,
        "time": time,
        "trafficDensity": traffic_density,
        "busSpeed": bus_speed,
        "weatherType": weather_type,
        "delayTime": delay_time,
        "timestamp": datetime.now().isoformat()
    }

    # Send message to Kafka
    producer.send('bus-delays', message)
    return {
        "busId": bus_id,
        "driverId": driver_id,
        "delayTime": delay_time ,
        "timestamp": datetime.now().isoformat()
        
    }