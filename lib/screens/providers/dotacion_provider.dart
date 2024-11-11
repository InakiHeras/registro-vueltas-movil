import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:collection/collection.dart';

class DotacionProvider with ChangeNotifier {
  List<Dotacion> _dotaciones = [];
  String? _token;

  List<Dotacion> get dotaciones => _dotaciones;

  // Agregar una nueva dotación o actualizar la unidad si ya existe
  void agregarOActualizarDotacion(Dotacion nuevaDotacion) {
    // Buscar si el operador ya tiene una dotación activa
    final dotacionExistente = _dotaciones.firstWhereOrNull(
      (dotacion) => dotacion.agente == nuevaDotacion.agente,
    );

    if (dotacionExistente != null) {
      // Actualizar la unidad
      dotacionExistente.unidadId = nuevaDotacion.unidadId;
      dotacionExistente.descripcionUnidad = nuevaDotacion.descripcionUnidad;
    } else {
      // Agregar nueva dotación
      _dotaciones.add(nuevaDotacion);
    }
    notifyListeners();
  }

  // Limpiar todas las dotaciones
  void limpiarDotaciones() {
    _dotaciones.clear();
    notifyListeners();
  }

  void eliminarDotacion(String operador) {
    _dotaciones.removeWhere((dotacion) => dotacion.nombreAgente == operador);
    notifyListeners();
  }

  // Método para obtener el token
  Future<void> generarToken() async {
    final url = Uri.parse('${dotenv.env['AUTOCAR_API']}/GenerarToken');
    final body = jsonEncode({
      "Usuario": "${dotenv.env['AUTOCAR_USER']}",
      "Contrasena": "${dotenv.env['AUTOCAR_PASS']}",
      "ClavePublica": "${dotenv.env['AUTOCAR_CLAVE']}"
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['Data']['Token'];
      } else {
        throw Exception('Error al obtener el token');
      }
    } catch (e) {
      print("Error en generarToken: $e");
    }
  }

  // Método para obtener las dotaciones desde la API
  Future<void> obtenerDotaciones(int unidadId) async {
    // Verificar si ya tenemos el token, si no, obtenerlo
    if (_token == null) await generarToken();

    final url = Uri.parse(
        '${dotenv.env['AUTOCAR_API']}/Autocar/Operacion/Dotacion/Tablero');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token'
      },
      body: jsonEncode({
        "filtro": {
          "Eq": {"Estatus": "TRANSITO", "UnidadId": unidadId},
          "Between": {
            "Campo": "FechaLabora",
            "Inicio": "20241001",
            "Fin": "20241101",
            "Tipo": "DATE"
          }
        },
        "paginacion": {"Pagina": 0, "Paginar": true, "Cantidad": "10"}
      }),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data']['Data'];
      _dotaciones = data.map((json) => Dotacion.fromJson(json)).toList();
      notifyListeners();
    } else {
      throw Exception('Error al obtener las dotaciones');
    }
  }

  Dotacion? buscarDotacionPorUnidad(int unidadId) {
    try {
      return _dotaciones.firstWhere(
        (dotacion) => dotacion.unidadId == unidadId,
      );
    } catch (e) {
      // Si no se encuentra ninguna dotación, retornar null
      return null;
    }
  }
}
