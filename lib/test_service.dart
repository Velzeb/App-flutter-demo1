import '../services/car_service.dart';

void testCarService() {
  print('CarService test');
  final cars = CarService.getAvailableCars();
  print('Found ${cars.length} cars');
}
