import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/providers/vueltas_provider.dart';
import 'package:flutter_registro/screens/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_estado.dart';

class ActualizarVueltaScreen extends StatefulWidget {
  final Map<String, dynamic> vuelta;
  final bool esPrimeraVuelta;

  const ActualizarVueltaScreen({
    Key? key,
    required this.vuelta,
    required this.esPrimeraVuelta,
  }) : super(key: key);

  @override
  _ActualizarVueltaScreenState createState() => _ActualizarVueltaScreenState();
}

class _ActualizarVueltaScreenState extends State<ActualizarVueltaScreen> {
  final _kilometrajeInicialController = TextEditingController();
  final _horaSalidaController = TextEditingController();
  final _horaLlegadaController = TextEditingController();
  final _boletosVendidosController = TextEditingController();
  String? _estadoSeleccionado;
  bool _isEditable = true;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _kilometrajeInicialController.text =
        widget.vuelta['KilometrajeInicial']?.toString() ?? '';
    _horaSalidaController.text = widget.vuelta['HoraSalida'] ?? '';
    _horaLlegadaController.text = widget.vuelta['HoraLlegada'] ?? '';
    _boletosVendidosController.text =
        widget.vuelta['BoletosVendidos']?.toString() ?? '';
    _estadoSeleccionado = widget.vuelta['Estado'];
    _isEditable = !['Completada', 'Perdida'].contains(_estadoSeleccionado);
  }

  Future<void> _actualizarVuelta() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);

    bool success = await vueltasProvider.actualizarVuelta(
      idVuelta: widget.vuelta['IdVuelta'],
      idTurnoOperador: widget.vuelta['IdTurnoOperador'],
      kilometrajeInicial: int.tryParse(_kilometrajeInicialController.text),
      horaSalida: _horaSalidaController.text,
      horaLlegada: _horaLlegadaController.text,
      boletosVendidos: int.tryParse(_boletosVendidosController.text) ?? 0,
      estado: _estadoSeleccionado ?? 'En curso',
      context: context,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success
              ? 'Vuelta actualizada con éxito'
              : 'Error al actualizar la vuelta')),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Actualizar Vuelta'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (widget.esPrimeraVuelta)
                CustomTextField(
                  controller: _kilometrajeInicialController,
                  label: 'Kilometraje Inicial',
                  isNumeric: true,
                ),
              CustomTextField(
                controller: _horaSalidaController,
                label: 'Hora de Salida (YYYY-MM-DD HH:MM:SS)',
              ),
              CustomTextField(
                controller: _horaLlegadaController,
                label: 'Hora de Llegada (YYYY-MM-DD HH:MM:SS)',
              ),
              CustomTextField(
                controller: _boletosVendidosController,
                label: 'Boletos Vendidos',
                isNumeric: true,
              ),
              DropdownEstado(
                value: _estadoSeleccionado,
                onChanged: (valor) =>
                    setState(() => _estadoSeleccionado = valor),
                isEnabled: _isEditable,
              ),
              SizedBox(height: 20),
              CustomButton(
                onPressed: _actualizarVuelta,
                label: 'Actualizar Vuelta',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
