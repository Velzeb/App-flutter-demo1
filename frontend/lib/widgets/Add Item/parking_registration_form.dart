// lib/widgets/parking_registration_form.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/parking.dart';
import '../../models/location_data.dart';
import '../../services/Add Items/parking_service.dart';
import '../map/modern_location_picker.dart';
import '../../theme/app_theme.dart';

class ParkingRegistrationForm extends StatefulWidget {
  final void Function(Parking)? onSubmit;
  const ParkingRegistrationForm({Key? key, this.onSubmit}) : super(key: key);

  @override
  State<ParkingRegistrationForm> createState() =>
      _ParkingRegistrationFormState();
}

class _ParkingRegistrationFormState extends State<ParkingRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _service = ParkingService();
  final _picker = ImagePicker();
  XFile? _image;
  LocationData? _position;
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) setState(() => _image = file);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LocationData>(
      MaterialPageRoute(
        builder: (context) => ModernLocationPicker(
          initialLocation: _position?.coordinates,
          title: 'Ubicación del Parqueo',
          subtitle: 'Selecciona la ubicación exacta donde estará tu parqueo',
        ),
      ),
    );

    if (result != null) {
      setState(() => _position = result);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  bool _validate() {
    if (!_formKey.currentState!.validate()) return false;
    if (_image == null) {
      _snack('Seleccione una imagen');
      return false;
    }
    if (_position == null) {
      _snack('Seleccione una ubicación');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _submitting = true);

    try {
      final newParking = await _service.registerParking(
        parking: Parking(
          name: _nameCtrl.text.trim(),
          address: _position!.address ?? _position!.coordinatesString,
          description: _descCtrl.text.trim(),
          image: Uri.parse(''),
          hourlyRate: _rateCtrl.text.trim(),
          isActive: true,
        ),
        imagePath: _image!.path,
      );
      _snack('Parqueo registrado');
      widget.onSubmit?.call(newParking);
      _formKey.currentState!.reset();
      setState(() {
        _image = null;
        _position = null;
      });
    } catch (e) {
      _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _submitting,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre del parqueo',
                hintText: 'Ej: Parqueo Central',
                prefixIcon: const Icon(Icons.local_parking),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'El nombre es requerido' : null,
            ),
            const SizedBox(height: 12),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: _pickLocation,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _position != null
                          ? AppTheme.primaryColor.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    gradient: _position != null
                        ? LinearGradient(
                            colors: [
                              AppTheme.primaryColor.withOpacity(0.05),
                              AppTheme.secondaryColor.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _position != null
                              ? AppTheme.primaryColor
                              : Colors.grey.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _position != null
                              ? Icons.location_on
                              : Icons.location_off,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ubicación del parqueo',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _position != null
                                    ? AppTheme.primaryColor
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _position != null
                                  ? _position!.displayText
                                  : 'Toca para seleccionar en el mapa',
                              style: TextStyle(
                                fontSize: 12,
                                color: _position != null
                                    ? Colors.grey[700]
                                    : Colors.grey[500],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe las características del parqueo',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateCtrl,
              decoration: InputDecoration(
                labelText: 'Tarifa por hora',
                hintText: 'Ej: 5.00',
                prefixIcon: const Icon(Icons.attach_money),
                suffixText: 'Bs',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (v) =>
                  v == null || v.isEmpty ? 'La tarifa es requerida' : null,
            ),
            const SizedBox(height: 20),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _image != null
                        ? AppTheme.primaryColor.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.3),
                    width: 1,
                  ),
                  gradient: _image != null
                      ? LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withOpacity(0.05),
                            AppTheme.secondaryColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: _image == null
                          ? Icon(
                              Icons.image_outlined,
                              color: Colors.grey[400],
                              size: 30,
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.file(
                                File(_image!.path),
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Imagen del parqueo',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _image != null
                                  ? AppTheme.primaryColor
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _image != null
                                ? 'Imagen seleccionada'
                                : 'Agrega una foto de tu parqueo',
                            style: TextStyle(
                              fontSize: 12,
                              color: _image != null
                                  ? Colors.grey[700]
                                  : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(
                        _image != null ? Icons.edit : Icons.upload_file,
                        size: 18,
                      ),
                      label: Text(_image != null ? 'Cambiar' : 'Elegir'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Icon(Icons.cloud_upload, color: Colors.white),
                label: Text(
                  _submitting ? 'Registrando...' : 'Registrar Parqueo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
