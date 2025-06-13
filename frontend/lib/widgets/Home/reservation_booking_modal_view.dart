// lib/widget/reservation_booking_modal_view.dart

import 'package:flutter/material.dart';
import '../../models/carAvailable.dart';

class ReservationBookingModalView extends StatelessWidget {
  final CarAvailable car;
  final DateTime? startDate;
  final DateTime? endDate;
  final String precio;
  final String? error;
  final bool loading;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ReservationBookingModalView({
    Key? key,
    required this.car,
    required this.startDate,
    required this.endDate,
    required this.precio,
    required this.error,
    required this.loading,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onCancel,
    required this.onConfirm,
  }) : super(key: key);

  String _fmt(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título
          Text(
            'Reserva: ${car.make} ${car.model}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Fecha inicio
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

          // Fecha fin
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

          // Precio por día
          Row(children: [
            const Icon(Icons.attach_money),
            const SizedBox(width: 8),
            Text('Precio por día: Bs ${car.dailyRate}'),
          ]),
          const SizedBox(height: 8),

          // Total
          Row(children: [
            const Icon(Icons.payment),
            const SizedBox(width: 8),
            Text('Total: Bs $precio'),
          ]),
          const SizedBox(height: 12),

          // Error
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),

          // Botones
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
