import 'package:flutter/material.dart';
import '../../models/Availability.dart';
import '../../models/carAvailable.dart';
import '../../services/car_available_service.dart';


/// Modal que carga y muestra detalle de un auto disponible,
/// incluyendo su disponibilidad obtenida al abrir.
class CarAvailableModal extends StatefulWidget {
  final CarAvailable car;
  const CarAvailableModal({Key? key, required this.car}) : super(key: key);

  static Future<void> show(BuildContext context, CarAvailable car) async {
    await showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: CarAvailableModal(car: car),
      ),
    );
  }

  @override
  State<CarAvailableModal> createState() => _CarAvailableModalState();
}

class _CarAvailableModalState extends State<CarAvailableModal> {
  late Future<List<Availability>> _availabilityFuture;

  @override
  void initState() {
    super.initState();
    // Carga disponibilidad al iniciar el modal
    _availabilityFuture = CarAvailableService().fetchCarAvailability(widget.car.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Availability>>(
      future: _availabilityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error cargando disponibilidad: ${snapshot.error}'),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          );
        }

        final availability = snapshot.data!;
        final dates = availability.map((a) {
          final s = a.start.toLocal();
          final e = a.end.toLocal();
          return '${s.day}/${s.month}/${s.year} - ${e.day}/${e.month}/${e.year}';
        }).join('\n');

        // UI de detalle con fechas
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título
              Text(
                '${widget.car.make} ${widget.car.model}'.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Información básica
              Text('Dueño: ${widget.car.owner}'),
              const SizedBox(height: 4),
              Text('Precio: Bs ${widget.car.dailyRate}/día'),
              const SizedBox(height: 12),
              const Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(widget.car.description),
              const SizedBox(height: 12),

              // Fechas disponibles
              const Text('Disponibilidad de Fechas:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(dates.isEmpty ? 'Sin rangos disponibles' : dates),
              const SizedBox(height: 16),

              // Botones de navegación (otro modal, next button separado)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Llamar al PhotoGalleryModal.show(...) o siguiente acción
                    },
                    child: const Text('Siguiente'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
