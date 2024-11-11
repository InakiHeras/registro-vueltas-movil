import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/pages/actualizar_vuelta_screen.dart';
import 'package:flutter_registro/screens/pages/registrar_vuelta_dialog.dart';
import 'package:flutter_registro/screens/providers/auth_provider.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:flutter_registro/screens/providers/vueltas_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/confirmation_dialog.dart';
import '../widgets/loading_indicator.dart';

class DetalleRegistroScreen extends StatefulWidget {
  final Map<String, dynamic> turno;
  final VoidCallback onCloseTurn;

  const DetalleRegistroScreen(
      {Key? key, required this.turno, required this.onCloseTurn})
      : super(key: key);

  @override
  _DetalleRegistroScreenState createState() => _DetalleRegistroScreenState();
}

class _DetalleRegistroScreenState extends State<DetalleRegistroScreen> {
  List<Map<String, dynamic>> vueltas = [];
  List<Map<String, dynamic>> motivosPerdida = [];
  Map<String, dynamic>? motivoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // Cargar vueltas y motivos de vuelta perdida
  void _cargarDatos() {
    _cargarVueltas();
    _cargarMotivosPerdida();
  }

  Future<void> _cargarVueltas() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    final vueltasList = await vueltasProvider.listarVueltas(
      context,
      widget.turno['IdTurnoOperador'],
    );
    setState(() => vueltas = vueltasList);
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
            ? const LoadingIndicator()
            : SizedBox(
                width: double.maxFinite, // Set width constraint
                height: 300, // Set a fixed height or any height constraint
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

  void _marcarVueltaPerdida(int idMotivo) async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);

    if (widget.turno['IdTurnoOperador'] != null) {
      final now = DateTime.now();
      final success = await vueltasProvider.registrarVuelta(
        context: context,
        idTurnoOperador: widget.turno['IdTurnoOperador'],
        idMotivoPerdida: idMotivo,
        horaSalida:
            "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}",
        estado: 'Perdida',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(success
                ? 'Vuelta marcada como perdida exitosamente'
                : 'Error al marcar la vuelta como perdida')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener el turno del operador')));
    }
  }

  void _mostrarDetallesVueltaPerdida(Map<String, dynamic> vuelta) async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final motivo = await vueltasProvider.obtenerMotivoPerdida(
        context, vuelta['id_vuelta_perdida']);
    if (motivo != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Detalles de Vuelta Perdida'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Clave: ${motivo['clave']}'),
              Text('Motivo: ${motivo['motivo']}'),
              Text('Responsable: ${motivo['responsable']}'),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cerrar')),
          ],
        ),
      );
    }
  }

  void _mostrarDialogoConfirmacionVueltaPerdida(int idMotivo) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Confirmación',
        content: '¿Estás seguro de que deseas marcar esta vuelta como perdida?',
        onConfirm: () {
          Navigator.pop(context);
          _marcarVueltaPerdida(idMotivo);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _mostrarDialogoConfirmacionCerrarTurno() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    final int? idTurnoOperador = widget.turno['IdTurnoOperador'];

    if (idTurnoOperador != null) {
      // Verifica que no haya vueltas en curso
      final hayVueltaEnCurso =
          await vueltasProvider.vueltaEnCurso(idTurnoOperador, context);
      if (hayVueltaEnCurso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No se puede cerrar el turno. Hay una vuelta en curso.')),
        );
        return;
      }

      // Última vuelta registrada
      final ultimaVueltaId =
          await vueltasProvider.obtenerUltimoIdVuelta(idTurnoOperador, context);

      if (ultimaVueltaId != null) {
        final ultimaVuelta = vueltas.firstWhere(
            (v) => v['IdVuelta'] == ultimaVueltaId,
            orElse: () => <String, dynamic>{});

        if (ultimaVuelta.isNotEmpty) {
          final horaLlegadaActual = ultimaVuelta['HoraLlegada'];
          final boletosVendidosActual = ultimaVuelta['BoletosVendidos'];

          showDialog(
            context: context,
            builder: (BuildContext context) {
              int? kilometrajeFinal;

              return AlertDialog(
                title: Text('Cierre de Turno - Kilometraje Final'),
                content: TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Kilometraje Final'),
                  onChanged: (value) {
                    kilometrajeFinal = int.tryParse(value);
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (kilometrajeFinal != null) {
                        // Navigator.pop(context);

                        // Actualiza la última vuelta con el kilometraje final
                        final success = await vueltasProvider.actualizarVuelta(
                          idVuelta: ultimaVueltaId,
                          idTurnoOperador: idTurnoOperador,
                          kilometrajeFinal: kilometrajeFinal,
                          estado: 'Completada',
                          context: context,
                        );

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Turno cerrado con éxito. Kilometraje final registrado.')),
                          );
                          await turnProvider.cerrarTurnoOperador(
                            ScaffoldMessenger.of(context),
                            widget.turno,
                            token,
                          );
                          Navigator.pop(context);
                          widget.onCloseTurn();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Error al actualizar la última vuelta.')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Por favor, ingresa un kilometraje final válido.')),
                        );
                      }
                    },
                    child: Text('Confirmar'),
                  ),
                ],
              );
            },
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('No se encontró la última vuelta para actualizar.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('No hay vueltas registradas para cerrar el turno.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener el turno del operador')),
      );
    }
  }

  void _mostrarFormularioActualizacionVuelta(
      Map<String, dynamic> vuelta) async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    final int? idTurnoOperador = widget.turno['IdTurnoOperador'];

    if (idTurnoOperador != null) {
      final vueltasRegistradas =
          await vueltasProvider.listarVueltas(context, idTurnoOperador);
      final esPrimeraVuelta = vueltasRegistradas.isEmpty ||
          vueltasRegistradas.first['IdVuelta'] == vuelta['IdVuelta'];

      if (vuelta['Estado'] == 'Perdida') {
        _mostrarDetallesVueltaPerdida(vuelta);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ActualizarVueltaScreen(
              vuelta: vuelta,
              esPrimeraVuelta: esPrimeraVuelta,
            ),
          ),
        );
      }
    }
  }

  // Método para abrir el formulario de vuelta manual
  void _mostrarFormularioVueltaManual() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RegistrarVueltaDialog(
          idTurnoOperador: widget.turno['IdTurnoOperador'],
          onVueltaRegistrada: () {
            Navigator.pop(context);
            _cargarDatos(); // Recargar las vueltas después de registrar
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Detalle de Registro'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoText('Operador: ${widget.turno['Operador']}',
                fontSize: 20, fontWeight: FontWeight.bold),
            _buildInfoText('Unidad: ${widget.turno['ClaveOperador']}'),
            _buildInfoText('Ruta: ${widget.turno['ruta']}'),
            _buildInfoText('Zona: ${widget.turno['Zona']}'),
            _buildInfoText('Turno: ${widget.turno['Turno']}'),
            _buildInfoText('Estatus: ${widget.turno['Estatus']}'),
            const SizedBox(height: 20),
            Text('Vueltas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: vueltas.isEmpty
                  ? const Center(child: Text('No hay vueltas registradas.'))
                  : ListView.builder(
                      itemCount: vueltas.length,
                      itemBuilder: (context, index) {
                        final vuelta = vueltas[index];
                        return ListTile(
                          title: Text(
                              'Vuelta ${index + 1} - Estado: ${vuelta['Estado']}'),
                          subtitle:
                              Text('Hora de Salida: ${vuelta['HoraSalida']}'),
                          trailing: Icon(Icons.arrow_forward_ios),
                          onTap: () =>
                              _mostrarFormularioActualizacionVuelta(vuelta),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 20),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _mostrarFormularioVueltaManual,
              child: Text('Registrar Vuelta Manualmente'),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _mostrarDialogoConfirmacionCerrarTurno,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cerrar Vueltas',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 10), // Space between buttons
                Expanded(
                  child: ElevatedButton(
                    onPressed: _mostrarDialogoMotivoPerdida,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Vuelta Perdida',
                        style: TextStyle(fontSize: 16, color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoText(String text,
      {double fontSize = 16, FontWeight fontWeight = FontWeight.normal}) {
    return Text(text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight));
  }
}
