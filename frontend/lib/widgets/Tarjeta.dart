// widget/TarjetaAutos.dart
import 'package:flutter/material.dart';
import 'StatusBotton.dart';
import 'LongText.dart';
import 'Boton.dart';

class TarjetaAutos extends StatelessWidget {
  final String usuario;
  final String imageUrl;
  final bool disponible;
  final String nombre;
  final String descripcion;
  final String rangoFechas;
  final VoidCallback onVerMas;

  const TarjetaAutos({
    super.key,
    required this.usuario,
    required this.imageUrl,
    required this.disponible,
    required this.nombre,
    required this.descripcion,
    required this.rangoFechas,
    required this.onVerMas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header con usuario ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.person, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  usuario,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(color: Colors.grey[800]),
                ),
              ],
            ),
          ),

          // --- Image + StatusBotton ---
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: StatusBotton(disponible: disponible),
              ),
            ],
          ),

          // --- Nombre, Descripción (LongText) y Fechas ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                LongText(text: descripcion),
                const SizedBox(height: 8),
                Text(
                  'Disponibilidad: $rangoFechas',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          // --- Botón “Ver más” usando nuestro Boton.ts ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Boton(texto: 'Ver más', onPressed: onVerMas),
          ),
        ],
      ),
    );
  }
}
