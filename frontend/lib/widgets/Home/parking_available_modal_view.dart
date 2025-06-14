// lib/widgets/parking_available_modal_view.dart

import 'package:flutter/material.dart';
import '../../models/Main Screen/Availability.dart';
import '../../models/Main Screen/parkingAvailable.dart';
import '../../services/image_service.dart';


/// Vista interna del modal para parkings disponible, alineada al estilo del modal de autos.
class ParkingAvailableModalView extends StatelessWidget {
  final ParkingAvailable parking;
  final List<Availability> availability;

  const ParkingAvailableModalView({
    Key? key,
    required this.parking,
    required this.availability,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
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
                        Text(parking.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(parking.address,
                                  style: theme.textTheme.bodySmall),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          parking.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.attach_money, size: 20),
                            const SizedBox(width: 4),
                            Text('Bs ${parking.hourlyRate}/h',
                                style: theme.textTheme.titleMedium!
                                    .copyWith(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- Disponibilidad ----------
            Text('Disponibilidad', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: availability.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(12),
                child: Text('No hay rangos disponibles.'),
              )
                  : ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: availability.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final a = availability[index];
                  return ListTile(
                    leading: const Icon(Icons.event_available),
                    title: Text(_formatRange(a)),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // ---------- Botones ----------
            ElevatedButton.icon(
              icon: const Icon(Icons.book_online),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // TODO: Integrar flujo de reserva
                Navigator.of(context).pop();
              },
              label: const Text('Reservar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }

  // --------- Helpers ---------
  String _formatRange(Availability a) {
    final s = a.start.toLocal();
    final e = a.end.toLocal();
    return '${s.day}/${s.month}/${s.year} – ${e.day}/${e.month}/${e.year}';
  }
}
