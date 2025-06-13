import 'package:flutter/material.dart';
import '../../widgets/Tarjeta.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ejemplo: genera 6 tarjetas de prueba
    final items = List.generate(6, (index) {
      final disponible = index.isEven;
      return TarjetaItem(
        // width y height se dejan null → usan todo el ancho y altura dinámica
        usuario: 'usuario${index + 1}',
        imageUrl: 'https://via.placeholder.com/400x200',
        disponible: disponible,
        titulo: 'Auto ${index + 1}',
        descripcion:
        'Descripción de prueba para la tarjeta ${index + 1}. Texto extendido para comprobar el LongText.',
        rangoFechas: disponible
            ? '15/06 - 20/06'
            : 'Reservado: 10/06 - 14/06\nDisponible desde 15/06',
        precio: 'Bs 120/día',
        ubicacion: 'Zona Central',
        onVerMas: () {
          // Acción al presionar “Ver más”
        },
      );
    });

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (_, i) => items[i],
      separatorBuilder: (_, __) => const SizedBox(height: 4),
    );
  }
}