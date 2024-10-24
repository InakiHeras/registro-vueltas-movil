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
  //late Future<List<Map<String, dynamic>>> _vueltasFuture;

  @override
  void initState() {
    super.initState();
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);
    //final idTurnoOperador =
    //turnProvider.getIdTurnoOperador(widget.registro.agente);
    //_vueltasFuture = Provider.of<VueltasProvider>(context, listen: false)
    //.listarVueltas(context, idTurnoOperador!);
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
            /*
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _vueltasFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No hay vueltas disponibles'));
                  } else {
                    final vueltas = snapshot.data!;
                    return ListView.builder(
                      itemCount: vueltas.length,
                      itemBuilder: (context, index) {
                        // Customize the item display according to your needs
                        return ListTile(
                          title: Text('Vuelta ${index + 1}'), // Example display
                          // You can access vueltas[index] to get details
                        );
                      },
                    );
                  }
                },
              ),
            ),*/
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
