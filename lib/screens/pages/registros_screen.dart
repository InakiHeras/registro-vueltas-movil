import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/pages/detalle_registro_screen.dart';
import 'package:flutter_registro/screens/providers/dotacion_provider.dart';
import 'package:provider/provider.dart';

class RegistrosScreen extends StatefulWidget {
  const RegistrosScreen({super.key});

  @override
  State<RegistrosScreen> createState() => _RegistrosScreenState();
}

class _RegistrosScreenState extends State<RegistrosScreen> {
  List<Dotacion> registros = [];

  @override
  void initState() {
    super.initState();
    // Si ya hay dotaciones en el provider, las cargamos en la lista
    final dotacionProvider =
        Provider.of<DotacionProvider>(context, listen: false);

    if (dotacionProvider.dotaciones.isNotEmpty) {
      registros = List.from(dotacionProvider.dotaciones);
    }
  }

  // Función para agregar un nuevo registro a la lista
  void agregarRegistro(Dotacion dotacion) {
    setState(() {
      registros.add(dotacion);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Registros de Unidades'),
        ),
        body: registros.isEmpty
            ? Center(
                child: Text('No hay registros por el momento.'),
              )
            : ListView.builder(
                itemCount: registros.length,
                itemBuilder: (context, index) {
                  final registro = registros[index];
                  return ListTile(
                    title: Text('Operador: ${registro.nombreAgente}'),
                    subtitle: Text(
                        'Ruta: ${registro.descripcionRuta}\nZona: ${registro.descripcionZona}'),
                    onTap: () {
                      // Lógica para abrir los detalles del registro
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetalleRegistroScreen(registro: registro),
                        ),
                      );
                    },
                  );
                },
              ));
  }
}
