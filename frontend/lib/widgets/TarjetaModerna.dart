import 'package:flutter/material.dart';
import 'LongText.dart';

/// Tarjeta moderna y profesional para Autos o Parqueos.
/// Diseñada con Material Design 3 y mejores prácticas de UI/UX
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
  /// Callback del botón "Ver más"
  final VoidCallback onVerMas;

  /// Texto opcional para el botón "Ver más" (por defecto "Ver más")
  final String? textoVerMas;

  /// Callback opcional para el botón "Editar"
  final VoidCallback? onEditar;

  /// Callback opcional para el botón "Eliminar"
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
    final theme = Theme.of(context);

    return Container(
      width: width ?? double.infinity,
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Stack con imagen y estado ----------
            Stack(
              children: [
                // Imagen de fondo
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Gradiente superior para mejorar legibilidad
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.center,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),

                // Usuario en la parte superior
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          usuario,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Botones de acción en la esquina superior derecha
                if (onEditar != null || onEliminar != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEditar != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: onEditar,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        if (onEditar != null && onEliminar != null)
                          const SizedBox(width: 8),
                        if (onEliminar != null)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: onEliminar,
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                      ],
                    ),
                  ),

                // Estado de disponibilidad
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: disponible
                          ? const Color(0xFF43A047)
                          : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (disponible
                                      ? const Color(0xFF43A047)
                                      : const Color(0xFFE53935))
                                  .withOpacity(0.3),
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      disponible ? 'Disponible' : 'No disponible',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ---------- Contenido principal ----------
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    titulo,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF212121),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Descripción
                  LongText(text: descripcion, trimLines: 2),
                  const SizedBox(height: 12),

                  // Información adicional
                  if (ubicacion != null ||
                      espaciosDisponibles != null ||
                      rangoFechas != null)
                    Column(
                      children: [
                        if (ubicacion != null)
                          _buildInfoRow(Icons.location_on, ubicacion!),
                        if (espaciosDisponibles != null)
                          _buildInfoRow(
                            Icons.local_parking,
                            '$espaciosDisponibles espacios',
                          ),
                        if (rangoFechas != null)
                          _buildInfoRow(Icons.date_range, rangoFechas!),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // Precio y botón
                  Row(
                    children: [
                      if (precio != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Precio',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF757575),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                precio!,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: const Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Botón Ver más
                      ElevatedButton(
                        onPressed: onVerMas,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0),
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: const Color(0xFF1565C0).withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          textoVerMas ?? 'Ver más',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF757575)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14, color: Color(0xFF757575)),
            ),
          ),
        ],
      ),
    );
  }
}
