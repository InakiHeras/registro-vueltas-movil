import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class VueltasProvider with ChangeNotifier {
  String apiUrl = 'http://10.20.0.50:8000/api';

  Future<bool> registrarVuelta({
    required BuildContext context,
    int? kilometrajeInicial,
    required String horaSalida,
    int? kilometrajeFinal,
    String? horaLlegada,
    int? boletosVendidos,
    required int idTurnoOperador,
  }) async {
    final url = Uri.parse('$apiUrl/vueltas/registrar');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'kilometraje_inicial': kilometrajeInicial,
        'hora_salida': horaSalida,
        'kilometraje_final': kilometrajeFinal,
        'hora_llegada': horaLlegada,
        'boletos_vendidos': boletosVendidos,
        'id_turno_operador': idTurnoOperador,
      }),
    );

    if (response.statusCode == 201) {
      // Registro exitoso
      return true;
    } else {
      // Error al registrar vuelta
      return false;
    }
  }

  Future<bool> actualizarVuelta({
    required int idVuelta,
    int? kilometrajeFinal,
    required String horaLlegada,
    required int boletosVendidos,
    required String estado,
    required BuildContext context, // 'En curso' o 'Completada'
  }) async {
    final url = Uri.parse('$apiUrl/vueltas/actualizar/$idVuelta');
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'kilometraje_final': kilometrajeFinal,
        'hora_llegada': horaLlegada,
        'boletos_vendidos': boletosVendidos,
        'estado': estado,
      }),
    );

    if (response.statusCode == 200) {
      // Actualización exitosa
      return true;
    } else {
      // Error al actualizar vuelta
      return false;
    }
  }

  // Método para listar las vueltas de un operador
  Future<List<Map<String, dynamic>>> listarVueltas(
      BuildContext context, int idTurnoOperador) async {
    final url = Uri.parse('$apiUrl/vueltas/$idTurnoOperador');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final List vueltas = jsonDecode(response.body)['vueltas'];
      return vueltas.cast<Map<String, dynamic>>();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      throw Exception('Error al listar vueltas');
    }
  }

  Future<bool> vueltaEnCurso(int idTurnoOperador, BuildContext context) async {
    try {
      final vueltas = await listarVueltas(context, idTurnoOperador);

      // Filtramos vueltas que estén en curso
      final vueltaActiva =
          vueltas.any((vuelta) => vuelta['Estado'] == 'En curso');

      return vueltaActiva;
    } catch (e) {
      print('Error verificando vuelta en curso: $e');
      return false;
    }
  }

  // Determinar si la vuelta actual es la última para este operador
  /*
  Future<bool> esUltimaVuelta(int idTurnoOperador) async {
    // Llamada al endpoint para verificar si es la última vuelta del día
    final url = Uri.parse('$apiUrl/vueltas/ultima/$idTurnoOperador');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['es_ultima'];
    } else {
      throw Exception('Error al verificar si es la última vuelta');
    }
  }*/

  // Verificar si hay alguna vuelta registrada para el turno
  Future<bool> hayVueltaRegistrada(
      int idTurnoOperador, BuildContext context) async {
    final url = Uri.parse('$apiUrl/vueltas/$idTurnoOperador');
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 404 || response.statusCode == 200) {
      bool hayVueltas = jsonDecode(response.body)['success'];
      return hayVueltas; // Retorna true si hay vueltas registradas
    } else {
      throw Exception('Error al verificar vueltas registradas');
    }
  }

  Future<int?> obtenerUltimoIdVuelta(
      int idTurnoOperador, BuildContext context) async {
    final url = Uri.parse('$apiUrl/vueltas/ultima/$idTurnoOperador');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['idVuelta'];
    } else {
      print('Error fetching last vuelta ID');
      return null;
    }
  }
}
