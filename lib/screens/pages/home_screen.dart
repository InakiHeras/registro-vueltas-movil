import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      Provider.of<TurnProvider>(context, listen: false)
          .verificarTurnoAbierto(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final turnProvider = Provider.of<TurnProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Turno'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indicador del estado del turno
            Text(
              turnProvider.turnoAbierto ? 'Turno Abierto' : 'Turno Cerrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: turnProvider.turnoAbierto ? Colors.green : Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            // Menú desplegable para seleccionar zona
            DropdownButtonFormField<String>(
              value: turnProvider.zona,
              items: const [
                DropdownMenuItem(
                  value: 'norte',
                  child: Text('Norte'),
                ),
                DropdownMenuItem(
                  value: 'sur',
                  child: Text('Sur'),
                ),
                DropdownMenuItem(
                  value: 'hotelera',
                  child: Text('Hotelera'),
                ),
              ],
              onChanged: turnProvider.turnoAbierto
                  ? null
                  : (String? value) {
                      turnProvider.zona = value;
                    },
              decoration: const InputDecoration(
                labelText: 'Seleccionar Zona',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            // Botón para abrir/cerrar turno
            ElevatedButton(
              onPressed: turnProvider.turnoAbierto
                  ? null
                  : () => turnProvider.abrirTurno(
                        turnProvider.zona,
                        context,
                      ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Iniciar turno',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 20,
            ),

            // Botón para cerrar turno
            ElevatedButton(
              onPressed: turnProvider.turnoAbierto
                  ? () => turnProvider.cerrarTurno(context)
                  : null,
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
