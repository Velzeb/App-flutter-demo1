// lib/screens/pending_verifications_screen.dart

import 'package:flutter/material.dart';

import '../../models/renter.dart';
import '../../services/image_service.dart';
import '../../services/me/renter_service.dart';


class PendingVerificationsScreen extends StatefulWidget {
  const PendingVerificationsScreen({Key? key}) : super(key: key);

  @override
  State<PendingVerificationsScreen> createState() =>
      _PendingVerificationsScreenState();
}

class _PendingVerificationsScreenState
    extends State<PendingVerificationsScreen> {
  final _service = RenterService();
  late Future<List<Renter>> _future;
  List<Renter> _pendings = [];

  @override
  void initState() {
    super.initState();
    _future = _service.listPendingVerifications();
  }

  void _approve(Renter renter) async {
    try {
      await _service.verifyRenter(renter.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rentador aprobado')),
      );
      setState(() => _pendings.remove(renter));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al aprobar: \$e')),
      );
    }
  }

  void _hide(Renter renter) {
    setState(() => _pendings.remove(renter));
  }

  void _viewLicense(Renter renter) {
    final rel = renter.driverLicenseImage?.toString() ?? '';
    if (rel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay imagen de licencia')),
      );
      return;
    }
    final url = ImageService.getFullImageUrl(rel);
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(url),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Renter>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('Error: \${snap.error}'));
        }
        _pendings = snap.data ?? [];
        if (_pendings.isEmpty) {
          return const Center(child: Text('No hay verificaciones pendientes.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pendings.length,
          itemBuilder: (context, i) {
            final renter = _pendings[i];
            final relPhoto = renter.photoIdImage?.toString() ?? '';
            final photoUrl = relPhoto.isNotEmpty
                ? ImageService.getFullImageUrl(relPhoto)
                : null;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // Foto de documento de identidad o placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: photoUrl != null
                          ? Image.network(photoUrl,
                          width: 100, height: 100, fit: BoxFit.cover)
                          : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person_outline,
                            size: 40, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Detalles y botones
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(renter.name,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(renter.email,
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _viewLicense(renter),
                                child: const Text('Ver licencia'),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                onPressed: () => _approve(renter),
                                child: const Text('Aprobar'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => _hide(renter),
                                child: const Text('Ocultar'),
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
          },
        );
      },
    );
  }
}
