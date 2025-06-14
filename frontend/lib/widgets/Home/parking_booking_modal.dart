// lib/widgets/parking_booking_modal.dart
//
// Controlador de lógica para la reserva de un estacionamiento.
// Ahora la tarifa se calcula **por hora** en lugar de por día.
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../models/Main Screen/parkingAvailable.dart';
import '../../models/Main Screen/reservation.dart';
import '../../services/Main Screen/reservation_service.dart';
import '../Home/reservation_confirmation_model.dart';
import 'parking_booking_modal_view.dart';

class ParkingBookingModal extends StatefulWidget {
  final ParkingAvailable parking;
  const ParkingBookingModal({Key? key, required this.parking}) : super(key: key);

  /// Abre el diálogo y devuelve la [Reservation] creada o `null` si se canceló.
  static Future<Reservation?> show(BuildContext context, ParkingAvailable parking) {
    return showDialog<Reservation?>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ParkingBookingModal(parking: parking),
      ),
    );
  }

  @override
  State<ParkingBookingModal> createState() => _ParkingBookingModalState();
}

class _ParkingBookingModalState extends State<ParkingBookingModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _error;
  bool _loading = false;

  /// Horas totales de estadía (redondeadas al múltiplo de horas completas).
  int get _hours {
    if (_startDate == null || _endDate == null) return 0;
    final diff = _endDate!.difference(_startDate!).inHours;
    // Si el usuario elige la misma fecha (0 h) se cuenta como 1 h mínima.
    return diff == 0 ? 1 : diff;
  }

  /// Total = horas * tarifa por hora.
  String get _total {
    final hours = _hours;
    final rate = double.tryParse(widget.parking.hourlyRate) ?? 0.0; // se usa el mismo campo como tarifa por hora
    return hours > 0 ? (hours * rate).toStringAsFixed(2) : '0.00';
  }

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEnd() async {
    final initial = _endDate ?? (_startDate?.add(const Duration(hours: 1)) ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _onConfirm() async {
    if (_startDate == null || _endDate == null) {
      setState(() => _error = 'Debes seleccionar ambas fechas');
      return;
    }

    // -------- Confirmación previa --------
    final confirmed = await ReservationConfirmationModal.show(
      context,
      owner: widget.parking.owner.toString(),
      startDate: _startDate!,
      endDate: _endDate!,
      total: _total,
    );
    if (confirmed != true) return; // Cancelado

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reservation = await ReservationService().bookParking(
        parkingId: widget.parking.id,
        start: _startDate!,
        end: _endDate!,
      );
      Navigator.of(context).pop(reservation);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onCancel() => Navigator.of(context).pop(null);

  @override
  Widget build(BuildContext context) {
    return ParkingBookingModalView(
      parking: widget.parking,
      startDate: _startDate,
      endDate: _endDate,
      total: _total,
      error: _error,
      loading: _loading,
      onPickStart: _pickStart,
      onPickEnd: _pickEnd,
      onCancel: _onCancel,
      onConfirm: _onConfirm,
    );
  }
}
