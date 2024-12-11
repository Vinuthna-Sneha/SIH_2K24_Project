from datetime import time
import requests
from google.transit import gtfs_realtime_pb2 # type: ignore


# API Key and URL
API_KEY = "cKslRjfjpiyMAcAdcBAJNCdTpeMaRzkC"
URL = f"https://otd.delhi.gov.in/api/realtime/VehiclePositions.pb?key={API_KEY}"


def fetch_and_send_data(bus_id, driver_id):
    response = requests.get(URL)
    if response.status_code == 200:
        feed = gtfs_realtime_pb2.FeedMessage()
        feed.ParseFromString(response.content)

        for entity in feed.entity:
            if entity.HasField("vehicle"):
                vehicle = entity.vehicle
                # Match the busId and driverId with the vehicle data
                if vehicle.vehicle.id == bus_id:
                    vehicle_data = {
                        "bus_id": driver_id,
                        "driver_id": driver_id,
                        "latitude": vehicle.position.latitude,
                        "longitude": vehicle.position.longitude,
                        "timestamp": time.time()
                    }
                    # Send data to Kafka
                    print(f"Sent data for vehicle {vehicle.vehicle.id} to Kafka.")
                    return vehicle_data
    else:
        print(f"Error fetching data: {response.status_code}, {response.text}")
        return None
