// lib/widgets/car_rentout_modal.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/Main Screen/carAvailable.dart';
import '../../models/Main Screen/availability.dart';
import '../../services/image_service.dart';
import '../../services/my items/rentout_a_car.dart';
import 'car_rentout_modal_view.dart';

class RentCarModal extends StatefulWidget {
  final CarAvailable car;
  const RentCarModal({Key? key, required this.car}) : super(key: key);

  /// Abre el modal y devuelve la [Availability] creada o `null` si se canceló.
  static Future<Availability?> show(
      BuildContext context, CarAvailable car) {
    return showDialog<Availability?>(
      context: context,
      builder: (_) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding:
        const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: RentCarModal(car: car),
      ),
    );
  }

  @override
  State<RentCarModal> createState() => _RentCarModalState();
}

class _RentCarModalState extends State<RentCarModal> {
  DateTime? _start;
  DateTime? _end;
  bool _loading = false;
  String? _error;

  final _service = RentOutCarService();
  final _fmt = DateFormat('dd/MM/yyyy HH:mm');

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_start ?? now),
      );
      if (time != null) {
        setState(() {
          _start = DateTime(
              picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _pickEnd() async {
    final base = _start ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? base.add(const Duration(hours: 1)),
      firstDate: base,
      lastDate: base.add(const Duration(days: 365)),
    );
    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
            _end ?? base.add(const Duration(hours: 1))),
      );
      if (time != null) {
        setState(() {
          _end = DateTime(
              picked.year, picked.month, picked.day, time.hour, time.minute);
        });
      }
    }
  }

  Future<void> _onConfirm() async {
    if (_start == null || _end == null) {
      setState(() => _error = 'Debes seleccionar inicio y fin');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final avail = await _service.rentOutCar(
        carId: widget.car.id,
        start: _start!,
        end: _end!,
      );
      if (!mounted) return;
      Navigator.of(context).pop(avail);
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
    final imageUrl =
    ImageService.getFullImageUrl(widget.car.imageFront.toString());
    return RentCarModalView(
      imageUrl: imageUrl,
      message:
      'Define el rango de disponibilidad para ${widget.car.make} ${widget.car.model}.',
      start: _start != null ? _fmt.format(_start!) : null,
      end: _end != null ? _fmt.format(_end!) : null,
      loading: _loading,
      error: _error,
      onPickStart: _pickStart,
      onPickEnd: _pickEnd,
      onCancel: _onCancel,
      onConfirm: _onConfirm,
    );
  }
}
