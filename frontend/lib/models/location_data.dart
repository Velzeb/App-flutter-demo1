import 'package:latlong2/latlong.dart';

class LocationData {
  final LatLng coordinates;
  final String? address;

  const LocationData({required this.coordinates, this.address});

  @override
  String toString() {
    if (address != null && address!.isNotEmpty) {
      return address!;
    }
    return '${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}';
  }

  String get coordinatesString =>
      '${coordinates.latitude.toStringAsFixed(6)}, ${coordinates.longitude.toStringAsFixed(6)}';

  String get displayText {
    if (address != null && address!.isNotEmpty) {
      return '$address\n${coordinatesString}';
    }
    return coordinatesString;
  }
}
