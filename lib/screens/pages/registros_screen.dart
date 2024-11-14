import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/pages/detalle_registro_screen.dart';
import 'package:flutter_registro/screens/providers/dotacion_provider.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:provider/provider.dart';

class RegistrosScreen extends StatefulWidget {
  final bool refresh;

  const RegistrosScreen({Key? key, this.refresh = false}) : super(key: key);

  @override
  State<RegistrosScreen> createState() => _RegistrosScreenState();
}

class _RegistrosScreenState extends State<RegistrosScreen> {
  List<Map<String, dynamic>> registrosConTurno = [];

  @override
  void didUpdateWidget(RegistrosScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if refresh flag is true, then reload data
    if (widget.refresh) {
      _loadData();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dotacionProvider =
        Provider.of<DotacionProvider>(context, listen: false);
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);

    List<Dotacion> registros = dotacionProvider.dotaciones;
    List<Map<String, dynamic>> registrosConTurnoTemp = [];

    for (var registro in registros) {
      final turnoInfo =
          await turnProvider.obtenerTurnoOperador(context, registro.agente);
      if (turnoInfo != null) {
        registrosConTurnoTemp.add(turnoInfo);
      }
    }

    setState(() {
      registrosConTurno = registrosConTurnoTemp;
    });
  }

  void _registrarDotacionManual() {
    final TextEditingController operadorController = TextEditingController();
    final TextEditingController nombreAgenteController =
        TextEditingController();
    final TextEditingController descripcionTurnoController =
        TextEditingController();
    final TextEditingController rutaController = TextEditingController();
    final TextEditingController zonaController = TextEditingController();
    final TextEditingController unidadController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Registrar Dotación Manual'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: operadorController,
                  decoration: InputDecoration(labelText: 'Clave'),
                ),
                TextField(
                  controller: nombreAgenteController,
                  decoration: InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descripcionTurnoController,
                  decoration: InputDecoration(labelText: 'Turno'),
                ),
                TextField(
                  controller: rutaController,
                  decoration: InputDecoration(labelText: 'Ruta'),
                ),
                TextField(
                  controller: zonaController,
                  decoration: InputDecoration(labelText: 'Zona'),
                ),
                TextField(
                  controller: unidadController,
                  decoration: InputDecoration(labelText: 'Unidad ID'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Registrar'),
              onPressed: () async {
                final nuevaDotacion = Dotacion(
                  agente: operadorController.text,
                  nombreAgente: nombreAgenteController.text,
                  descripcionTurno: descripcionTurnoController.text,
                  estatus: 'EN TRANSITO',
                  descripcionRuta: rutaController.text,
                  descripcionZona: zonaController.text,
                  unidadId: int.tryParse(unidadController.text) ?? 0,
                  descripcionUnidad: 'Unidad ${unidadController.text}',
                );

                Provider.of<DotacionProvider>(context, listen: false)
                    .agregarOActualizarDotacion(nuevaDotacion);

                // Llamar a TurnProvider para verificar o abrir turno del operador
                await Provider.of<TurnProvider>(context, listen: false)
                    .verificarOAbrirTurnoOperador(context, nuevaDotacion);

                //Navigator.of(context).pop();
                _loadData(); // Refresh data after registration
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registros de Unidades')),
      body: registrosConTurno.isEmpty
          ? Center(child: Text('No hay registros por el momento.'))
          : ListView.builder(
              itemCount: registrosConTurno.length,
              itemBuilder: (context, index) {
                final turno = registrosConTurno[index];
                return ListTile(
                  title: Text('Operador: ${turno['Operador']}'),
                  subtitle:
                      Text('Ruta: ${turno['ruta']}\nZona: ${turno['Zona']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleRegistroScreen(
                          turno: turno,
                          onCloseTurn: () {
                            // Call navigateToRegistrosScreen when closing turn
                            Navigator.pop(
                                context); // Close DetalleRegistroScreen
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _registrarDotacionManual,
        child: Icon(Icons.add),
        tooltip: 'Agregar Dotación Manual',
      ),
    );
  }
}
