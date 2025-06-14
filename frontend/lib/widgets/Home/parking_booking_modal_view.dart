// lib/widgets/parking_booking_modal_view.dart
//
// Vista sin estado que muestra los detalles de la reserva de un estacionamiento.
// Inspirada 1:1 en `car_booking_modal_view.dart`, con cambios mínimos en textos
// y campos específicos de ParkingAvailable.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import '../../models/Main Screen/parkingAvailable.dart';

class ParkingBookingModalView extends StatelessWidget {
  final ParkingAvailable parking;
  final DateTime? startDate;
  final DateTime? endDate;
  final String total;
  final String? error;
  final bool loading;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ParkingBookingModalView({
    Key? key,
    required this.parking,
    required this.startDate,
    required this.endDate,
    required this.total,
    required this.error,
    required this.loading,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  String _fmt(DateTime? dt) => dt == null ? '' : '${dt.month}/${dt.day}/${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---------- Título ----------
          Text(
            'Reserva de Estacionamiento: ${parking.name}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // ---------- Inicio ----------
          Row(children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Expanded(child: Text('Fecha Inicio: ${_fmt(startDate)}')),
            OutlinedButton(
              onPressed: onPickStart,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('Seleccionar'),
            ),
          ]),
          const SizedBox(height: 8),

          // ---------- Fin ----------
          Row(children: [
            const Icon(Icons.calendar_today),
            const SizedBox(width: 8),
            Expanded(child: Text('Fecha Fin: ${_fmt(endDate)}')),
            OutlinedButton(
              onPressed: onPickEnd,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('Seleccionar'),
            ),
          ]),
          const SizedBox(height: 12),

          // ---------- Tarifa diaria ----------
          Row(children: [
            const Icon(Icons.attach_money),
            const SizedBox(width: 8),
            Text('Tarifa diaria: Bs ${parking.hourlyRate}'),
          ]),
          const SizedBox(height: 8),

          // ---------- Total ----------
          Row(children: [
            const Icon(Icons.payment),
            const SizedBox(width: 8),
            Text('Total: Bs $total'),
          ]),
          const SizedBox(height: 12),

          // ---------- Error ----------
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),

          // ---------- Botones ----------
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: const Text('Volver'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: loading ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              child: loading
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Confirmar'),
            ),
          ]),
        ],
      ),
    );
  }
}
