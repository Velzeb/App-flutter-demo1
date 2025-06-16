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

  /// Url de la foto de portada (auto o parqueo)
  final String imageUrl;

  /// Nombre de usuario (dueño del auto / parqueo)
  final String usuario;

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

  // ---------- Botones principales ----------
  /// Callback del botón “Ver más”
  final VoidCallback onVerMas;

  /// Texto opcional para el botón “Ver más” (por defecto "Ver más")
  final String? textoVerMas;

  /// Callback opcional para el botón “Editar”
  final VoidCallback? onEditar;

  /// Callback opcional para el botón “Eliminar”
  final VoidCallback? onEliminar;

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
    this.textoVerMas,
    this.onEditar,
    this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    // Botones secundarios (Editar / Eliminar) si existen
    List<Widget> _actionButtons() {
      final List<Widget> buttons = [];
      if (onEditar != null) {
        buttons.add(
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit, size: 20),
            onPressed: onEditar,
          ),
        );
      }
      if (onEliminar != null) {
        buttons.add(
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
            onPressed: onEliminar,
          ),
        );
      }
      return buttons;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Encabezado (usuario + acciones) ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  const Icon(Icons.person, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      usuario,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ..._actionButtons(),
                ],
              ),
            ),

            // ---------- Imagen de portada ----------
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 160,
                  child: Image.network(imageUrl, fit: BoxFit.cover),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: StatusBotton(disponible: disponible),
                ),
              ],
            ),

            // ---------- Título y precio ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Row(
                children: [
                  const Icon(Icons.directions_car, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      titulo,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (precio != null)
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          precio!,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ---------- Descripción ----------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: LongText(text: descripcion),
            ),
            const SizedBox(height: 6),

            // ---------- Ubicación, espacios y rango de fechas ----------
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
                child: Row(
                  children: [
                    const Icon(Icons.local_parking, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      'Espacios: $espaciosDisponibles',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            if (rangoFechas != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      rangoFechas!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // ---------- Botón principal (Ver más) ----------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Boton(
                texto: textoVerMas ?? 'Ver más',
                onPressed: onVerMas,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
