// lib/widget/TarjetaItem.dart
import 'package:flutter/material.dart';
import 'StatusBotton.dart';
import 'LongText.dart';
import 'Boton.dart';

/// Tarjeta genérica para Autos o Parqueos.
/// - Muestra: usuario, foto, estado, título, descripción,
///            precio / ubicación / rango de fechas / espacios (opcionales)
/// - Requiere: [imageUrl] y [disponible].
class TarjetaItem extends StatelessWidget {


  final double? width;
  final double? height;

  /// Usuario que publica
  final String usuario;

  /// URL o asset de la imagen principal
  final String imageUrl;

  /// `true` si está disponible, `false` si está rentado / reservado
  final bool disponible;

  /// Título principal (nombre de auto o identificador de parqueo)
  final String titulo;

  /// Descripción (texto largo – usa LongText)
  final String descripcion;

  /// Rango de fechas o texto libre (ej. "10/10 – 15/10")
  final String? rangoFechas;

  /// Precio opcional (ej. "Bs 120/día" o "Bs 3/h")
  final String? precio;

  /// Ubicación opcional (ej. "Zona Sur • Calle 15")
  final String? ubicacion;

  /// Espacios disponibles opcional (solo parqueos)
  final int? espaciosDisponibles;

  /// Callback del botón “Ver más”
  final VoidCallback onVerMas;

  const TarjetaItem({
    super.key,
    this.width,
    this.height,
    required this.usuario,
    required this.imageUrl,
    required this.disponible,
    required this.titulo,
    required this.descripcion,
    this.rangoFechas,
    this.precio,
    this.ubicacion,
    this.espaciosDisponibles,
    required this.onVerMas,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(
        width: width ?? double.infinity,
        height: height,

    child:  Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Header: usuario ---
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                const Icon(Icons.person, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  usuario,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // --- Imagen + estado ---
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

          // --- Contenido principal ---
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y precio (si hay)
                Row(
                  children: [
                    Expanded(
                      child: Text(titulo,
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    if (precio != null)
                      Text(
                        precio!,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                const SizedBox(height: 4),

                // Descripción larga
                LongText(text: descripcion),
                const SizedBox(height: 6),

                // Ubicación, espacios, fechas
                if (ubicacion != null)
                  Row(
                    children: [
                      const Icon(Icons.place, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          ubicacion!,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (espaciosDisponibles != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Espacios: $espaciosDisponibles',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                if (rangoFechas != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      rangoFechas!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
              ],
            ),
          ),

          // --- Botón “Ver más” ---
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: Boton(texto: 'Ver más', onPressed: onVerMas),
          ),
        ],
      ),
    )
    );
  }
}
