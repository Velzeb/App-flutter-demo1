// lib/widget/reservation_booking_modal.dart

import 'package:flutter/material.dart';
import '../../models/carAvailable.dart';
import '../../models/reservation_car.dart';
import '../../services/reservation_service.dart';
import 'reservation_booking_modal_view.dart';

class ReservationBookingModal extends StatefulWidget {
  final CarAvailable car;
  const ReservationBookingModal({Key? key, required this.car}) : super(key: key);

  /// Abre el modal y devuelve la [Reservation] creada o null si se canceló.
  static Future<Reservation?> show(BuildContext context, CarAvailable car) {
    return showDialog<Reservation?>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ReservationBookingModal(car: car),
      ),
    );
  }

  @override
  _ReservationBookingModalState createState() => _ReservationBookingModalState();
}

class _ReservationBookingModalState extends State<ReservationBookingModal> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _error;
  bool _loading = false;
  Reservation? _result;

  /// Calcula el número de días incluidos (primero y último)
  int get _days {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays;
  }

  /// Calcula el total de renta como días * tarifa diaria
  String get _total {
    final days = _days;
    final rate = double.tryParse(widget.car.dailyRate) ?? 0.0;
    return days > 0 ? (days * rate).toStringAsFixed(2) : '0.00';
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
    final initial = _endDate ?? (_startDate?.add(const Duration(days: 1)) ?? DateTime.now());
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
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final reservation = await ReservationService().bookCar(
        carId: widget.car.id,
        start: _startDate!,
        end: _endDate!,
      );
      _result = reservation;
      // Imprime la respuesta en consola
      print('Reserva creada: ${reservation.toJson()}');
      Navigator.of(context).pop(reservation);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onCancel() {
    Navigator.of(context).pop(null);
  }

  @override
  Widget build(BuildContext context) {
    return ReservationBookingModalView(
      car: widget.car,
      startDate: _startDate,
      endDate: _endDate,
      precio: _total,
      error: _error,
      loading: _loading,
      onPickStart: _pickStart,
      onPickEnd: _pickEnd,
      onCancel: _onCancel,
      onConfirm: _onConfirm,
    );
  }
}
