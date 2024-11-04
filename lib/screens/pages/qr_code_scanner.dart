import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/pages/registros_screen.dart';
import 'package:flutter_registro/screens/pages/vuelta_form_screen.dart';
import 'package:flutter_registro/screens/providers/dotacion_provider.dart';
import 'package:flutter_registro/screens/providers/turn_provider.dart';
import 'package:flutter_registro/screens/widgets/custom_button.dart';
import 'package:flutter_registro/screens/widgets/message_display.dart';
import 'package:provider/provider.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  String _scanResult = 'No se ha escaneado nada aún.';

  // Method to scan QR code
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

      if (scanResult.rawContent.isNotEmpty) {
        await _procesarEscaneo(scanResult.rawContent);
      }
    } catch (e) {
      setState(() {
        _scanResult = 'Error al escanear código: $e';
      });
    }
  }

  // Process QR content
  Future<void> _procesarEscaneo(String contenido) async {
    try {
      final qrData = jsonDecode(contenido);
      final int unidadId = int.parse(qrData['Unidad']);
      final dotacionProvider =
          Provider.of<DotacionProvider>(context, listen: false);
      final turnProvider = Provider.of<TurnProvider>(context, listen: false);

      Dotacion? dotacion = dotacionProvider.buscarDotacionPorUnidad(unidadId);

      if (dotacion == null) {
        await dotacionProvider.obtenerDotaciones(unidadId);
        dotacion = dotacionProvider.buscarDotacionPorUnidad(unidadId);
      }

      if (dotacion != null) {
        await _verificarYRegistrarTurno(
            dotacion, dotacionProvider, turnProvider);
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

  Future<void> _verificarYRegistrarTurno(Dotacion dotacion,
      DotacionProvider dotacionProvider, TurnProvider turnProvider) async {
    await turnProvider.verificarOAbrirTurnoOperador(context, dotacion);

    bool existe = dotacionProvider.dotaciones.any(
      (d) => d.dotacionId == dotacion.dotacionId,
    );

    if (!existe) {
      dotacionProvider.agregarOActualizarDotacion(dotacion);
    } else {
      setState(() {
        _scanResult = 'Esta dotación ya está registrada.';
      });
    }

    final screen = turnProvider.turnoOperadorAbierto(int.parse(dotacion.agente))
        ? VueltaFormScreen(dotacion: dotacion)
        : RegistrosScreen();

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Escáner de QR'),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Display scan result message
            MessageDisplay(message: _scanResult),
            SizedBox(height: 20),
            // Button to scan QR code
            CustomButton(
              label: 'Escanear código QR unidad',
              icon: Icons.qr_code_scanner,
              onPressed: scanQRCode,
              color: Colors.grey, // Optional: Customize color if needed
            ),
          ],
        ),
      ),
    );
  }
}
