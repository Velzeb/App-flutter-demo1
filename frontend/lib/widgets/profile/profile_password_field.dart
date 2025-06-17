// lib/widgets/profile/profile_password_field.dart

import 'package:flutter/material.dart';

class ProfilePasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool enabled;
  final String? Function(String?)? validator;

  const ProfilePasswordField({
    Key? key,
    required this.controller,
    required this.label,
    this.enabled = false,
    this.validator,
  }) : super(key: key);

  @override
  State<ProfilePasswordField> createState() => _ProfilePasswordFieldState();
}

class _ProfilePasswordFieldState extends State<ProfilePasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      enabled: widget.enabled,
      obscureText: ! _visible,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _visible ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: widget.enabled ? () {
            setState(() => _visible = !_visible);
          } : null,
        ),
        border: const OutlineInputBorder(),
      ),
      validator: widget.enabled ? widget.validator : null,
    );
  }
}
