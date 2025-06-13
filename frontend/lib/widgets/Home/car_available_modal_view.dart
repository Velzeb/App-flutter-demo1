// lib/widget/car_available_modal_view.dart
import 'package:flutter/material.dart';
import '../../models/Availability.dart';
import '../../models/carAvailable.dart';
import '../../services/image_service.dart';
import 'car_photos_modal.dart';

/// Modal que muestra el detalle de un auto disponible para renta.
/// Solo se han aplicado cambios **visuales** (fondo blanco, botones
/// de esquinas cuadradas e iconos contextuales). Toda la lógica,
/// parámetros y flujo interno permanecen intactos.
class CarAvailableModalView extends StatelessWidget {
  final CarAvailable? car;
  final List<Availability>? availability;
  final String? errorMessage;
  final VoidCallback onClose;
  final VoidCallback? onNext;
  final VoidCallback? onViewPhotos;
  final bool isError;

  const CarAvailableModalView._({
    Key? key,
    this.car,
    this.availability,
    this.errorMessage,
    required this.onClose,
    this.onNext,
    this.onViewPhotos,
    this.isError = false,
  }) : super(key: key);

  /// Constructor para estado de error
  factory CarAvailableModalView.error({
    required String errorMessage,
    required VoidCallback onClose,
  }) {
    return CarAvailableModalView._(
      isError: true,
      errorMessage: errorMessage,
      onClose: onClose,
    );
  }

  /// Constructor para estado de contenido
  factory CarAvailableModalView.content({
    required CarAvailable car,
    required List<Availability> availability,
    required VoidCallback onClose,
    required VoidCallback onNext,
    required VoidCallback onViewPhotos,
  }) {
    return CarAvailableModalView._(
      car: car,
      availability: availability,
      onClose: onClose,
      onNext: onNext,
      onViewPhotos: onViewPhotos,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Color de fondo global (blanco) ---
    const backgroundColor = Colors.white;

    // --- Estilos reutilizables ---
    final squareTextButtonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
    final squareElevatedButtonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    if (isError) {
      return Container(
        color: backgroundColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Ocurrió un error',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Error: $errorMessage'),
            const SizedBox(height: 12),
            TextButton.icon(
              style: squareTextButtonStyle,
              onPressed: onClose,
              icon: const Icon(Icons.close),
              label: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }

    // --- Formatear rangos de fechas ---
    final datesText = availability!
        .map((a) {
      final s = a.start.toLocal();
      final e = a.end.toLocal();
      return '${s.day}/${s.month}/${s.year} – ${e.day}/${e.month}/${e.year}';
    })
        .join('\n');

    final imageUrl = ImageService.getFullImageUrl(car!.imageFront.toString());

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Imagen principal ---
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(imageUrl, height: 180, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),

            // --- Título + botón ver más fotos ---
            Row(
              children: [
                const Icon(Icons.directions_car, size: 22, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${car!.make} ${car!.model}'.toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                if (onViewPhotos != null)
                  TextButton.icon(
                    style: squareTextButtonStyle,
                    onPressed: onViewPhotos,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Más fotos'),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // --- Dueño ---
            Row(
              children: [
                const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text('Dueño: ${car!.owner}')),
              ],
            ),
            const SizedBox(height: 4),

            // --- Precio ---
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text('Precio: Bs ${car!.dailyRate}/día')),
              ],
            ),
            const SizedBox(height: 12),

            // --- Descripción ---
            Row(
              children: const [
                Icon(Icons.description_outlined, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Text('Descripción', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Text(car!.description),
            const SizedBox(height: 12),

            // --- Fechas disponibles ---
            Row(
              children: const [
                Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Text('Fechas disponibles:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            Text(datesText.isEmpty ? 'Sin rangos disponibles' : datesText),
            const SizedBox(height: 16),

            // --- Botones de acción ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  style: squareTextButtonStyle,
                  onPressed: onClose,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                ),
                const SizedBox(width: 8),
                if (onNext != null)
                  ElevatedButton.icon(
                    style: squareElevatedButtonStyle,
                    onPressed: onNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Siguiente'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
