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
  final _horaSalidaController = TextEditingController();
  final _kilometrajeFinalController = TextEditingController();
  final _horaLlegadaController = TextEditingController();
  final _boletosVendidosController = TextEditingController();

  Future<void> _registrarVuelta() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);

    final success = await vueltasProvider.registrarVuelta(
      context: context,
      idTurnoOperador: widget.idTurnoOperador,
      kilometrajeInicial: int.tryParse(_kilometrajeInicialController.text),
      horaSalida: _horaSalidaController.text,
      kilometrajeFinal: int.tryParse(_kilometrajeFinalController.text),
      horaLlegada: _horaLlegadaController.text,
      boletosVendidos: int.tryParse(_boletosVendidosController.text),
      estado: 'Completada',
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
              decoration: InputDecoration(
                  labelText: 'Hora de Salida (YYYY-MM-DD HH:MM:SS)'),
            ),
            TextField(
              controller: _kilometrajeFinalController,
              decoration: InputDecoration(labelText: 'Kilometraje Final'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _horaLlegadaController,
              decoration: InputDecoration(
                  labelText: 'Hora de Llegada (YYYY-MM-DD HH:MM:SS)'),
            ),
            TextField(
              controller: _boletosVendidosController,
              decoration: InputDecoration(labelText: 'Boletos Vendidos'),
              keyboardType: TextInputType.number,
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
