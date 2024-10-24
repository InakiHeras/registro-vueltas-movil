import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/providers/vueltas_provider.dart';
import 'package:provider/provider.dart';

class VueltaFormScreen extends StatefulWidget {
  final int idTurnoOperador;
  final bool isNuevaVuelta;
  final bool? kilometrajeInicial;

  VueltaFormScreen(
      {required this.idTurnoOperador,
      required this.isNuevaVuelta,
      this.kilometrajeInicial});

  @override
  State<VueltaFormScreen> createState() => _VueltaFormScreenState();
}

class _VueltaFormScreenState extends State<VueltaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _kilometrajeInicialController =
      TextEditingController();
  final TextEditingController _kilometrajeFinalController =
      TextEditingController();
  final TextEditingController _horaSalidaController = TextEditingController();
  final TextEditingController _horaLlegadaController = TextEditingController();
  final TextEditingController _boletosVendidosController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    final vueltasProvider = Provider.of<VueltasProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar vuelta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (widget.isNuevaVuelta && widget.kilometrajeInicial!)
                TextFormField(
                  controller: _kilometrajeInicialController,
                  decoration: InputDecoration(labelText: 'Kilometraje Inicial'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'El kilometraje inicial es obligatorio.';
                    }
                    return null;
                  },
                ),
              TextFormField(
                controller: _horaSalidaController,
                decoration: InputDecoration(labelText: 'Hora de Salida'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'La hora de salida es obligatoria';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _kilometrajeFinalController,
                decoration: InputDecoration(labelText: 'Kilometraje Final'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _horaLlegadaController,
                decoration: InputDecoration(labelText: 'Hora de Llegada'),
                keyboardType: TextInputType.datetime,
              ),
              TextFormField(
                controller: _boletosVendidosController,
                decoration: InputDecoration(labelText: 'Boletos Vendidos'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    vueltasProvider.registrarVuelta(
                      context: context,
                      kilometrajeInicial: widget.isNuevaVuelta
                          ? int.parse(_kilometrajeInicialController.text)
                          : 0,
                      horaSalida: _horaSalidaController.text,
                      kilometrajeFinal:
                          _kilometrajeFinalController.text.isNotEmpty
                              ? int.parse(_kilometrajeFinalController.text)
                              : null,
                      horaLlegada: _horaLlegadaController.text,
                      boletosVendidos:
                          _boletosVendidosController.text.isNotEmpty
                              ? int.parse(_boletosVendidosController.text)
                              : null,
                      idTurnoOperador: widget.idTurnoOperador,
                    );
                  }
                },
                child: Text('Registrar Vuelta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
