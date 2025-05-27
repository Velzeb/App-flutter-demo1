import '../models/car.dart';
import '../models/rental.dart';

class CarService {
  // Almacenamiento en memoria para demostración
  static final List<Car> _cars = [];
  static final List<Rental> _rentals = [];

  // Inicializar con datos de demostración
  static void _initializeData() {
    if (_cars.isNotEmpty) return;

    // Agregar algunos autos de demostración
    _cars.addAll([
      Car(
        id: '1',
        ownerId: 'demo@example.com',
        ownerName: 'Usuario Demo',
        brand: 'Toyota',
        model: 'Corolla',
        year: 2020,
        color: 'Blanco',
        pricePerDay: 150.0,
        location: 'Zona Sur, La Paz',
        description: 'Auto económico y confiable, perfecto para la ciudad.',
        imageUrl: 'https://via.placeholder.com/400x250?text=Toyota+Corolla',
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Car(
        id: '2',
        ownerId: 'admin@example.com',
        ownerName: 'Admin Usuario',
        brand: 'Honda',
        model: 'Civic',
        year: 2021,
        color: 'Azul',
        pricePerDay: 180.0,
        location: 'Zona Norte, La Paz',
        description: 'Auto moderno con excelente rendimiento de combustible.',
        imageUrl: 'https://via.placeholder.com/400x250?text=Honda+Civic',
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Car(
        id: '3',
        ownerId: 'demo@example.com',
        ownerName: 'Usuario Demo',
        brand: 'Nissan',
        model: 'Sentra',
        year: 2019,
        color: 'Gris',
        pricePerDay: 140.0,
        location: 'Centro, La Paz',
        description: 'Cómodo y espacioso, ideal para viajes largos.',
        imageUrl: 'https://via.placeholder.com/400x250?text=Nissan+Sentra',
        isAvailable: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
    ]);
  }

  // Obtener estadísticas de la plataforma
  static Future<Map<String, int>> getStats() async {
    _initializeData();

    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simular delay de red

    return {
      'totalCars': _cars.length,
      'availableCars': _cars.where((car) => car.isAvailable).length,
      'totalRentals': _rentals.length,
    };
  }

  // Obtener todos los autos
  static Future<List<Car>> getAllCars() async {
    _initializeData();

    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simular delay de red

    return List.from(_cars);
  }

  // Obtener autos disponibles
  static List<Car> getAvailableCars() {
    _initializeData();
    return _cars.where((car) => car.isAvailable).toList();
  }

  // Obtener auto por ID
  static Future<Car?> getCarById(String carId) async {
    _initializeData();

    await Future.delayed(
      const Duration(milliseconds: 200),
    ); // Simular delay de red

    try {
      return _cars.firstWhere((car) => car.id == carId);
    } catch (e) {
      return null;
    }
  }

  // Agregar un nuevo auto
  static Future<void> addCar(Car car) async {
    await Future.delayed(
      const Duration(milliseconds: 800),
    ); // Simular delay de red

    _cars.add(car);
  }

  // Rentar un auto
  static Future<void> rentCar(Rental rental) async {
    await Future.delayed(
      const Duration(milliseconds: 1000),
    ); // Simular delay de red

    // Agregar la renta a la lista
    _rentals.add(rental);

    // Opcional: Marcar el auto como no disponible durante las fechas de renta
    // En una implementación real, esto sería más complejo con verificación de fechas
    final carIndex = _cars.indexWhere((car) => car.id == rental.carId);
    if (carIndex != -1) {
      // Por simplicidad, no cambiamos la disponibilidad aquí
      // En una app real, manejarías las fechas de disponibilidad
    }
  }

  // Obtener rentas de un usuario específico (rentas que ha realizado)
  static Future<List<Rental>> getUserRentals(String userEmail) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simular delay de red

    return _rentals.where((rental) => rental.renterId == userEmail).toList();
  }

  // Obtener rentas de los autos de un usuario (autos que le han rentado)
  static Future<List<Rental>> getRentalsToUser(String userEmail) async {
    await Future.delayed(
      const Duration(milliseconds: 500),
    ); // Simular delay de red

    return _rentals.where((rental) => rental.ownerId == userEmail).toList();
  }

  // Método auxiliar para limpiar datos (útil para testing)
  static void clearData() {
    _cars.clear();
    _rentals.clear();
  }

  // Método auxiliar para obtener autos de un propietario específico
  static Future<List<Car>> getCarsByOwner(String ownerEmail) async {
    _initializeData();

    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simular delay de red

    return _cars.where((car) => car.ownerId == ownerEmail).toList();
  }

  // Actualizar disponibilidad de un auto
  static Future<void> updateCarAvailability(
    String carId,
    bool isAvailable,
  ) async {
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simular delay de red

    final carIndex = _cars.indexWhere((car) => car.id == carId);
    if (carIndex != -1) {
      _cars[carIndex] = _cars[carIndex].copyWith(isAvailable: isAvailable);
    }
  }

  // Buscar autos por criterios
  static Future<List<Car>> searchCars({
    String? query,
    double? maxPrice,
    int? minYear,
    String? location,
  }) async {
    _initializeData();

    await Future.delayed(
      const Duration(milliseconds: 400),
    ); // Simular delay de red

    var filteredCars = List<Car>.from(_cars);

    if (query != null && query.isNotEmpty) {
      filteredCars = filteredCars.where((car) {
        return car.brand.toLowerCase().contains(query.toLowerCase()) ||
            car.model.toLowerCase().contains(query.toLowerCase()) ||
            car.location.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }

    if (maxPrice != null) {
      filteredCars = filteredCars
          .where((car) => car.pricePerDay <= maxPrice)
          .toList();
    }

    if (minYear != null) {
      filteredCars = filteredCars.where((car) => car.year >= minYear).toList();
    }

    if (location != null && location.isNotEmpty) {
      filteredCars = filteredCars.where((car) {
        return car.location.toLowerCase().contains(location.toLowerCase());
      }).toList();
    }

    return filteredCars;
  }
}
