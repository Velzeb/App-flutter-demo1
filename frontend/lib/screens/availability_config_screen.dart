import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../services/item_registration_service.dart';
import 'package:intl/intl.dart';

class AvailabilityConfigScreen extends StatefulWidget {
  final bool isCarAvailability; // true para auto, false para parqueo
  final int itemId; // ID del auto o parqueo
  final String itemName; // Nombre o descripción del ítem para mostrar

  const AvailabilityConfigScreen({
    super.key,
    required this.isCarAvailability,
    required this.itemId,
    required this.itemName,
  });

  @override
  State<AvailabilityConfigScreen> createState() =>
      _AvailabilityConfigScreenState();
}

class _AvailabilityConfigScreenState extends State<AvailabilityConfigScreen> {
  final SessionService _sessionService = SessionService();
  final ItemRegistrationService _registrationService =
      ItemRegistrationService();

  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _endTime = TimeOfDay.now();

  bool _isLoading = false;
  final List<Map<String, dynamic>> _availabilityPeriods = [];

  @override
  void initState() {
    super.initState();
    _loadAvailabilities();
  }

  Future<void> _loadAvailabilities() async {
    // Aquí se podría cargar las disponibilidades existentes
    // Por ahora, dejamos la lista vacía
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;

        // Asegurarse que la fecha de fin no sea anterior a la de inicio
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isAfter(_endDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  DateTime _combineDateTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _addAvailability() async {
    final startDateTime = _combineDateTime(_startDate, _startTime);
    final endDateTime = _combineDateTime(_endDate, _endTime);

    // Validar que la fecha de fin sea posterior a la de inicio
    if (endDateTime.isBefore(startDateTime) ||
        endDateTime.isAtSameMomentAs(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'La fecha/hora de fin debe ser posterior a la de inicio',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Preparar los datos para enviar
      final availabilityData = {
        widget.isCarAvailability ? 'car' : 'parking': widget.itemId,
        'start_datetime': startDateTime.toIso8601String(),
        'end_datetime': endDateTime.toIso8601String(),
      };

      // Llamar al servicio correspondiente según el tipo de ítem
      final response = widget.isCarAvailability
          ? await _registrationService.createCarAvailability(availabilityData)
          : await _registrationService.createParkingAvailability(
              availabilityData,
            );

      // Agregar a la lista local para mostrar al usuario
      setState(() {
        _availabilityPeriods.add({
          'id': response['id'],
          'start_datetime': startDateTime,
          'end_datetime': endDateTime,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disponibilidad agregada con éxito')),
      );

      // Resetear los valores para facilitar la adición de otro período
      setState(() {
        _startDate = DateTime.now();
        _endDate = DateTime.now().add(const Duration(days: 1));
        _startTime = TimeOfDay.now();
        _endTime = TimeOfDay.now();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al agregar disponibilidad: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _finishConfiguration() async {
    if (_availabilityPeriods.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe agregar al menos un período de disponibilidad'),
        ),
      );
      return;
    }

    // Navegar a la pantalla principal o a donde sea necesario
    Navigator.of(context).pop(); // Volver a la pantalla anterior
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Tu ítem está listo para ser rentado!')),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final date = DateFormat('dd/MM/yyyy').format(dateTime);
    final time = DateFormat('HH:mm').format(dateTime);
    return '$date a las $time';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Configurar Disponibilidad')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y descripción
                    Text(
                      'Configura cuándo está disponible tu ${widget.isCarAvailability ? "auto" : "parqueo"}',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.itemName,
                      style: Theme.of(context).textTheme.subtitle1?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selección de fecha y hora de inicio
                    const Text(
                      'Disponible desde:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectStartDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              DateFormat('dd/MM/yyyy').format(_startDate),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectStartTime(context),
                            icon: const Icon(Icons.access_time),
                            label: Text(_startTime.format(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Selección de fecha y hora de fin
                    const Text(
                      'Disponible hasta:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectEndDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              DateFormat('dd/MM/yyyy').format(_endDate),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _selectEndTime(context),
                            icon: const Icon(Icons.access_time),
                            label: Text(_endTime.format(context)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botón para agregar disponibilidad
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _addAvailability,
                        icon: const Icon(Icons.add),
                        label: const Text('AGREGAR PERÍODO'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Lista de períodos de disponibilidad
                    if (_availabilityPeriods.isNotEmpty) ...[
                      const Text(
                        'Períodos de disponibilidad agregados:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(_availabilityPeriods.length, (index) {
                        final period = _availabilityPeriods[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.event_available),
                            title: Text('Período ${index + 1}'),
                            subtitle: Text(
                              'De ${_formatDateTime(period['start_datetime'])} hasta ${_formatDateTime(period['end_datetime'])}',
                            ),
                          ),
                        );
                      }),
                    ] else ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No hay períodos de disponibilidad configurados',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Botón para finalizar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _finishConfiguration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'FINALIZAR CONFIGURACIÓN',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
