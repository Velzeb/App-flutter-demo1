import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_app/services/requesthandler.dart';
import 'package:login_app/services/session_service.dart';

/// Modelo para una renta de auto
class CarRental {
  final int id;
  final int car;
  final int renter;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final String totalPrice;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CarRental({
    required this.id,
    required this.car,
    required this.renter,
    required this.startDatetime,
    required this.endDatetime,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CarRental.fromJson(Map<String, dynamic> json) {
    return CarRental(
      id: json['id'] as int,
      car: json['car'] as int,
      renter: json['renter'] as int,
      startDatetime: DateTime.parse(json['start_datetime'] as String).toLocal(),
      endDatetime: DateTime.parse(json['end_datetime'] as String).toLocal(),
      totalPrice: json['total_price'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toLocal(),
    );
  }
}

/// Servicio que obtiene todas las rentas del usuario
class CarRentalService {
  final RequestHandler _handler = RequestHandler();
  final SessionService _session = SessionService();

  Future<List<CarRental>> fetchAllRentals() async {
    final token = _session.token;
    if (token == null) throw Exception('Usuario no autenticado');
    final headers = {'Authorization': 'Token $token'};

    final response = await _handler.getRequest(
      'api/rentals/list_car_rentals/',
      headers: headers,
    ) as List<dynamic>;

    return response
        .map((e) => CarRental.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

/// Pantalla que permite filtrar rentas Activas e Históricas
class RentalsScreen extends StatefulWidget {
  const RentalsScreen({Key? key}) : super(key: key);

  @override
  State<RentalsScreen> createState() => _RentalsScreenState();
}

class _RentalsScreenState extends State<RentalsScreen> {
  late Future<List<CarRental>> _futureRentals;
  int _selectedIndex = 0; // 0 = Activas, 1 = Históricas

  @override
  void initState() {
    super.initState();
    _futureRentals = CarRentalService().fetchAllRentals();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFFF8FAFB);
    final accent = const Color(0xFF1565C0);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Mis Rentas'),
        backgroundColor: accent,
      ),
      body: Column(
        children: [
          // Botones de filtro
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: accent,
              color: accent,
              borderColor: accent,
              selectedBorderColor: accent,
              onPressed: (i) => setState(() => _selectedIndex = i),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Activas'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Históricas'),
                ),
              ],
              isSelected: [
                _selectedIndex == 0,
                _selectedIndex == 1,
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CarRental>>(
              future: _futureRentals,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error al cargar rentas: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                final rentals = snapshot.data ?? [];
                // Filtrar por rango de fechas
                final filtered = rentals.where((r) {
                  final start = r.startDatetime;
                  final end = r.endDatetime;
                  final isActive = now.isAfter(start) && now.isBefore(end);
                  return _selectedIndex == 0 ? isActive : !isActive;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      _selectedIndex == 0
                          ? 'No tienes rentas activas.'
                          : 'No tienes rentas históricas.',
                      style: const TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _RentalCard(rental: filtered[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta estilizada para mostrar cada renta
class _RentalCard extends StatelessWidget {
  final CarRental rental;
  const _RentalCard({Key? key, required this.rental}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFF1565C0);
    final dateFmt = DateFormat('dd/MM/yyyy');
    final start = dateFmt.format(rental.startDatetime);
    final end = dateFmt.format(rental.endDatetime);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openChatModal(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.directions_car, size: 30, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Renta #${rental.id}',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text('$start – $end',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              Text('Bs ${rental.totalPrice}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: accent)),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _openChatModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ChatModal(),
    );
  }
}

/// Modal sofisticado para chat con el propietario
class ChatModal extends StatelessWidget {
  const ChatModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Chat con propietario',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  children: const [
                    Center(
                        child: Text(
                            'Próximamente: mensajería en tiempo real vía WebSocket.',
                            textAlign: TextAlign.center)),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Escribe tu mensaje...',
                        border: const OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: const Color(0xFF1565C0)),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF1565C0)),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
