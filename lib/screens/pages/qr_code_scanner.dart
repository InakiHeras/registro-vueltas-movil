import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/pages/registros_screen.dart';
import 'package:flutter_registro/screens/pages/vuelta_form_screen.dart';
import 'package:flutter_registro/screens/providers/dotacion_provider.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String _scanResult = 'No se ha escaneado nada aún.';

  // Método para escanear código QR
  Future<void> scanQRCode() async {
    final turnProvider = Provider.of<TurnProvider>(context, listen: false);

    if (!turnProvider.turnoAbierto) {
      setState(() {
        _scanResult =
            'No puedes escanear un código QR si no has abierto un turno.';
      });
      return;
    }

    try {
      var scanResult = await BarcodeScanner.scan();
      if (!mounted) return;

      setState(() {
        _scanResult = scanResult.rawContent.isNotEmpty
            ? 'Resultado del escaneo: ${scanResult.rawContent}'
            : 'No se encontró ningún código.';
      });
      // Procesar el código escaneado
      if (scanResult.rawContent.isNotEmpty) {
        _procesarEscaneo(scanResult.rawContent);
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Error al escanear código: $e';
      });
    }
  }

  // Procesar el contenido del QR
  void _procesarEscaneo(String contenido) async {
    try {
      // Decodificar el json del contenido del QR
      Map<String, dynamic> qrData = jsonDecode(contenido);

      // Extraer la unidad del json
      int unidadId = int.parse(qrData['Unidad']);

      // Verificar la dotación de la unidad
      final dotacionProvider =
          Provider.of<DotacionProvider>(context, listen: false);
      final turnProvider = Provider.of<TurnProvider>(context, listen: false);

      Dotacion? dotacion = dotacionProvider.buscarDotacionPorUnidad(unidadId);

      if (dotacion != null) {
        // Si hay una dotación activa, verificar el turno del operador
        await turnProvider.verificarOAbrirTurnoOperador(context, dotacion);

        bool existe = dotacionProvider.dotaciones.any(
          (d) => d.dotacionId == dotacion.dotacionId,
        );

        if (!existe) {
          // Si la dotación no está registrada, agregarla
          dotacionProvider.agregarDotacion(dotacion);
        } else {
          setState(() {
            _scanResult = 'Está dotación ya está registrada.';
          });
        }

        if (turnProvider.turnoOperadorAbierto(int.parse(dotacion.agente))) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VueltaFormScreen(dotacion: dotacion),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegistrosScreen()),
          );
        }
      } else {
        setState(() {
          _scanResult = 'No hay dotación activa para la unidad $unidadId.';
        });
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Formato de QR inválido: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escáner de QR'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Texto para mostrar el resultado del escaneo
            Text(
              _scanResult,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Botón para escanear código QR
            ElevatedButton.icon(
              onPressed: scanQRCode,
              icon: Icon(Icons.qr_code_scanner),
              label: Text('Escanear Código QR'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
