// lib/Screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/SearchNavBar.dart';
import '../widgets/Tarjeta.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // 0: Inicio, 1: Disponibles, 2: Reservados

  @override
  Widget build(BuildContext context) {
    // Generamos 4 dummies
    final cards = List.generate(4, (i) {
      final disponible = (_selectedIndex == 1) ? true : (_selectedIndex == 2 ? false : i % 2 == 0);
      final rango = disponible
          ? '10/10/2020 - 15/10/2020'
          : 'Reservado: 10/10/2020 - 15/10/2020\nDisponible desde: 16/10/2020';

      return TarjetaAutos(
        usuario: 'usuario${i + 1}',
        imageUrl: 'https://via.placeholder.com/400x200',
        disponible: disponible,
        nombre: 'Auto Dummy ${i + 1}',
        descripcion:
        'Este es un auto de prueba con descripción larga para validar el LongText widget. Línea $i.',
        rangoFechas: rango,
        onVerMas: () {
          // TODO: navegar a detalle
        },
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFEFF5F9),
      appBar: AppBar(
        title: const Text('Anuncios Recientes'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          // NavBar con Inicio, Disponibles, Reservados
          SearchNavBar(
            selectedIndex: _selectedIndex,
            onTap: (idx) => setState(() => _selectedIndex = idx),
          ),

          // Grid de 2 columnas x 2 filas
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.65,
                children: cards,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
