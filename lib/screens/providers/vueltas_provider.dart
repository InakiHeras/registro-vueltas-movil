import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class VueltasProvider with ChangeNotifier {
  String apiUrl = 'http://192.168.0.7:8000/api';

  Future<bool> registrarVuelta({
    required BuildContext context,
    required int kilometrajeInicial,
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
    String? horaLlegada,
    int? boletosVendidos,
    required String estado, // 'En curso' o 'Completada'
  }) async {
    final url = Uri.parse('$apiUrl/vueltas/actualizar/$idVuelta');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
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
    } else {
      throw Exception('Error al listar vueltas');
    }
  }

  Future<bool> vueltaEnCurso(int idTurnoOperador, BuildContext context) async {
    try {
      final vueltas = await listarVueltas(context, idTurnoOperador);

      // Filtramos vueltas que estén en curso
      final vueltaActiva =
          vueltas.any((vuelta) => vuelta['estado'] == 'En curso');

      return vueltaActiva;
    } catch (e) {
      print('Error verificando vuelta en curso: $e');
      return false;
    }
  }
}
