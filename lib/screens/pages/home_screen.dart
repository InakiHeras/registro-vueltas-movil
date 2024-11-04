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
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Greeting and logo
            Text(
              'Gestión de turno',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            SizedBox(height: 10),
            Image.asset(
              'assets/images/logo_autocar.jpg',
              height: 100,
            ),
            SizedBox(height: 20),

            // Turno status
            Text(
              turnProvider.turnoAbierto ? 'Turno Abierto' : 'Turno Cerrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: turnProvider.turnoAbierto ? Colors.green : Colors.red,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Dropdown for selecting zone
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
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
              decoration: InputDecoration(
                labelText: 'Seleccionar Zona',
                labelStyle: TextStyle(color: Colors.blue),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            SizedBox(height: 20),

            // Buttons for starting and closing the shift
            ElevatedButton(
              onPressed: turnProvider.turnoAbierto
                  ? null
                  : () => turnProvider.abrirTurno(turnProvider.zona, context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Iniciar Turno',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: turnProvider.turnoAbierto
                  ? () => turnProvider.cerrarTurno(context)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Cerrar Turno',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
