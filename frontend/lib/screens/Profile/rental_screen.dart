import 'dart:io' as io; // Para plataformas móviles
import 'dart:typed_data';
import 'dart:html' as html; // Solo en web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/Renter/renter_service.dart';

class RegisterRenterScreen extends StatefulWidget {
  const RegisterRenterScreen({super.key});

  @override
  State<RegisterRenterScreen> createState() => _RegisterRenterScreenState();
}

class _RegisterRenterScreenState extends State<RegisterRenterScreen> {
  final _renterService = RenterService();

  XFile? _licenseFile;
  XFile? _idFile;

  String? _licensePreview;
  String? _idPreview;

  bool _isSubmitting = false;

  Future<void> _pickImage({required bool isLicense}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);

        setState(() {
          if (isLicense) {
            _licenseFile = picked;
            _licensePreview = url;
          } else {
            _idFile = picked;
            _idPreview = url;
          }
        });
      } else {
        setState(() {
          if (isLicense) {
            _licenseFile = picked;
          } else {
            _idFile = picked;
          }
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_licenseFile == null || _idFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona ambas imágenes')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final renter = await _renterService.registerRenter(
        driverLicenseImage: _licenseFile!.path,
        photoIdImage: _idFile!.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro como rentador exitoso')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Widget _imagePreview(String? preview, XFile? file) {
    if (kIsWeb && preview != null) {
      return Image.network(preview, height: 150);
    } else if (!kIsWeb && file != null) {
      return Image.file(io.File(file.path), height: 150);
    }
    return const Text('Ninguna imagen seleccionada');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro como Rentador')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () => _pickImage(isLicense: true),
              child: const Text('Seleccionar Licencia de Conducir'),
            ),
            _imagePreview(_licensePreview, _licenseFile),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _pickImage(isLicense: false),
              child: const Text('Seleccionar Foto de Identificación'),
            ),
            _imagePreview(_idPreview, _idFile),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Enviar solicitud'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
