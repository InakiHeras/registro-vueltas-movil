import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedTurno;
  String? selectedRuta;
  List<String> availableRutas = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TurnProvider>(context, listen: false)
          .verificarTurnoAbierto(context);
    });
  }

  void updateRutas(String zona) {
    setState(() {
      if (zona == 'norte') {
        availableRutas = ['Ruta 1', 'Ruta 17', 'Ruta 5'];
      } else if (zona == 'sur') {
        availableRutas = ['Ruta 44', 'Ruta 54', 'Ruta 45', 'Ruta 6'];
      } else if (zona == 'hotelera') {
        availableRutas = ['Ruta 3', 'Ruta 8', 'Ruta 33', 'Ruta 34', 'Ruta 36'];
      } else {
        availableRutas = [];
      }
      selectedRuta =
          null; // Reiniciar la selección de ruta cuando se cambia la zona
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
                      updateRutas(value!); // Actualizar rutas según la zona
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

            // Dropdown for selecting turno
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: selectedTurno,
              items: const [
                DropdownMenuItem(
                  value: 'AM',
                  child: Text('AM'),
                ),
                DropdownMenuItem(
                  value: 'PM',
                  child: Text('PM'),
                ),
              ],
              onChanged: turnProvider.turnoAbierto
                  ? null
                  : (String? value) {
                      setState(() {
                        selectedTurno = value;
                      });
                    },
              decoration: InputDecoration(
                labelText: 'Seleccionar Turno',
                labelStyle: TextStyle(color: Colors.blue),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            SizedBox(height: 20),

            // Dropdown for selecting ruta
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: selectedRuta,
              items: availableRutas
                  .map((ruta) => DropdownMenuItem(
                        value: ruta,
                        child: Text(ruta),
                      ))
                  .toList(),
              onChanged: turnProvider.turnoAbierto
                  ? null
                  : (String? value) {
                      setState(() {
                        selectedRuta = value;
                      });
                    },
              decoration: InputDecoration(
                labelText: 'Seleccionar Ruta',
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
                  : () {
                      if (turnProvider.zona != null &&
                          selectedTurno != null &&
                          selectedRuta != null) {
                        turnProvider.abrirTurno(turnProvider.zona, context,
                            turno: selectedTurno, ruta: selectedRuta);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Por favor, selecciona una zona, turno y ruta'),
                          ),
                        );
                      }
                    },
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
