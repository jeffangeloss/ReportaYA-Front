class TecnicoResponse {
  final int id;
  final String usuario;
  final String nombres;
  final String apellidos;
  final String? email;
  final String? especialidad;

  TecnicoResponse({
    required this.id,
    required this.usuario,
    required this.nombres,
    required this.apellidos,
    this.email,
    this.especialidad,
  });

  // Alineado con backend TecnicoDTO: id, usuario, nombres, apellidos, email, especialidad.
  factory TecnicoResponse.fromJson(Map<String, dynamic> json) => TecnicoResponse(
        id: json['id'] as int,
        usuario: json['usuario'] as String? ?? '',
        nombres: json['nombres'] as String? ?? '',
        apellidos: json['apellidos'] as String? ?? '',
        email: json['email'] as String?,
        especialidad: json['especialidad'] as String?,
      );

  String get nombreCompleto => '$nombres $apellidos';
}

class FotoRequest {
  final String tipo;
  final String descripcion;
  final String archivoBase64;

  FotoRequest({
    required this.tipo,
    required this.descripcion,
    required this.archivoBase64,
  });

  Map<String, dynamic> toJson() => {
        'tipo': tipo,
        'descripcion': descripcion,
        'archivoBase64': archivoBase64,
      };
}

class CompletarReporteRequest {
  final String comentarioResolucion;
  final List<FotoRequest> fotos;

  CompletarReporteRequest({
    required this.comentarioResolucion,
    required this.fotos,
  });

  Map<String, dynamic> toJson() => {
        'comentarioResolucion': comentarioResolucion,
        'fotos': fotos.map((f) => f.toJson()).toList(),
      };
}

class CompletarReporteResponse {
  final String mensaje;
  final int fotosAdjuntadas;
  final String estadoFinal;
  final String proximoPaso;

  CompletarReporteResponse({
    required this.mensaje,
    required this.fotosAdjuntadas,
    required this.estadoFinal,
    required this.proximoPaso,
  });

  factory CompletarReporteResponse.fromJson(Map<String, dynamic> json) =>
      CompletarReporteResponse(
        mensaje: json['mensaje'] as String? ?? '',
        fotosAdjuntadas: json['fotosAdjuntadas'] as int? ?? 0,
        estadoFinal: json['estadoFinal'] as String? ?? '',
        proximoPaso: json['proximoPaso'] as String? ?? '',
      );
}
