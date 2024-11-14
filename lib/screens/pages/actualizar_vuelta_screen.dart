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

  List<Map<String, dynamic>> motivosPerdida = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
    _cargarMotivosPerdida();
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

  Future<void> _cargarMotivosPerdida() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final motivos = await vueltasProvider.listarMotivosPerdida(context);
    setState(() => motivosPerdida = motivos);
  }

  void _mostrarDialogoMotivoPerdida() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Selecciona un Motivo de Vuelta Perdida'),
        content: motivosPerdida.isEmpty
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: motivosPerdida.length,
                  itemBuilder: (context, index) {
                    final motivo = motivosPerdida[index];
                    return ListTile(
                      title: Text('${motivo['clave']} - ${motivo['motivo']}'),
                      onTap: () {
                        Navigator.pop(context);
                        _mostrarDialogoConfirmacionVueltaPerdida(motivo['id']);
                      },
                    );
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoConfirmacionVueltaPerdida(int idMotivo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmación'),
        content: Text(
            '¿Estás seguro de que deseas marcar esta vuelta como perdida? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _marcarVueltaComoPerdida(idMotivo);
            },
            child: Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _marcarVueltaComoPerdida(int idMotivo) async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);

    bool success = await vueltasProvider.actualizarVuelta(
      idVuelta: widget.vuelta['IdVuelta'],
      idTurnoOperador: widget.vuelta['IdTurnoOperador'],
      estado: 'Perdida',
      idMotivoPerdida: idMotivo,
      context: context,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'Vuelta marcada como perdida exitosamente'
            : 'Error al marcar la vuelta como perdida'),
      ),
    );

    if (success) Navigator.pop(context);
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
              const SizedBox(height: 20),
              CustomButton(
                onPressed: _actualizarVuelta,
                label: 'Actualizar Vuelta',
              ),
              const SizedBox(height: 20),
              CustomButton(
                onPressed: _mostrarDialogoMotivoPerdida,
                label: 'Marcar Vuelta como Perdida',
                icon: Icons.warning,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
