import 'package:flutter/material.dart';

class DropdownEstado extends StatelessWidget {
  final String? value;
  final Function(String?)? onChanged;
  final bool isEnabled;

  const DropdownEstado({
    Key? key,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: 'Estado'),
      items: ['En curso', 'Completada', 'Perdida'].map((estado) {
        return DropdownMenuItem(value: estado, child: Text(estado));
      }).toList(),
      onChanged: isEnabled ? onChanged : null,
    );
  }
}
