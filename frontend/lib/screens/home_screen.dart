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
    // Simulamos N tarjetas (aquí 4), podrían venir de tu backend
    final cards = List.generate(4, (i) {
      final disponible = (_selectedIndex == 1)
          ? true
          : (_selectedIndex == 2 ? false : i % 2 == 0);
      final rango = disponible
          ? '10/10/2020 - 15/10/2020'
          : 'Reservado: 10/10/2020 - 15/10/2020\nDisponible: 16/10/2020';
      return TarjetaAutos(
        usuario: 'usuario${i + 1}',
        imageUrl: 'https://via.placeholder.com/400x200',
        disponible: disponible,
        nombre: 'Auto Dummy ${i + 1}',
        descripcion:
        'Descripción de ejemplo para la tarjeta ${i + 1}. Texto largo para probar LongText y asegurar que no explote el layout.',
        rangoFechas: rango,
        onVerMas: () {
          // TODO: Navegar a detalle
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
          // NavBar superior
          SearchNavBar(
            selectedIndex: _selectedIndex,
            onTap: (idx) => setState(() => _selectedIndex = idx),
          ),

          // Contenedor de tarjetas en Wrap para dos columnas dinámicas
          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = 12.0;
                  // Ancho disponible para cada tarjeta: restamos el espacio entre
                  final itemWidth = (constraints.maxWidth - spacing) / 2;
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: spacing,
                      runSpacing: spacing,
                      children: cards
                          .map((card) =>
                          SizedBox(width: itemWidth, child: card))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
