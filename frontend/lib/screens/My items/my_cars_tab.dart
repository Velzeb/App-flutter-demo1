// lib/screens/my_cars_tab.dart
// --------------------------------------------------
// Lista "Mis Autos" con botones Detalle, Editar y Eliminar
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:login_app/services/image_service.dart';

import '../../models/Main Screen/carAvailable.dart';
import '../../services/my items/my_cars_service.dart';
import '../../widgets/MyItems/car_delete_confirm_dialog.dart';
import '../../widgets/MyItems/car_edit_modal.dart';
import '../../widgets/MyItems/rent_car_modal.dart';
import '../../widgets/Tarjeta.dart';

class MyCarsTab extends StatefulWidget {
  const MyCarsTab({super.key});

  @override
  State<MyCarsTab> createState() => _MyCarsTabState();
}

class _MyCarsTabState extends State<MyCarsTab> {
  late Future<List<CarAvailable>> _future;
  final _service = MyCarsService();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.listMyCars();
    });
  }

  // ----------------------- Callbacks -----------------------

  void _showDetails(CarAvailable car) async {
    final availability = await RentCarModal.show(context, car);
    if (availability != null) {
      _reload();
    }
  }

  Future<void> _editCar(CarAvailable car) async {
    final updated = await CarEditModal.show(context, car);
    if (updated != null) setState(() => _future = _service.listMyCars());
  }

  Future<void> _deleteCar(CarAvailable car) async {
    final confirmed = await CarDeleteConfirmDialog.show(context, car);
    if (confirmed == true) {
      await _service.deleteCar(car.id);
      _reload();
    }
  }

  // ----------------------- UI -----------------------

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
            final fullImageUrl =
            ImageService.getFullImageUrl(car.imageFront.toString());

            return TarjetaItem(
              usuario: car.owner,
              imageUrl: fullImageUrl,
              disponible: car.isActive,
              titulo: '${car.make} ${car.model} (${car.year})',
              descripcion: car.description,
              textoVerMas: 'Rentar',
              onVerMas: () => _showDetails(car),
              onEditar: () => _editCar(car),
              onEliminar: () => _deleteCar(car),
            );
          },
        );
      },
    );
  }
}
