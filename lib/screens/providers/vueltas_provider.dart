import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_registro/screens/providers/auth_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VueltasProvider with ChangeNotifier {
  Future<bool> registrarVuelta({
    required BuildContext context,
    int? idMotivoPerdida,
    int? kilometrajeInicial,
    required String horaSalida,
    int? kilometrajeFinal,
    String? horaLlegada,
    int? boletosVendidos,
    required String estado,
    required int idTurnoOperador,
  }) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/vueltas/registrar');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode({
        'id_vuelta_perdida': idMotivoPerdida,
        'kilometraje_inicial': kilometrajeInicial,
        'hora_salida': horaSalida,
        'kilometraje_final': kilometrajeFinal,
        'hora_llegada': horaLlegada,
        'boletos_vendidos': boletosVendidos,
        'id_turno_operador': idTurnoOperador,
        'estado': estado,
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
    required int idTurnoOperador,
    int? kilometrajeInicial,
    int? kilometrajeFinal,
    String? horaSalida,
    String? horaLlegada,
    int? boletosVendidos,
    int? idMotivoPerdida,
    required String estado,
    required BuildContext context, // 'En curso' o 'Completada'
  }) async {
    if (estado == 'En curso') {
      final existeVueltaEnCurso =
          await _hayOtraVueltaEnCurso(idVuelta, idTurnoOperador, context);

      if (existeVueltaEnCurso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No se puede cambiar el estado a "En curso" porque ya hay otra vuelta en curso')),
        );
        return false; // No realizar la actualización
      }
    }

    final url =
        Uri.parse('${dotenv.env['API_URL']}/vueltas/actualizar/$idVuelta');
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
        'motivo_perdida': idMotivoPerdida,
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
    final url = Uri.parse('${dotenv.env['API_URL']}/vueltas/$idTurnoOperador');
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

  // Verificar si hay alguna vuelta registrada para el turno
  Future<bool> hayVueltaRegistrada(
      int idTurnoOperador, BuildContext context) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/vueltas/$idTurnoOperador');
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
    final url =
        Uri.parse('${dotenv.env['API_URL']}/vueltas/ultima/$idTurnoOperador');
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

  Future<bool> _hayOtraVueltaEnCurso(
      int idVueltaActual, int idTurnoOperador, BuildContext context) async {
    final url =
        Uri.parse('${dotenv.env['API_URL']}/vueltas/en-curso/$idTurnoOperador');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final vueltas = jsonDecode(response.body)['vueltas'];
      return vueltas.any((vuelta) =>
          vuelta['Estado'] == 'En curso' &&
          vuelta['IdVuelta'] != idVueltaActual);
    } else {
      throw Exception('Error al verificar vueltas en curso');
    }
  }

  // Método para listar motivos de vuelta perdida
  Future<List<Map<String, dynamic>>> listarMotivosPerdida(
      BuildContext context) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/vueltas/motivos-perdida');
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
      if (data['success']) {
        return (data['motivos'] as List)
            .map((motivo) => {
                  'id': motivo['id'],
                  'clave': motivo['clave'],
                  'motivo': motivo['motivo'],
                })
            .toList();
      } else {
        throw Exception('Error al listar motivos de vuelta perdida');
      }
    } else {
      throw Exception(
          'Error en el servidor al obtener motivos de vuelta perdida');
    }
  }

  Future<Map<String, dynamic>?> obtenerMotivoPerdida(
      BuildContext context, int idMotivoPerdida) async {
    final url =
        Uri.parse('${dotenv.env['API_URL']}/vueltas_perdidas/$idMotivoPerdida');
    final token = Provider.of<AuthProvider>(context, listen: false).token;

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['motivo'];
    } else {
      print('Error al obtener motivo de pérdida: ${response.statusCode}');
      return null;
    }
  }
}
