import 'package:flutter/material.dart';
import 'package:login_app/widgets/Home/reservation_booking_modal.dart';
import '../../models/Main Screen/Availability.dart';
import '../../models/Main Screen/carAvailable.dart';
import '../../services/car_available_service.dart';
import 'car_available_modal_view.dart';
import 'car_photos_modal.dart';

/// Lógica del modal: carga disponibilidad y delega la presentación al view.
class CarAvailableModal extends StatefulWidget {
  final CarAvailable car;
  const CarAvailableModal({Key? key, required this.car}) : super(key: key);

  static Future<void> show(BuildContext context, CarAvailable car) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: CarAvailableModal(car: car),
      ),
    );
  }

  @override
  _CarAvailableModalState createState() => _CarAvailableModalState();
}

class _CarAvailableModalState extends State<CarAvailableModal> {
  late Future<List<Availability>> _availabilityFuture;

  @override
  void initState() {
    super.initState();
    _availabilityFuture =
        CarAvailableService().fetchCarAvailability(widget.car.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Availability>>(
      future: _availabilityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return CarAvailableModalView.error(
            errorMessage: snapshot.error.toString(),
            onClose: () => Navigator.of(context).pop(),
          );
        } else {
          return CarAvailableModalView.content(
            car: widget.car,
            availability: snapshot.data!,
            onClose: () => Navigator.of(context).pop(),
            onNext: () {
              Navigator.of(context).pop();
              ReservationBookingModal.show(context, widget.car);
            },
            onViewPhotos: () {
              CarPhotosModal.show(context, widget.car);
            },
          );
        }
      },
    );
  }
}
