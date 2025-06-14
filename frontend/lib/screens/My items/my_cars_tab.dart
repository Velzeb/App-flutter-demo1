// lib/screens/my_cars_tab.dart
// --------------------------------------------------
// Tab "Mis Autos" mostrando cada [CarAvailable] del usuario con TarjetaItem.
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:login_app/services/image_service.dart';

import '../../models/Main Screen/carAvailable.dart';
import '../../services/my items/my_cars_service.dart';
import '../../widgets/Tarjeta.dart';

class MyCarsTab extends StatefulWidget {
  const MyCarsTab({super.key});

  @override
  State<MyCarsTab> createState() => _MyCarsTabState();
}

class _MyCarsTabState extends State<MyCarsTab> {
  late Future<List<CarAvailable>> _future;

  @override
  void initState() {
    super.initState();
    _future = MyCarsService().listMyCars();
  }

  void _showDetails(CarAvailable car) {
    // Navegar a detalle o mostrar diálogo.
    debugPrint('[MyCarsTab] Ver más → id=${car.id}');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CarAvailable>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final cars = snapshot.data ?? [];
        if (cars.isEmpty) {
          return const Center(child: Text('No se encontraron autos registrados.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: cars.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final car = cars[index];
            final fullImageUrl = ImageService.getFullImageUrl(car.imageFront.toString());
            return TarjetaItem(
              usuario: car.owner,
              imageUrl: fullImageUrl,
              disponible: car.isActive,
              titulo: '${car.make} ${car.model} (${car.year})',
              descripcion: car.description,
              onVerMas: () => _showDetails(car),
            );
          },
        );
      },
    );
  }
}
