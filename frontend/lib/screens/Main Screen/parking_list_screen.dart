// lib/screens/parking_list_screen.dart

import 'package:flutter/material.dart';

import '../../models/Main Screen/parkingAvailable.dart';
import '../../services/Main Screen/parking_available_service.dart';
import '../../widgets/Home/parking_available_modal.dart';
import '../../widgets/Tarjeta.dart';
import '../../services/image_service.dart';

/// Pantalla que muestra la lista de parkings disponibles.
class ParkingListScreen extends StatefulWidget {
  const ParkingListScreen({Key? key}) : super(key: key);

  @override
  State<ParkingListScreen> createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  final _service = ParkingAvailableService();
  late Future<List<ParkingAvailable>> _futureParkings;

  @override
  void initState() {
    super.initState();
    _futureParkings = _service.fetchAvailableParkings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ParkingAvailable>>(
        future: _futureParkings,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final parkings = snapshot.data ?? [];
          if (parkings.isEmpty) {
            return const Center(
              child: Text('No hay parkings disponibles'),
            );
          }
          return ListView.builder(
            itemCount: parkings.length,
            itemBuilder: (context, index) {
              final parking = parkings[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TarjetaItem(usuario: 'owner',
                    imageUrl: ImageService.getFullImageUrl(parking.image.toString()),
                    disponible: parking.isActive,
                    titulo: parking.name,
                    descripcion: parking.address,
                    onVerMas: (){ParkingAvailableModal.show(context, parking);})
              );
            },
          );
        },
      ),
    );
  }
}
