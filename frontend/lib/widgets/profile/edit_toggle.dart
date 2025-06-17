import 'package:flutter/material.dart';

class EditToggle extends StatelessWidget {
  final bool editing;
  final ValueChanged<bool> onChanged;

  const EditToggle({
    Key? key,
    required this.editing,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(editing ? 'Modo edición activo' : 'Editar perfil'),
      value: editing,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
      secondary: Icon(editing ? Icons.edit_off : Icons.edit),
    );
  }
}
