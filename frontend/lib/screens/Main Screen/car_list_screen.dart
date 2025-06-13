// lib/Screens/car_list_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/Home/car_available_modal.dart';
import '../../widgets/Home/car_available_modal_view.dart';
import '../../models/carAvailable.dart';
import '../../services/car_available_service.dart';
import '../../services/image_service.dart';
import '../../widgets/Tarjeta.dart';

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
            // Construimos la URL completa de la imagen frontal
            final fullImageUrl = ImageService.getFullImageUrl(
              car.imageFront.toString(),
            );

            return TarjetaItem(
              usuario: 'Dueño ${car.owner}',
              imageUrl: fullImageUrl,         // <-- aquí usamos ImageService
              disponible: car.isActive,
              titulo: '${car.year} ${car.make} ${car.model}',
              descripcion: car.description,
              rangoFechas: null,
              precio: 'Bs ${car.dailyRate}',
              ubicacion: null,
              espaciosDisponibles: null,
              onVerMas: () {
                // TODO: mostrar modal de detalle
                CarAvailableModal.show(context, car);
              },
            );
          },
        );
      },
    );
  }
}
