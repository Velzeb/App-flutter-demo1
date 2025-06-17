import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/renter/renter_service.dart';

class RegisterRenterScreen extends StatefulWidget {
  const RegisterRenterScreen({super.key});

  @override
  State<RegisterRenterScreen> createState() => _RegisterRenterScreenState();
}

class _RegisterRenterScreenState extends State<RegisterRenterScreen> {
  final RenterService _renterService = RenterService();

  File? _licenseImage;
  File? _photoIdImage;
  bool _isSubmitting = false;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage(Function(File) onPicked) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      onPicked(File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_licenseImage == null || _photoIdImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes seleccionar ambas imágenes')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _renterService.registerRenter(
        driverLicenseImage: _licenseImage!.path,
        photoIdImage: _photoIdImage!.path,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitud enviada correctamente')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ser Rentador')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text('Licencia de conducir'),
              const SizedBox(height: 8),
              _licenseImage != null
                  ? Image.file(_licenseImage!, height: 100)
                  : const Text('No seleccionada'),
              ElevatedButton(
                onPressed: () => _pickImage((file) {
                  setState(() => _licenseImage = file);
                }),
                child: const Text('Seleccionar Licencia'),
              ),
              const SizedBox(height: 16),
              const Text('Foto de identificación'),
              const SizedBox(height: 8),
              _photoIdImage != null
                  ? Image.file(_photoIdImage!, height: 100)
                  : const Text('No seleccionada'),
              ElevatedButton(
                onPressed: () => _pickImage((file) {
                  setState(() => _photoIdImage = file);
                }),
                child: const Text('Seleccionar Foto ID'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator()
                    : const Text('Enviar solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
