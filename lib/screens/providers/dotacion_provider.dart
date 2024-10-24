import 'package:flutter/material.dart';
import 'package:flutter_registro/models/dotacion.dart';

class DotacionProvider with ChangeNotifier {
  List<Dotacion> _dotaciones = [];

  List<Dotacion> get dotaciones => _dotaciones;

  // Agregar una nueva dotación a la lista
  void agregarDotacion(Dotacion dotacion) {
    _dotaciones.add(dotacion);
    notifyListeners();
  }

  // Limpiar todas las dotaciones
  void limpiarDotaciones() {
    _dotaciones.clear();
    notifyListeners();
  }

  Dotacion? buscarDotacionPorUnidad(int unidadId) {
    List<Dotacion> dotaciones = [
      Dotacion(
          dotacionId: 137,
          agente: '11182',
          nombreAgente: 'PESADO QUINTERO OMAR',
          descripcionUnidad: 'UNIDAD 548',
          descripcionRuta: 'R1 MIGUEL HIDALGO',
          descripcionZona: 'URBANA NORTE',
          descripcionTurno: 'PM',
          estatus: 'TRANSITO'),
      Dotacion(
          dotacionId: 132,
          agente: '12053',
          nombreAgente: 'ORIGEL MIRANDA MARCO ANTONIO',
          descripcionUnidad: 'UNIDAD 808',
          descripcionRuta: 'R36 NICHUPTE-HOTELES',
          descripcionZona: 'HOTELES',
          descripcionTurno: 'PM QUEBRADO',
          estatus: 'TRANSITO'),
      // Agrega las demás dotaciones de tu conjunto de JSONs...
    ];

    try {
      return dotaciones.firstWhere(
        (dotacion) => dotacion.descripcionUnidad.contains(unidadId.toString()),
      );
    } catch (e) {
      // Si no encuentra una dotación, retornar null
      return null;
    }
  }
}
