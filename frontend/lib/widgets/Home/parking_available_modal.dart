import 'package:flutter/material.dart';
import 'package:login_app/widgets/Home/parking_booking_modal.dart';
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
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ParkingAvailableModal(parking: parking),
      ),
    );
  }

  @override
  State<ParkingAvailableModal> createState() => _ParkingAvailableModalState();
}

class _ParkingAvailableModalState extends State<ParkingAvailableModal> {
  late Future<List<Availability>> _futureAvailability;

  @override
  void initState() {
    super.initState();
    _futureAvailability =
        ParkingAvailableService().fetchParkingAvailability(widget.parking.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Availability>>(
      future: _futureAvailability,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        else if (snapshot.hasError) {
          return ParkingAvailableModalView.error(
              errorMessage: snapshot.error.toString(),
              onClose: () => Navigator.of(context).pop(),
          );
        } else{
          return ParkingAvailableModalView.content(
              parking: widget.parking,
              availability: snapshot.data!,
              onClose: () => Navigator.of(context).pop(),
              onNext: (){
                Navigator.of(context).pop();
                ParkingBookingModal.show(context, widget.parking);
              }
          );
        }


      },
    );
  }
}
