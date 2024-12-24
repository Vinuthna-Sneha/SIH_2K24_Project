import numpy as np
import math
from datetime import datetime
import random

class AntColonyOptimization:
    def __init__(self, stops, total_passengers, alternate_routes):
        self.stops = stops
        self.total_passengers = total_passengers
        self.alternate_routes = alternate_routes or {}

    @staticmethod
    def haversine(lat1, lon1, lat2, lon2):
        R = 6371  # Earth's radius in km
        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)

        a = math.sin(delta_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return R * c

    def compute_distance_matrix(self):
        num_cities = len(self.stops)
        distance_matrix = np.zeros((num_cities, num_cities))
        for i in range(num_cities):
            for j in range(i + 1, num_cities):
                distance = self.haversine(
                    self.stops[i]['lat'], self.stops[i]['lon'],
                    self.stops[j]['lat'], self.stops[j]['lon']
                )
                distance_matrix[i][j] = distance
                distance_matrix[j][i] = distance
        return distance_matrix

    def calculate_route_feasibility(self, optimized_route, affected_stops, time_of_day):
        impact_threshold = 25 if time_of_day == "peak" else 35
        total_affected = 0

        for stop_index, num_passengers in affected_stops.items():
            if stop_index in self.alternate_routes:
                # Access the 'ETA' value directly from the dictionary
                alternate_available = self.alternate_routes[stop_index].get('ETA', float('inf')) <= 15  
                if alternate_available:
                    continue
            if stop_index not in optimized_route:
                total_affected += num_passengers

        percentage_affected = (total_affected / self.total_passengers) * 100
        return percentage_affected <= impact_threshold

    def optimize(self, num_ants=50, num_iterations=100, alpha=1.2, beta=3.0, evaporation_rate=0.5, q=50, initial_pheromone=1.0):
        num_cities = len(self.stops)
        distance_matrix = self.compute_distance_matrix()
        pheromone_matrix = np.full((num_cities, num_cities), initial_pheromone)

        def calculate_probabilities(current_city, unvisited):
            distances = distance_matrix[current_city, unvisited]
            distances[distances == 0] = 1e-10
            pheromones = pheromone_matrix[current_city, unvisited] ** alpha
            distances = (1 / distances) ** beta
            probabilities = pheromones * distances
            total_prob = probabilities.sum()
            return probabilities / total_prob if total_prob > 0 else np.ones_like(probabilities) / len(probabilities)

        best_tour, best_distance = None, float('inf')
        for _ in range(num_iterations):
            all_tours, all_distances = [], []
            for _ in range(num_ants):
                tour, unvisited = [0], list(range(1, num_cities))
                while unvisited:
                    current_city = tour[-1]
                    probabilities = calculate_probabilities(current_city, unvisited)
                    next_city = np.random.choice(unvisited, p=probabilities)
                    tour.append(next_city)
                    unvisited.remove(next_city)

                distance = sum(distance_matrix[tour[i - 1], tour[i]] for i in range(1, len(tour)))
                all_tours.append(tour)
                all_distances.append(distance)

                if distance < best_distance:
                    best_tour, best_distance = tour, distance

            pheromone_matrix *= (1 - evaporation_rate)
            for tour, distance in zip(all_tours, all_distances):
                pheromone_increase = q / distance
                for i in range(len(tour) - 1):
                    pheromone_matrix[tour[i], tour[i + 1]] += pheromone_increase
                    pheromone_matrix[tour[i + 1], tour[i]] += pheromone_increase

        affected_stops = {i: random.randint(5, 20) for i in range(num_cities) if self.stops[i]['condition']}
        time_of_day = "peak" if 8 <= datetime.now().hour < 10 or 17 <= datetime.now().hour < 19 else "non-peak"
        feasible = self.calculate_route_feasibility(best_tour, affected_stops, time_of_day)

        return [self.stops[i]['name'] for i in best_tour], best_distance if feasible else (None, float('inf'))

# Usage example
if __name__ == "__main__":
    stops_input = [
        {"name": "Lajpat Nagar", "lat": 28.817559, "lon": 77.104537, "condition": False},
        {"name": "Dwarka Sector 10", "lat": 28.875682, "lon": 77.321606, "condition": True},
        # Add other stops as required
    ]
    alternate_routes_input = {"1": {"bus":"Bus101","ETA":10}, "2": {"bus":"Bus201","ETA":20}}
    aco = AntColonyOptimization(stops_input, total_passengers=200, alternate_routes=alternate_routes_input)
    best_tour, best_distance = aco.optimize()
    print("Best Tour:", best_tour)
    print("Distance:", best_distance)