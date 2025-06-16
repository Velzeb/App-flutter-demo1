// lib/screens/my_parkings_tab.dart
// --------------------------------------------------
// Tab \"Mis Parqueos\" con TarjetaItem mostrando botones
// Publicar (renta), Editar y Eliminar.
// --------------------------------------------------

import 'package:flutter/material.dart';
import 'package:login_app/services/image_service.dart';
import '../../models/Main Screen/parkingAvailable.dart';
import '../../services/my items/my_parking_service.dart';
import '../../widgets/MyItems/parking_delete_confirm_dialog.dart';
import '../../widgets/Tarjeta.dart';


class MyParkingsTab extends StatefulWidget {
  const MyParkingsTab({Key? key}) : super(key: key);

  @override
  _MyParkingsTabState createState() => _MyParkingsTabState();
}

class _MyParkingsTabState extends State<MyParkingsTab> {
  late Future<List<ParkingAvailable>> _future;
  final _service = MyParkingsService();

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _service.listMyParkings();
    });
  }

  Future<void> _rentParking(ParkingAvailable p) async {
    /*final avail = await RentParkingModal.show(context, p);
    if (avail != null) {
      _reload();
    }*/
  }

  Future<void> _editParking(ParkingAvailable p) async {
    /*final updated = await ParkingEditModal.show(context, p);
    if (updated != null) {
      _reload();
    }*/
  }

  Future<void> _deleteParking(ParkingAvailable p) async {
   final confirmed = await ParkingDeleteConfirmDialog.show(context, p);
    if (confirmed == true) {
      await _service.deleteParking(p.id);
      _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ParkingAvailable>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final parkings = snapshot.data ?? [];
        if (parkings.isEmpty) {
          return const Center(child: Text('No se encontraron parqueos.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: parkings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final p = parkings[i];
            final fullImageUrl =
            ImageService.getFullImageUrl(p.image.toString());
            return TarjetaItem(
              usuario: p.owner.toString(),
              imageUrl: fullImageUrl,
              disponible: p.isActive,
              titulo: p.name,
              descripcion: p.description,
              precio: 'Bs ${p.hourlyRate}/h',
              ubicacion: p.address,
              textoVerMas: 'Publicar',
              onVerMas: () => _rentParking(p),
              onEditar: () => _editParking(p),
              onEliminar: () => _deleteParking(p),
            );
          },
        );
      },
    );
  }
}
