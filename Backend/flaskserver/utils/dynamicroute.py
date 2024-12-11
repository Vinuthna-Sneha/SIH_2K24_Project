import numpy as np
import math

class AntColonyOptimization:
    def __init__(self, stops, num_ants=100, num_iterations=300, alpha=1.5, beta=4.0, evaporation_rate=0.4, q=100, initial_pheromone=2.0):
        self.stops = stops
        self.num_ants = num_ants
        self.num_iterations = num_iterations
        self.alpha = alpha
        self.beta = beta
        self.evaporation_rate = evaporation_rate
        self.q = q
        self.initial_pheromone = initial_pheromone
        self.num_cities = len(stops)

        # Distance matrix
        self.distance_matrix = np.zeros((self.num_cities, self.num_cities))
        self._compute_distance_matrix()

        # Pheromone matrix
        self.pheromone_matrix = np.full((self.num_cities, self.num_cities), self.initial_pheromone)

    def _compute_distance_matrix(self):
        for i in range(self.num_cities):
            for j in range(i + 1, self.num_cities):
                distance = self.haversine(self.stops[i]['lat'], self.stops[i]['lon'], self.stops[j]['lat'], self.stops[j]['lon'])
                self.distance_matrix[i][j] = distance
                self.distance_matrix[j][i] = distance  # Symmetric distance

    @staticmethod
    def haversine(lat1, lon1, lat2, lon2):
        R = 6371  # Earth's radius in km
        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lon2 - lon1)

        a = math.sin(delta_phi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return R * c

    def _calculate_probabilities(self, current_city, unvisited):
        pheromones = self.pheromone_matrix[current_city, unvisited] ** self.alpha
        distances = (1 / self.distance_matrix[current_city, unvisited]) ** self.beta
        probabilities = pheromones * distances
        return probabilities / probabilities.sum()

    def _calculate_tour_length(self, tour):
        return sum(self.distance_matrix[tour[i - 1], tour[i]] for i in range(1, len(tour)))

    def _filter_stops(self, unvisited):
        return [i for i in unvisited if not self.stops[i]['condition']]

    def optimize(self):
        best_tour = None
        best_distance = float('inf')

        for iteration in range(self.num_iterations):
            all_tours = []
            all_distances = []

            # Ant simulation
            for ant in range(self.num_ants):
                tour = [0]  # Start from the first city
                unvisited = list(range(1, self.num_cities))

                while unvisited:
                    # Filter unvisited stops to exclude those with condition=True
                    unvisited = self._filter_stops(unvisited)
                    if not unvisited:
                        break  # Exit if no valid stops remain

                    current_city = tour[-1]
                    probabilities = self._calculate_probabilities(current_city, unvisited)
                    next_city = np.random.choice(unvisited, p=probabilities)
                    tour.append(next_city)
                    unvisited.remove(next_city)

                # Calculate tour length
                distance = self._calculate_tour_length(tour)
                all_tours.append(tour)
                all_distances.append(distance)

                if distance < best_distance:
                    best_tour = tour
                    best_distance = distance

            # Pheromone update: evaporation and reinforcement
            self.pheromone_matrix *= (1 - self.evaporation_rate)
            for tour, distance in zip(all_tours, all_distances):
                pheromone_increase = self.q / distance
                for i in range(len(tour) - 1):
                    self.pheromone_matrix[tour[i], tour[i + 1]] += pheromone_increase
                    self.pheromone_matrix[tour[i + 1], tour[i]] += pheromone_increase  # Symmetric routes

        # Get the best tour names
        best_tour_cities = [self.stops[i]['name'] for i in best_tour]
        return best_tour_cities, best_distance


# Example usage
# stops_input = [
#     {"name": "Lajpat Nagar", "lat": 28.817559, "lon": 77.104537, "condition": False},
#     {"name": "Dwarka Sector 10", "lat": 28.875682, "lon": 77.321606, "condition": True},
#     {"name": "Sarojini Nagar", "lat": 28.688008, "lon": 76.871453, "condition": True},
#     {"name": "Vivek Vihar", "lat": 28.77752, "lon": 77.124188, "condition": False},
#     {"name": "Red Fort", "lat": 28.72066, "lon": 77.169159, "condition": False},
#     {"name": "Janakpuri", "lat": 28.682632, "lon": 77.147544, "condition": False},
#     {"name": "Dwarka Sector 21", "lat": 28.629151, "lon": 76.847819, "condition": False},
# ]

# # Initialize the AntColonyOptimization instance
# aco = AntColonyOptimization(
#     stops_input,
#     num_ants=50,
#     num_iterations=100,
#     alpha=1.2,
#     beta=3.0,
#     evaporation_rate=0.5,
#     q=50,
#     initial_pheromone=1.0
# )

# # Run the optimization
# best_tour, best_distance = aco.optimize()

# # Output results
# print("\nBest Tour Found:", best_tour)
# print("Best Distance:", best_distance, "km")