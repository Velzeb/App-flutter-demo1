// lib/widget/car_booking_modal_view.dart

import 'package:flutter/material.dart';
import '../../models/Main Screen/carAvailable.dart';

class ReservationBookingModalView extends StatefulWidget {
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

  @override
  _ReservationBookingModalViewState createState() =>
      _ReservationBookingModalViewState();
}

class _ReservationBookingModalViewState
    extends State<ReservationBookingModalView> {
  // 0 = Esencial, 1 = Ejecutiva
  int _selectedInsurance = 0;

  static const double _essentialFeePerDay = 50.0;
  static const double _executiveFeePerDay = 100.0;

  String _fmt(DateTime? dt) {
    if (dt == null) return '';
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    final accent = const Color(0xFF1565C0);

    // Días de reserva (incluir ambos extremos)
    final days = (widget.startDate != null && widget.endDate != null)
        ? widget.endDate!.difference(widget.startDate!).inDays + 1
        : 1;

    // Total base sin seguro
    final baseTotal =
        double.tryParse(widget.precio.replaceAll(',', '')) ?? 0.0;

    // Tarifa de seguro según selección
    final feePerDay = _selectedInsurance == 0
        ? _essentialFeePerDay
        : _executiveFeePerDay;
    final insuranceTotal = feePerDay * days;

    // Gran total (sólo visual)
    final grandTotal = baseTotal + insuranceTotal;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título
          Text(
            'Reserva: ${widget.car.make} ${widget.car.model}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Fecha inicio
          Row(children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text('Fecha Inicio: ${_fmt(widget.startDate)}')),
            OutlinedButton(
              onPressed: widget.onPickStart,
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('Seleccionar'),
            ),
          ]),
          const SizedBox(height: 8),

          // Fecha fin
          Row(children: [
            const Icon(Icons.calendar_today, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(child: Text('Fecha Fin: ${_fmt(widget.endDate)}')),
            OutlinedButton(
              onPressed: widget.onPickEnd,
              style: OutlinedButton.styleFrom(
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('Seleccionar'),
            ),
          ]),
          const SizedBox(height: 12),

          // Precio por día
          Row(children: [
            const Icon(Icons.attach_money, color: Colors.grey),
            const SizedBox(width: 8),
            Text('Precio por día: Bs ${widget.car.dailyRate}'),
          ]),
          const SizedBox(height: 16),

          // Selección de seguro
          Text(
            'Selecciona tu seguro',
            style: TextStyle(fontWeight: FontWeight.bold, color: accent),
          ),
          const SizedBox(height: 8),

          // Opciones
          RadioListTile<int>(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cobertura Esencial',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Protección básica'),
            secondary:
                Text('Bs ${_essentialFeePerDay.toStringAsFixed(0)}/día'),
            value: 0,
            groupValue: _selectedInsurance,
            activeColor: accent,
            onChanged: (v) => setState(() => _selectedInsurance = v!),
          ),
          RadioListTile<int>(
            contentPadding: EdgeInsets.zero,
            title: const Text('Cobertura Ejecutiva',
                style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: const Text('Protección completa'),
            secondary:
                Text('Bs ${_executiveFeePerDay.toStringAsFixed(0)}/día'),
            value: 1,
            groupValue: _selectedInsurance,
            activeColor: accent,
            onChanged: (v) => setState(() => _selectedInsurance = v!),
          ),
          const SizedBox(height: 12),

          // Total visual incluyendo seguro
          Row(children: [
            const Icon(Icons.payment, color: Colors.grey),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Total (incluye seguro): Bs ${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          const SizedBox(height: 12),

          // Error
          if (widget.error != null) ...[
            Text(widget.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],

          // Botones de acción
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(
              onPressed: widget.onCancel,
              style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('Volver'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: widget.loading ? null : widget.onConfirm,
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(),
              ),
              child: widget.loading
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
