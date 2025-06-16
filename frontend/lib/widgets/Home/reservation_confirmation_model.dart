import 'package:flutter/material.dart';

/// Modal de confirmación de reserva:
class ReservationConfirmationModal extends StatelessWidget {
  final String owner;
  final DateTime startDate;
  final DateTime endDate;
  final String total;

  const ReservationConfirmationModal({
    Key? key,
    required this.owner,
    required this.startDate,
    required this.endDate,
    required this.total,
  }) : super(key: key);

  static Future<bool?> show(BuildContext context, {
    required String owner,
    required DateTime startDate,
    required DateTime endDate,
    required String total,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ReservationConfirmationModal(
          owner: owner,
          startDate: startDate,
          endDate: endDate,
          total: total,
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2,'0')}';

  @override
  Widget build(BuildContext context) {
    final start = _fmt(startDate);
    final end = _fmt(endDate);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Confirmación de Reserva',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            'Yo, confirmo la reserva del vehículo perteneciente a $owner, '
                'por el periodo comprendido entre $start y $end, '
                'por un monto total de $total Bs. Al confirmar esta reserva me comprometo '
                'a devolver el vehículo en las mismas condiciones en que fue entregado. '
                'Asimismo, reconozco que el vehículo cuenta con un seguro vigente, '
                'y acepto que en caso de accidente, daño o pérdida, se aplicarán las '
                'coberturas, deducibles y limitaciones establecidas en dicha póliza. '
                'Estoy de acuerdo en asumir cualquier responsabilidad no cubierta por el seguro.',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Confirmar'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}