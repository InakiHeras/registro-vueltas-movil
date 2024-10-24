import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/providers/dotacion_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'auth_provider.dart';
import 'dart:convert';

class TurnProvider with ChangeNotifier {
  bool _loading = false;
  bool _turnoAbierto = false; // Variable para manejar si hay un turno abierto
  bool _turnoOperadorAbierto = false;
  String? _zona; // Variable para almacenar la zona seleccionadaz

  bool get loading => _loading;
  bool get turnoAbierto => _turnoAbierto;
  bool get turnoOperadorAbierto => _turnoOperadorAbierto;
  String? get zona => _zona;

  set zona(String? nuevaZona) {
    if (_zona != nuevaZona) {
      _zona = nuevaZona;
      notifyListeners();
    }
  }

  // Turnos del asistente
  // Verificar si hay un turno abierto
  Future<void> verificarTurnoAbierto(BuildContext context) async {
    final url = Uri.parse('http://192.168.0.7:8000/api/turno/verificar');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _turnoAbierto = data['turno_abierto'];

        if (_turnoAbierto) {
          _zona = data['turno']['Zona'];
        } else {
          _zona = null;
        }

        notifyListeners();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al verificar turno')),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de red')),
        );
      }
    }
  }

  Future<void> abrirTurno(String? zona, BuildContext context) async {
    _loading = true;
    notifyListeners();

    final url = Uri.parse('http://192.168.0.7:8000/api/turno/abrir');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    if (zona == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Por favor, selecciona una zona antes de abrir un turno')),
      );
      return;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'zona': zona,
        }),
      );

      if (response.statusCode == 200) {
        _turnoAbierto = true; // Marcar el turno como abierto
        _zona = zona;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno abierto con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al abrir turno')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de red al abrir turno')),
      );
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> cerrarTurno(BuildContext context) async {
    _loading = true;
    notifyListeners();

    final url = Uri.parse('http://192.168.0.7:8000/api/turno/cerrar');
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final dotacionProvider =
        Provider.of<DotacionProvider>(context, listen: false);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        _turnoAbierto = false;
        _zona = null;
        dotacionProvider.limpiarDotaciones();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno cerrado con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cerrar turno')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de red al cerrar turno')),
      );
    }

    _loading = false;
    notifyListeners();
  }

  // Turnos del operador
  Future<void> verificarOAbrirTurnoOperador(
      BuildContext context, Dotacion dotacion) async {
    final url = Uri.parse('http://192.168.0.7:8000/api/operador/verificar');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'ClaveOperador': dotacion.agente,
            'Operador': dotacion.nombreAgente,
            'Turno': dotacion.descripcionTurno,
            'Ruta': dotacion.descripcionRuta,
            'Zona': dotacion.descripcionZona,
          }));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _turnoOperadorAbierto = data['turno_abierto'];
        //abrirTurnoOperador(context, dotacion);

        if (!_turnoOperadorAbierto) {
          abrirTurnoOperador(context, dotacion);
        }

        notifyListeners();
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al verificar turno')),
          );
        }
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error de red')),
        );
      }
    }
  }

  Future<void> abrirTurnoOperador(
      BuildContext context, Dotacion dotacion) async {
    _loading = false;
    notifyListeners();

    final url = Uri.parse('http://192.168.0.7:8000/api/operador/abrir');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'ClaveOperador': dotacion.agente,
            'Operador': dotacion.nombreAgente,
            'Turno': dotacion.descripcionTurno,
            'Ruta': dotacion.descripcionRuta,
            'Zona': dotacion.descripcionZona,
          }));

      if (response.statusCode == 200) {
        _turnoOperadorAbierto = true; // Marcar el turno como abierto
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno abierto con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al abrir turno')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de red al abrir turno')),
      );
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> cerrarTurnoOperador(
      BuildContext context, Dotacion dotacion) async {
    _loading = true;
    notifyListeners();

    final url = Uri.parse('http://192.168.0.7:8000/api/operador/cerrar');
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final dotacionProvider =
        Provider.of<DotacionProvider>(context, listen: false);

    try {
      final response = await http.post(url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
          body: jsonEncode({
            'ClaveOperador': dotacion.agente,
            'Operador': dotacion.nombreAgente,
            'Turno': dotacion.descripcionTurno,
            'Ruta': dotacion.descripcionRuta,
            'Zona': dotacion.descripcionZona,
          }));

      if (response.statusCode == 200) {
        _turnoOperadorAbierto = false;
        // dotacionProvider.limpiarDotaciones();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Turno cerrado con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cerrar turno')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error de red al cerrar turno')),
      );
    }

    _loading = false;
    notifyListeners();
  }
}
