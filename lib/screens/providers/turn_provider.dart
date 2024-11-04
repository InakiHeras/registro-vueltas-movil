import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_registro/screens/providers/dotacion_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_provider.dart';
import 'dart:convert';

class TurnProvider with ChangeNotifier {
  bool _loading = false;
  bool _turnoAbierto = false; // Variable para manejar si hay un turno abierto
  Map<int, bool> _turnosOperadores = {}; // Mapa para los turnos por operador
  Map<int, int?> _idTurnoOperadores = {};
  String? _zona; // Variable para almacenar la zona seleccionadaz

  bool get loading => _loading;
  bool get turnoAbierto => _turnoAbierto;
  String? get zona => _zona;

  set zona(String? nuevaZona) {
    if (_zona != nuevaZona) {
      _zona = nuevaZona;
      notifyListeners();
    }
  }

  bool turnoOperadorAbierto(int idOperador) {
    return _turnosOperadores[idOperador] ?? false;
  }

  int? obtenerIdTurnoOperador(int idOperador) {
    return _idTurnoOperadores[idOperador];
  }

  // Turnos del asistente
  // Verificar si hay un turno abierto
  Future<void> verificarTurnoAbierto(BuildContext context) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/turno/verificar');
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

    final url = Uri.parse('${dotenv.env['API_URL']}/turno/abrir');
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

    final url = Uri.parse('${dotenv.env['API_URL']}/turno/cerrar');
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
    final url = Uri.parse('${dotenv.env['API_URL']}/operador/verificar');
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
        _turnosOperadores[int.parse(dotacion.agente)] = data['turno_abierto'];
        _idTurnoOperadores[int.parse(dotacion.agente)] =
            data['turno']?['IdTurnoOperador'];
        //abrirTurnoOperador(context, dotacion);

        if (!_turnosOperadores[int.parse(dotacion.agente)]!) {
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

    final url = Uri.parse('${dotenv.env['API_URL']}/operador/abrir');
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
        _turnosOperadores[int.parse(dotacion.agente)] =
            true; // Marcar el turno como abierto
        _idTurnoOperadores[int.parse(dotacion.agente)] =
            data['turno']['IdTurnoOperador'];

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

  Future<void> cerrarTurnoOperador(ScaffoldMessengerState scaffoldMessenger,
      Dotacion dotacion, String token) async {
    _loading = true;
    notifyListeners();

    final url = Uri.parse('${dotenv.env['API_URL']}/operador/cerrar');
    final idTurnoOperador = obtenerIdTurnoOperador(int.parse(dotacion.agente));

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'TurnoOperador': idTurnoOperador,
          'ClaveOperador': dotacion.agente,
          'Operador': dotacion.nombreAgente,
          'Turno': dotacion.descripcionTurno,
          'Ruta': dotacion.descripcionRuta,
          'Zona': dotacion.descripcionZona,
        }),
      );

      if (response.statusCode == 200) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Turno cerrado con éxito')),
        );

        _turnosOperadores[int.parse(dotacion.agente)] = false;

        Provider.of<DotacionProvider>(scaffoldMessenger.context, listen: false)
            .eliminarDotacion(dotacion.unidadId);
      } else if (response.statusCode == 400) {
        final errorMessage = jsonDecode(response.body)['message'];
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Error al cerrar turno')),
        );
      }
    } catch (error) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Error de red al cerrar turno')),
      );
    }
  }
}
