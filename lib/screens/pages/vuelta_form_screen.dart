import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:flutter_registro/screens/providers/vueltas_provider.dart';
import 'package:flutter_registro/screens/widgets/custom_button.dart';
import 'package:flutter_registro/screens/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';

class VueltaFormScreen extends StatefulWidget {
  final Dotacion dotacion;

  const VueltaFormScreen({Key? key, required this.dotacion}) : super(key: key);

  @override
  _VueltaFormScreenState createState() => _VueltaFormScreenState();
}

class _VueltaFormScreenState extends State<VueltaFormScreen> {
  final _kilometrajeController = TextEditingController();
  final _boletosController = TextEditingController();
  bool esPrimeraVuelta = false;
  bool esVueltaDeRegreso = false;
  bool esNuevaVuelta = false;

  @override
  void initState() {
    super.initState();
    _determinarEstadoVuelta();
  }

  Future<void> _determinarEstadoVuelta() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    final idTurnoOperador =
        turnProvider.obtenerIdTurnoOperador(int.parse(widget.dotacion.agente));

    if (idTurnoOperador != null) {
      bool hayVueltaEnCurso =
          await vueltasProvider.vueltaEnCurso(idTurnoOperador, context);
      bool hayVueltaRegistrada =
          await vueltasProvider.hayVueltaRegistrada(idTurnoOperador, context);

      setState(() {
        esPrimeraVuelta = !hayVueltaRegistrada;
        esVueltaDeRegreso = hayVueltaEnCurso;
        esNuevaVuelta = hayVueltaRegistrada && !hayVueltaEnCurso;
      });
    } else {
      _mostrarMensaje('Error: no se pudo obtener el ID del turno del operador');
    }
  }

  Future<void> _registrarVuelta() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    final idTurnoOperador =
        turnProvider.obtenerIdTurnoOperador(int.parse(widget.dotacion.agente));
    final now = DateTime.now();

    if (idTurnoOperador == null) {
      _mostrarMensaje('Error: no se pudo obtener el ID del turno del operador');
      return;
    }

    bool success = false;
    if (esVueltaDeRegreso) {
      success = await _registrarVueltaDeRegreso(
          vueltasProvider, idTurnoOperador, now);
    } else {
      success = await vueltasProvider.registrarVuelta(
        context: context,
        kilometrajeInicial:
            esPrimeraVuelta ? int.parse(_kilometrajeController.text) : null,
        horaSalida: _formatDateTime(now),
        idTurnoOperador: idTurnoOperador,
        estado: 'En curso',
      );
    }

    _mostrarMensaje(success
        ? 'Vuelta registrada con éxito'
        : 'Error al registrar la vuelta');
    if (success) Navigator.pop(context);
  }

  Future<bool> _registrarVueltaDeRegreso(VueltasProvider vueltasProvider,
      int idTurnoOperador, DateTime now) async {
    final idVuelta =
        await vueltasProvider.obtenerUltimoIdVuelta(idTurnoOperador, context);
    if (idVuelta == null) {
      _mostrarMensaje('Error: No se pudo obtener el ID de la vuelta');
      return false;
    }
    return await vueltasProvider.actualizarVuelta(
      context: context,
      idVuelta: idVuelta,
      idTurnoOperador: idTurnoOperador,
      horaLlegada: _formatDateTime(now),
      boletosVendidos: int.parse(_boletosController.text),
      estado: 'Completada',
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(mensaje)));
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Vuelta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (esPrimeraVuelta)
              CustomTextField(
                controller: _kilometrajeController,
                label: 'Kilometraje Inicial',
                isNumeric: true,
              ),
            if (esVueltaDeRegreso)
              CustomTextField(
                controller: _boletosController,
                label: 'Boletos Vendidos',
                isNumeric: true,
              ),
            if (esNuevaVuelta)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: const Text(
                  'Hora de salida registrada automáticamente.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Registrar Vuelta',
              icon: Icons.check,
              onPressed: _registrarVuelta,
            ),
          ],
        ),
      ),
    );
  }
}
