// lib/screens/renter_profile_form.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/renter.dart';
import '../../services/me/renter_service.dart';

class RenterProfileForm extends StatefulWidget {
  /// Callback que recibe el Renter actualizado tras registrar perfil.
  final void Function(Renter)? onRegistered;

  const RenterProfileForm({Key? key, this.onRegistered}) : super(key: key);

  @override
  State<RenterProfileForm> createState() => _RenterProfileFormState();
}

class _RenterProfileFormState extends State<RenterProfileForm> {
  final _picker = ImagePicker();
  final _service = RenterService();

  XFile? _licenseImage;
  XFile? _photoIdImage;
  bool  _submitting = false;
  String? _error;

  Future<void> _pickLicense() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _licenseImage = picked);
  }

  Future<void> _pickPhotoId() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) setState(() => _photoIdImage = picked);
  }

  bool _validate() {
    if (_licenseImage == null) {
      _showSnack('Seleccione la imagen de la licencia');
      return false;
    }
    if (_photoIdImage == null) {
      _showSnack('Seleccione la imagen del documento de identidad');
      return false;
    }
    return true;
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final renter = await _service.registerProfile(
        driverLicensePath: _licenseImage!.path,
        photoIdPath:       _photoIdImage!.path,
      );
      _showSnack('Perfil de rentador registrado');
      widget.onRegistered?.call(renter);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildImagePicker({
    required String label,
    required XFile? file,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPick,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: file == null
                ? const Center(child: Icon(Icons.upload_file, size: 40, color: Colors.grey))
                : Image.file(File(file.path), fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _submitting,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildImagePicker(
              label: 'Imagen de licencia de conducir',
              file: _licenseImage,
              onPick: _pickLicense,
            ),
            _buildImagePicker(
              label: 'Imagen de documento de identidad',
              file: _photoIdImage,
              onPick: _pickPhotoId,
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.save),
              label: Text(_submitting ? 'Enviando...' : 'Registrar perfil'),
            ),
          ],
        ),
      ),
    );
  }
}
