// lib/widgets/parking_available_modal_view.dart
//
// Refactor que alinea la vista del modal de parkings disponibles
// con la estructura y flujo de callbacks utilizada por
// CarAvailableModalView.
//
//  • Dos modos de construcción:  `.error()` y `.content()`
//  • Callbacks: `onClose`, `onNext` (opcional)
//  • Soporte de estado de error con visual similar
//  • Sin `onViewPhotos`, ya que no aplica a parkings
//

import 'package:flutter/material.dart';
import '../../models/Main Screen/Availability.dart';
import '../../models/Main Screen/parkingAvailable.dart';
import '../../services/image_service.dart';

class ParkingAvailableModalView extends StatelessWidget {
  // ---------- Propiedades compartidas ----------
  final ParkingAvailable? parking;
  final List<Availability>? availability;
  final String? errorMessage;
  final VoidCallback onClose;
  final VoidCallback? onNext;
  final bool isError;

  const ParkingAvailableModalView._({
    Key? key,
    this.parking,
    this.availability,
    this.errorMessage,
    required this.onClose,
    this.onNext,
    this.isError = false,
  }) : super(key: key);

  /// Crea el modal en modo *error*.
  factory ParkingAvailableModalView.error({
    required String errorMessage,
    required VoidCallback onClose,
  }) {
    return ParkingAvailableModalView._(
      isError: true,
      errorMessage: errorMessage,
      onClose: onClose,
    );
  }

  /// Crea el modal en modo *contenido*.
  factory ParkingAvailableModalView.content({
    required ParkingAvailable parking,
    required List<Availability> availability,
    required VoidCallback onClose,
    required VoidCallback onNext,
  }) {
    return ParkingAvailableModalView._(
      parking: parking,
      availability: availability,
      onClose: onClose,
      onNext: onNext,
    );
  }

  // ---------- Build ----------
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.scaffoldBackgroundColor;

    // --- Estilos reutilizables ---
    final squareTextButtonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );
    final squareElevatedButtonStyle = ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    );

    // ---------- Vista de ERROR ----------
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
                  child: Text(
                    'Ocurrió un error',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(errorMessage ?? 'Error desconocido'),
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

    // ---------- Vista de CONTENIDO ----------
    final parking = this.parking!;
    final availability = this.availability!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Encabezado ----------
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      ImageService.getFullImageUrl(parking.image.toString()),
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          parking.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                parking.address,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Rango disponible:',
                            style: theme.textTheme.titleSmall),
                        const SizedBox(height: 4),
                        Text(
                          availability.map(_formatRange).join('\n'),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ---------- Botones de acción ----------
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    style: squareTextButtonStyle,
                    onPressed: onClose,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver'),
                  ),
                ),
                const SizedBox(width: 8),
                if (onNext != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      style: squareElevatedButtonStyle,
                      onPressed: onNext,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Siguiente'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Helpers ----------
  String _formatRange(Availability a) {
    final s = a.start.toLocal();
    final e = a.end.toLocal();
    return '${s.day}/${s.month}/${s.year} – ${e.day}/${e.month}/${e.year}';
  }
}
