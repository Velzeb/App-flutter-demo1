import 'package:flutter/material.dart';
import '../../models/Main Screen/Availability.dart';
import '../../models/Main Screen/parkingAvailable.dart';
import '../../services/Main Screen/parking_available_service.dart';
import 'parking_available_modal_view.dart';

/// Modal que carga la disponibilidad del parking seleccionado y la muestra.
class ParkingAvailableModal extends StatefulWidget {
  final ParkingAvailable parking;

  const ParkingAvailableModal({Key? key, required this.parking})
      : super(key: key);

  /// Helper para abrir el modal desde cualquier parte:
  /// ```dart
  /// ParkingAvailableModal.show(context, parkingSeleccionado);
  /// ```
  static Future<void> show(BuildContext context, ParkingAvailable parking) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ParkingAvailableModal(parking: parking),
    );
  }

  @override
  State<ParkingAvailableModal> createState() => _ParkingAvailableModalState();
}

class _ParkingAvailableModalState extends State<ParkingAvailableModal> {
  late Future<List<Availability>> _futureAvailability;
  final _service = ParkingAvailableService();

  @override
  void initState() {
    super.initState();
    _futureAvailability =
        _service.fetchParkingAvailability(widget.parking.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Availability>>(
      future: _futureAvailability,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }
        final availability = snapshot.data ?? [];
        return ParkingAvailableModalView(
          parking: widget.parking,
          availability: availability,
        );
      },
    );
  }
}
