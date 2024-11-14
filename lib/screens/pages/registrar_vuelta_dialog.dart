import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/providers/vueltas_provider.dart';
import 'package:provider/provider.dart';

class RegistrarVueltaDialog extends StatefulWidget {
  final int idTurnoOperador;
  final VoidCallback onVueltaRegistrada;

  const RegistrarVueltaDialog({
    Key? key,
    required this.idTurnoOperador,
    required this.onVueltaRegistrada,
  }) : super(key: key);

  @override
  _RegistrarVueltaDialogState createState() => _RegistrarVueltaDialogState();
}

class _RegistrarVueltaDialogState extends State<RegistrarVueltaDialog> {
  final _kilometrajeInicialController = TextEditingController();
  final _horaSalidaController = TextEditingController(); // Format: HH:MM

  Future<void> _registrarVuelta() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);

    try {
      // Obtener la fecha actual y combinarla con el tiempo ingresado
      DateTime horaSalida = _combineDateAndTime(_horaSalidaController.text);

      String horaSalidaFormatted = _formatDateTime(horaSalida);

      final success = await vueltasProvider.registrarVuelta(
        context: context,
        idTurnoOperador: widget.idTurnoOperador,
        kilometrajeInicial: int.tryParse(_kilometrajeInicialController.text),
        horaSalida: horaSalidaFormatted,
        estado: 'En curso',
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Vuelta registrada con éxito')),
        );
        widget.onVueltaRegistrada();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la vuelta')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Formato de hora no válido. Por favor, usa HH:MM')),
      );
    }
  }

  DateTime _combineDateAndTime(String hourMinute) {
    final now = DateTime.now();
    final parts = hourMinute.split(':');

    if (parts.length != 2) {
      throw FormatException('Formato de hora incorrecto');
    }

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Formato Y-m-d H:i:s requerido por el backend
    return "${dateTime.year.toString().padLeft(4, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}:"
        "${dateTime.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Registrar Vuelta Manual'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _kilometrajeInicialController,
              decoration: InputDecoration(labelText: 'Kilometraje Inicial'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _horaSalidaController,
              decoration: InputDecoration(labelText: 'Hora de Salida (HH:MM)'),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _registrarVuelta,
          child: Text('Registrar'),
        ),
      ],
    );
  }
}
