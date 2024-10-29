import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:flutter_registro/screens/providers/vueltas_provider.dart';
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

  // Determina el tipo de vuelta: primera, nueva, o regreso
  void _determinarEstadoVuelta() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    final int? idTurnoOperador =
        turnProvider.obtenerIdTurnoOperador(int.parse(widget.dotacion.agente));

    if (idTurnoOperador != null) {
      // Verificar si hay alguna vuelta en curso
      bool hayVueltaEnCurso =
          await vueltasProvider.vueltaEnCurso(idTurnoOperador, context);

      // Verificar si existe alguna vuelta registrada para este turno
      bool hayVueltaRegistrada =
          await vueltasProvider.hayVueltaRegistrada(idTurnoOperador, context);

      setState(() {
        esPrimeraVuelta =
            !hayVueltaRegistrada; // Si no hay vueltas registradas, es la primera vuelta
        esVueltaDeRegreso =
            hayVueltaEnCurso; // Es de regreso si ya hay una en curso
        esNuevaVuelta = hayVueltaRegistrada &&
            !hayVueltaEnCurso; // Nueva vuelta solo si hay una vuelta registrada y no hay otra en curso
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: no se pudo obtener el ID del turno del operador')),
      );
    }
  }

  void _registrarVuelta() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final now = DateTime.now();
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    final int? idTurnoOperador =
        turnProvider.obtenerIdTurnoOperador(int.parse(widget.dotacion.agente));

    bool success = false;
    if (esVueltaDeRegreso) {
      // Registrar la vuelta de regreso
      int? idVuelta = await vueltasProvider.obtenerUltimoIdVuelta(
          idTurnoOperador!, context);
      if (idVuelta != null) {
        success = await vueltasProvider.actualizarVuelta(
          context: context,
          idVuelta: idVuelta,
          kilometrajeFinal: int.parse(_kilometrajeController.text),
          horaLlegada:
              "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
          boletosVendidos: int.parse(_boletosController.text),
          estado: 'Completada',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: No se pudo obtener el ID de la vuelta')),
        );
      }
    } else {
      // Registrar una vuelta intermedia o la primera vuelta
      success = await vueltasProvider.registrarVuelta(
        context: context,
        kilometrajeInicial:
            esPrimeraVuelta ? int.parse(_kilometrajeController.text) : null,
        horaSalida:
            "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
        idTurnoOperador: idTurnoOperador!,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success
              ? 'Vuelta registrada con éxito'
              : 'Error al registrar la vuelta')),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro de Vuelta')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (esPrimeraVuelta) ...[
              TextField(
                controller: _kilometrajeController,
                decoration: InputDecoration(labelText: 'Kilometraje Inicial'),
                keyboardType: TextInputType.number,
              ),
            ],
            if (esVueltaDeRegreso) ...[
              TextField(
                controller: _boletosController,
                decoration: InputDecoration(labelText: 'Boletos Vendidos'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _kilometrajeController,
                decoration: InputDecoration(labelText: 'Kilometraje Final'),
                keyboardType: TextInputType.number,
              ),
            ],
            if (esNuevaVuelta) ...[
              // Mensaje para vuelta intermedia
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'Hora de salida registrada automáticamente.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrarVuelta,
              child: Text('Registrar Vuelta'),
            ),
          ],
        ),
      ),
    );
  }
}
