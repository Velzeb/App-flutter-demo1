import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/item_registration_service.dart';
import '../widgets/car_registration_form.dart';
import '../widgets/parking_registration_form.dart';

class RegisterItemScreen extends StatefulWidget {
  const RegisterItemScreen({super.key});

  @override
  State<RegisterItemScreen> createState() => _RegisterItemScreenState();
}

class _RegisterItemScreenState extends State<RegisterItemScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ItemRegistrationService _registrationService =
      ItemRegistrationService();
  final SessionService _sessionService = SessionService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    if (mounted) {
      setState(() {
        _isLoading = loading;
      });
    }
  }

  Future<void> _registerCar(Map<String, dynamic> carData) async {
    _setLoading(true);
    try {
      await _registrationService.registerCar(carData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Auto registrado exitosamente. ¡Ahora configura su disponibilidad!',
            ),
          ),
        );
        // Navegar a la pantalla de configuración de disponibilidad
        _navigateToAvailabilityConfiguration(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al registrar auto: $e')));
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _registerParking(Map<String, dynamic> parkingData) async {
    _setLoading(true);
    try {
      await _registrationService.registerParking(parkingData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Parqueo registrado exitosamente. ¡Ahora configura su disponibilidad!',
            ),
          ),
        );
        // Navegar a la pantalla de configuración de disponibilidad
        _navigateToAvailabilityConfiguration(false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar parqueo: $e')),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  void _navigateToAvailabilityConfiguration(bool isCar) {
    // Aquí implementaremos la navegación a la pantalla de configuración
    // de disponibilidad una vez que tengamos esa pantalla
    // Por ahora, muestra un diálogo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configurar Disponibilidad'),
        content: Text(
          isCar
              ? 'Aquí configurarás cuando tu auto está disponible para alquiler.'
              : 'Aquí configurarás cuando tu parqueo está disponible para alquiler.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Item para Alquiler'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.directions_car), text: 'Auto'),
            Tab(icon: Icon(Icons.local_parking), text: 'Parqueo'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Formulario para registro de autos
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CarRegistrationForm(onSubmit: _registerCar),
                  ),
                ),
                // Formulario para registro de parqueos
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ParkingRegistrationForm(onSubmit: _registerParking),
                  ),
                ),
              ],
            ),
    );
  }
}
