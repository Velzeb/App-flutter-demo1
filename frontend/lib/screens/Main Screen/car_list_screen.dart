// lib/Screens/car_list_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/Tarjeta.dart';
import '../../services/car_available_service.dart';
import '../../models/carAvailable.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CarAvailable>>(
      future: CarAvailableService().fetchAvailableCars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final cars = snapshot.data;
        if (cars == null || cars.isEmpty) {
          return const Center(child: Text('No hay autos disponibles'));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: cars.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final car = cars[index];

            // Construye un string con las franjas de disponibilidad
            final availabilityText = car.availability
                .map((a) {
              final start = a.start.toLocal().toString().split(' ')[0];
              final end = a.end.toLocal().toString().split(' ')[0];
              return '$start - $end';
            })
                .join('\n');

            return TarjetaItem(
              usuario: 'Owner ${car.owner}',
              imageUrl: car.imageFront.toString(),
              disponible: car.isActive,
              titulo: '${car.year} ${car.make} ${car.model}',
              descripcion: car.description,
              rangoFechas: availabilityText,
              precio: 'Bs ${car.dailyRate}',
              ubicacion: null,
              espaciosDisponibles: null,
              onVerMas: () {
                // TODO: navegar a detalle pasando 'car'
              },
            );
          },
        );
      },
    );
  }
}
