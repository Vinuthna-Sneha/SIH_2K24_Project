import time
from flask import Flask, request, jsonify
import numpy as np
import requests
import tensorflow as tf
from tensorflow.keras.models import load_model # type: ignore
from keras import metrics
from flask import Flask, request, jsonify
from kafka import KafkaProducer
import json
import random
from datetime import datetime
from tensorflow.keras.models import load_model # type: ignore
from tensorflow.keras.losses import MeanAbsoluteError # type: ignore
from utils.dynamicroute import AntColonyOptimization
from kafkautils.locations import fetch_and_send_data
from kafkautils.delays import time_to_float
from utils.suggestion import IncidentSuggestionGenerator
# from utils.dynamicroute import AntColonyOptimization  
from google.transit import gtfs_realtime_pb2 # type: ignore


try:
    loaded_model = load_model(
    "models/delay.h5",
    custom_objects={'mae': MeanAbsoluteError}  
    
)
    
    # model = load_model("models/route_optimization_results.h5")
    # print("Model loaded successfully.")
except Exception as e:
    print(f"Error: {str(e)}")
API_KEY = "cKslRjfjpiyMAcAdcBAJNCdTpeMaRzkC"
URL = f"https://otd.delhi.gov.in/api/realtime/VehiclePositions.pb?key={API_KEY}"
KAFKA_BROKER = 'localhost:9092'
DELAY_TOPIC = 'bus-delays'
LOCATION_TOPIC = 'vehicle_locations'
producer = KafkaProducer(
    bootstrap_servers=KAFKA_BROKER,
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)
def get_time_of_day():
            current_hour = datetime.now().hour
            if 8 <= current_hour < 10 or 17 <= current_hour < 19:
                return "peak"
            else:
                return "non-peak"

def calculate_speed(prev_lat, prev_long, curr_lat, curr_long, time_diff):
    # Simplified Haversine formula for speed calculation (km/h)
    from math import radians, sin, cos, sqrt, atan2

    R = 6371  # Earth radius in km
    lat1, lon1, lat2, lon2 = map(radians, [prev_lat, prev_long, curr_lat, curr_long])
    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = sin(dlat / 2)**2 + cos(lat1) * cos(lat2) * sin(dlon / 2)**2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    distance = R * c  # Distance in km

    return (distance / (time_diff / 3600)) if time_diff > 0 else 0  # Speed in km/h
# Function to generate delay times
def generate_delay_time(bus_id, driver_id, time, traffic_density, bus_speed, weather_type):
    input_data =np.array([
        float(time_to_float(time)),
        float(traffic_density),
        float(bus_speed),
        float(weather_type),
    ]).reshape(1,1,4)
    print( " ----------------- " , input_data)
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







app = Flask(__name__)

@app.route('/get-report-info', methods=['POST'])
def get_report_info():
    if request.method == "POST":
        data = request.json

        # Extract the input data
        # current_lat = data.get('current_latitude')
        # current_lon = data.get('current_longitude')
        # scheduled_lat = data.get('scheduled_latitude')
        # scheduled_lon = data.get('scheduled_longitude')
        reported_by = data.get('reported_by')
        report_type = data.get('report_type')
        report_lat = data.get('report_location_latitude')
        report_lon = data.get('report_location_longitude')

        # Validate the input
        if not all([ reported_by, report_type, report_lat, report_lon]):
            return jsonify({"error": "Missing required fields"}), 400

        # Preprocess data for the model
        try:
            
            mod = IncidentSuggestionGenerator()
            text = mod.get_suggestions( [reported_by , report_type , datetime.now().isoformat() , report_lat , report_lon ])
        except Exception as e:
            return jsonify({"error": f"Model prediction failed: {str(e)}"}), 500

        # Example logic to customize response based on predictions and report type
        
        return jsonify({            
                "suggestions": text 
            })




@app.route('/optimalroute', methods=['POST'])
def get_optimal_route():
    data = request.get_json()
    buses = data.get("buses", [])
    routes = data.get("routes", [])
    alternatestops = data.get("alternateroute", {})

    if not routes or not buses or not alternatestops:
        return jsonify({"message": "No Routes provided"}), 400
    


    stops_input = [
        {
            "name": stop["name"],
            "lat": stop["lat"],
            "lon": stop["long"],
            "condition": stop["condition"]
        }
        for stop in routes
    ]

    if len(stops_input) < 2:
        return jsonify({"error": "At least two valid stops are required for optimization."}), 400

    delay_times = []

    for bus in buses:
        bus_id = bus.get("busId")
        time_of_day = get_time_of_day()
        passanger = bus.get("total_passanger", 0)  # Default to 0 if not provided
        driver_id = bus.get("driverId")

        if not all([bus_id, driver_id]):
            delay_times.append({"busId": bus_id, "error": "Incomplete bus data"})
            continue

        # Run Ant Colony Optimization for this bus
        aco = AntColonyOptimization(
            stops_input,
            passanger,
            alternatestops
        )

        # Optimize route for the current bus
        best_tour, best_distance = aco.optimize()

        print(f"Bus {bus_id}: Best Tour: {best_tour}, Best Distance: {best_distance}")

        delay_times.append({
            "busId": bus_id,
            "bestTour": best_tour,
            "bestDistance": best_distance,
        })

    return jsonify({"delayTimes": delay_times})




# every 2 min  
@app.route('/api/get-bus-delays', methods=['POST'])
def get_bus_delays():
    # Get parameters from the request
    data = request.get_json()
    buses = data.get("buses", [])


    if not buses :
        return jsonify({"message": "No buses provided"}), 400

    # Ensure at least two valid stops exist




    delay_times = []

    for bus in buses:
        bus_id = bus.get("busId")
        driver_id = bus.get("driverId")
        time = bus.get("time")
        traffic_density = bus.get("traffic density")
        bus_speed = bus.get("bus speed")
        weather_type = bus.get("wheather type")

        if not all([bus_id, driver_id, time, traffic_density, bus_speed, weather_type is not None]):
            delay_times.append({"busId": bus_id, "error": "Incomplete bus data"})
            continue

        # Generate delay time
        delay_time_message = generate_delay_time(bus_id, driver_id, time, traffic_density, bus_speed, weather_type)
        message = {
            "busId": bus_id,
            "driverId": driver_id,
            "time": time,
            "trafficDensity": traffic_density,
            "busSpeed": bus_speed,
            "weatherType": weather_type,
            "delayTime": delay_time_message,
            "timestamp": datetime.utcnow().isoformat()
        }

        producer.send(DELAY_TOPIC, message)

    return jsonify({"message": "Bus delay data sent to Kafka"}), 200




@app.route('/api/send-vehicle-locations', methods=['POST'])
def send_vehicle_locations():
    buses = request.json.get("buses", [])
    if not buses:
        return jsonify({"message": "No buses provided"}), 400

    response = requests.get(URL)
    if response.status_code != 200:
        return jsonify({"message": f"Error fetching data: {response.status_code}"}), 500

    feed = gtfs_realtime_pb2.FeedMessage()
    feed.ParseFromString(response.content)

    vehicle_data = []
    for entity in feed.entity:
        if entity.HasField("vehicle"):
            vehicle = entity.vehicle

            for bus in buses:
                if vehicle.vehicle.id == bus.get("busId"):
                    vehicle_data.append({
                        "busId": bus.get("busId"),
                        "latitude": vehicle.position.latitude,
                        "longitude": vehicle.position.longitude,
                        "timestamp": int(time.time()),  # Use current timestamp
                    })
                    break

    if not vehicle_data:
        return jsonify({"message": "No matching vehicle locations found"}), 200

    return jsonify(vehicle_data), 200






if __name__ == '__main__':
    app.run(debug=True, host="0.0.0.0", port=5001)







