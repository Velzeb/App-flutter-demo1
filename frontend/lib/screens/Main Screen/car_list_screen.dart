// lib/Screens/car_list_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/Home/car_available_modal.dart';
import '../../models/Main Screen/carAvailable.dart';
import '../../services/Main Screen/car_available_service.dart';
import '../../services/image_service.dart';
import '../../widgets/TarjetaModerna.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/loading_widget.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CarAvailable>>(
      future: CarAvailableService().fetchAvailableCars(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: const Color(0xFFF8FAFB),
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) => const ShimmerCard(),
            ),
          );
        }
        if (snapshot.hasError) {
          return EmptyStateWidget(
            icon: Icons.error_outline,
            title: 'Error al cargar',
            subtitle:
                'No pudimos cargar los autos disponibles. Verifica tu conexión e intenta nuevamente.',
            actionText: 'Reintentar',
            onAction: () {
              // Trigger rebuild
              (context as Element).markNeedsBuild();
            },
          );
        }
        final cars = snapshot.data;
        if (cars == null || cars.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.directions_car_outlined,
            title: 'No hay autos disponibles',
            subtitle:
                'Actualmente no tenemos vehículos disponibles para renta. ¡Vuelve pronto para ver nuevas opciones!',
          );
        }
        return Container(
          color: const Color(0xFFF8FAFB),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: cars.length,
            itemBuilder: (context, index) {
              final car = cars[index];
              // Construimos la URL completa de la imagen frontal
              final fullImageUrl = ImageService.getFullImageUrl(
                car.imageFront.toString(),
              );

              return TarjetaItem(
                usuario: 'Propietario: ${car.owner}',
                imageUrl: fullImageUrl,
                disponible: car.isActive,
                titulo: '${car.year} ${car.make} ${car.model}',
                descripcion: car.description,
                precio: 'Bs ${car.dailyRate}/día',
                ubicacion:
                    'La Paz, Bolivia', // Podrías obtener esto del backend
                onVerMas: () {
                  CarAvailableModal.show(context, car);
                },
              );
            },
          ),
        );
      },
    );
  }
}
