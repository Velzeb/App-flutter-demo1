// lib/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';

import '../../models/user.dart';
import '../../services/me/userService.dart';
import '../../widgets/profile/edit_toggle.dart';
import '../../widgets/profile/profile_password_field.dart';
import '../../widgets/profile/profile_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey    = GlobalKey<FormState>();
  final _userSvc    = UserService();
  bool  _loading    = true;
  bool  _editing    = false;
  bool  _saving     = false;
  String? _error;

  late User user;
  late final _nameCtrl     = TextEditingController();
  late final _emailCtrl    = TextEditingController();
  late final _phoneCtrl    = TextEditingController();
  late final _passwordCtrl = TextEditingController();
  late final _confirmCtrl  = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      user = await _userSvc.fetchCurrentUser();
      _nameCtrl.text     = user.name;
      _emailCtrl.text    = user.email;
      _phoneCtrl.text    = user.phoneNumber ?? '';
    } catch (e) {
      _error = 'Error cargando perfil';
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error  = null;
    });
    try {
      user = await _userSvc.updateCurrentUser(
        name:        _nameCtrl.text.trim(),
        email:       _emailCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        password:    _passwordCtrl.text.trim().isEmpty ? null : _passwordCtrl.text.trim(),
      );
      _nameCtrl.text     = user.name;
      _emailCtrl.text    = user.email;
      _phoneCtrl.text    = user.phoneNumber ?? '';
      _passwordCtrl.clear();
      _confirmCtrl.clear();
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 48),
              ),
              const SizedBox(height: 12),
              EditToggle(
                editing: _editing,
                onChanged: (v) => setState(() => _editing = v),
              ),
              const SizedBox(height: 16),
              ProfileTextField(
                controller: _nameCtrl,
                label: 'Nombre',
                icon: Icons.person,
                enabled: _editing,
                validator: (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _emailCtrl,
                label: 'Correo',
                icon: Icons.email,
                enabled: _editing,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || !v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ProfileTextField(
                controller: _phoneCtrl,
                label: 'Teléfono',
                icon: Icons.phone,
                enabled: _editing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              ProfilePasswordField(
                controller: _passwordCtrl,
                label: 'Nueva contraseña',
                enabled: _editing,
                validator: (v) {
                  if (_editing && v != null && v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              ProfilePasswordField(
                controller: _confirmCtrl,
                label: 'Confirmar contraseña',
                enabled: _editing,
                validator: (v) {
                  if (_editing && v != _passwordCtrl.text) return 'No coincide';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _editing && !_saving ? _save : null,
                child: _saving
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Guardar Cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
