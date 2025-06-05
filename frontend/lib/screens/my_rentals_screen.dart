import 'package:flutter/material.dart';
import '../models/rental.dart';
import '../models/car.dart';
import '../services/car_service.dart';
import '../services/auth_service.dart';

class MyRentalsScreen extends StatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  State<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends State<MyRentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Rental> _myRentals = [];
  List<Rental> _rentalsToMe = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadRentals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRentals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser != null) {
        final myRentals = await CarService.getUserRentals(
          currentUser['email'] ?? '',
        );
        final rentalsToMe = await CarService.getRentalsToUser(
          currentUser['email'] ?? '',
        );

        setState(() {
          _myRentals = myRentals;
          _rentalsToMe = rentalsToMe;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar rentas: $e')));
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return Colors.orange;
      case RentalStatus.confirmed:
        return Colors.green;
      case RentalStatus.active:
        return Colors.blue;
      case RentalStatus.completed:
        return Colors.indigo;
      case RentalStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(RentalStatus status) {
    switch (status) {
      case RentalStatus.pending:
        return 'Pendiente';
      case RentalStatus.confirmed:
        return 'Confirmada';
      case RentalStatus.active:
        return 'Activa';
      case RentalStatus.completed:
        return 'Completada';
      case RentalStatus.cancelled:
        return 'Cancelada';
    }
  }

  Future<Car?> _getCarDetails(String carId) async {
    try {
      return await CarService.getCarById(carId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Rentas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.car_rental),
              text: 'Rentas realizadas (${_myRentals.length})',
            ),
            Tab(
              icon: const Icon(Icons.directions_car),
              text: 'Mis autos rentados (${_rentalsToMe.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildRentalsList(_myRentals, true),
                _buildRentalsList(_rentalsToMe, false),
              ],
            ),
    );
  }

  Widget _buildRentalsList(List<Rental> rentals, bool isMyRentals) {
    if (rentals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMyRentals ? Icons.car_rental : Icons.directions_car,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isMyRentals
                  ? 'No has rentado ningún auto aún'
                  : 'Ninguno de tus autos ha sido rentado',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              isMyRentals
                  ? 'Explora los autos disponibles'
                  : 'Publica tu auto para que otros lo renten',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRentals,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: rentals.length,
        itemBuilder: (context, index) {
          final rental = rentals[index];
          return _buildRentalCard(rental, isMyRentals);
        },
      ),
    );
  }

  Widget _buildRentalCard(Rental rental, bool isMyRentals) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<Car?>(
          future: _getCarDetails(rental.carId),
          builder: (context, snapshot) {
            final car = snapshot.data;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con estado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        car != null
                            ? '${car.brand} ${car.model} ${car.year}'
                            : 'Cargando...',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(rental.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(rental.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Información de la renta
                if (car != null) ...[
                  _buildInfoRow(Icons.location_on, 'Ubicación', car.location),
                ],

                _buildInfoRow(
                  isMyRentals ? Icons.person : Icons.person_outline,
                  isMyRentals ? 'Propietario' : 'Arrendatario',
                  isMyRentals
                      ? car?.ownerName ?? 'Cargando...'
                      : rental.renterName,
                ),

                _buildInfoRow(
                  Icons.calendar_today,
                  'Fechas',
                  '${_formatDate(rental.startDate)} - ${_formatDate(rental.endDate)}',
                ),

                _buildInfoRow(
                  Icons.schedule,
                  'Duración',
                  '${rental.endDate.difference(rental.startDate).inDays + 1} días',
                ),

                const SizedBox(height: 12),

                // Precio y fecha de creación
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: Bs. ${rental.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Creada: ${_formatDate(rental.createdAt)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                // Botones de acción (para futuras funcionalidades)
                if (rental.status == RentalStatus.confirmed) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Funcionalidad futura: contactar al propietario/arrendatario
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isMyRentals
                                      ? 'Contactar propietario (funcionalidad futura)'
                                      : 'Contactar arrendatario (funcionalidad futura)',
                                ),
                              ),
                            );
                          },
                          child: Text(
                            isMyRentals
                                ? 'Contactar propietario'
                                : 'Contactar arrendatario',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
