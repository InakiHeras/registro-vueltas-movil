class Dotacion {
  final int dotacionId;
  final String agente;
  final String nombreAgente;
  int unidadId;
  String descripcionUnidad;
  final String descripcionRuta;
  final String descripcionZona;
  final String descripcionTurno;
  final String estatus;

  Dotacion({
    required this.dotacionId,
    required this.agente,
    required this.nombreAgente,
    required this.unidadId,
    required this.descripcionUnidad,
    required this.descripcionRuta,
    required this.descripcionZona,
    required this.descripcionTurno,
    required this.estatus,
  });

  factory Dotacion.fromJson(Map<String, dynamic> json) {
    return Dotacion(
      dotacionId: json['DotacionId'],
      agente: json['Agente'],
      nombreAgente: json['NombreAgente'],
      unidadId: json['UnidadId'],
      descripcionUnidad: json['DescripcionUnidad'],
      descripcionRuta: json['DescripcionRuta'],
      descripcionZona: json['DescripcionZona'],
      descripcionTurno: json['DescripcionTurno'],
      estatus: json['Estatus'],
    );
  }
}
