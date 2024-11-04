import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/pages/detalle_registro_screen.dart';
import 'package:flutter_registro/screens/providers/dotacion_provider.dart';
import 'package:provider/provider.dart';

class RegistrosScreen extends StatefulWidget {
  final bool refresh;

  const RegistrosScreen({Key? key, this.refresh = false}) : super(key: key);

  @override
  State<RegistrosScreen> createState() => _RegistrosScreenState();
}

class _RegistrosScreenState extends State<RegistrosScreen> {
  List<Dotacion> registros = [];

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
    registros = dotacionProvider.dotaciones;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registros de Unidades')),
      body: registros.isEmpty
          ? Center(child: Text('No hay registros por el momento.'))
          : ListView.builder(
              itemCount: registros.length,
              itemBuilder: (context, index) {
                final registro = registros[index];
                return ListTile(
                  title: Text('Operador: ${registro.nombreAgente}'),
                  subtitle: Text(
                      'Ruta: ${registro.descripcionRuta}\nZona: ${registro.descripcionZona}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetalleRegistroScreen(
                          registro: registro,
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
    );
  }
}
