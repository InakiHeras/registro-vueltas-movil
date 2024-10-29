import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:flutter_registro/screens/providers/vueltas_provider.dart';
import 'package:provider/provider.dart';

class DetalleRegistroScreen extends StatefulWidget {
  final Dotacion registro;
  const DetalleRegistroScreen({super.key, required this.registro});

  @override
  _DetalleRegistroScreenState createState() => _DetalleRegistroScreenState();
}

class _DetalleRegistroScreenState extends State<DetalleRegistroScreen> {
  List<Map<String, dynamic>> vueltas = [];

  @override
  void initState() {
    super.initState();
    _cargarVueltas();
  }

  // Cargar las vueltas del operador
  void _cargarVueltas() async {
    final vueltasProvider =
        Provider.of<VueltasProvider>(context, listen: false);
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    final vueltasList = await vueltasProvider.listarVueltas(
        context,
        turnProvider
            .obtenerIdTurnoOperador(int.parse(widget.registro.agente))!);
    setState(() {
      vueltas = vueltasList;
    });
  }

  // Mostrar detalles de la vuelta
  void _mostrarDetallesVuelta(Map<String, dynamic> vuelta) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Detalles de la Vuelta'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Kilometraje Inicial: ${vuelta['KilometrajeInicial'] ?? 'N/A'}'),
            Text('Hora de Salida: ${vuelta['HoraSalida']}'),
            if (vuelta['KilometrajeFinal'] != null)
              Text('Kilometraje Final: ${vuelta['KilometrajeFinal']}'),
            if (vuelta['HoraLlegada'] != null)
              Text('Hora de Llegada: ${vuelta['HoraLlegada']}'),
            if (vuelta['BoletosVendidos'] != null)
              Text('Boletos Vendidos: ${vuelta['BoletosVendidos']}'),
            Text('Estado: ${vuelta['Estado']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Registro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Operador: ${widget.registro.nombreAgente}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Unidad: ${widget.registro.descripcionUnidad}',
                style: TextStyle(fontSize: 16)),
            Text('Ruta: ${widget.registro.descripcionRuta}',
                style: TextStyle(fontSize: 16)),
            Text('Zona: ${widget.registro.descripcionZona}',
                style: TextStyle(fontSize: 16)),
            Text('Turno: ${widget.registro.descripcionTurno}',
                style: TextStyle(fontSize: 16)),
            Text('Estatus: ${widget.registro.estatus}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            Text('Vueltas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: vueltas.isEmpty
                  ? Center(child: Text('No hay vueltas registradas.'))
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
                          onTap: () => _mostrarDetallesVuelta(vuelta),
                        );
                      },
                    ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Provider.of<TurnProvider>(context, listen: false)
                  .cerrarTurnoOperador(context, widget.registro),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Cerrar turno',
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
      ),
    );
  }
}
