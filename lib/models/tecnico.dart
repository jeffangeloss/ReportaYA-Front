class TecnicoResponse {
  final int id;
  final String usuario;
  final String nombres;
  final String apellidos;
  final String dni;
  final String telefono;
  final String correo;
  final bool activo;

  TecnicoResponse({
    required this.id,
    required this.usuario,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.telefono,
    required this.correo,
    required this.activo,
  });

  factory TecnicoResponse.fromJson(Map<String, dynamic> json) => TecnicoResponse(
        id: (json['id'] as num?)?.toInt() ?? 0,
        usuario: json['usuario'] as String? ?? '',
        nombres: json['nombres'] as String? ?? '',
        apellidos: json['apellidos'] as String? ?? '',
        dni: json['dni'] as String? ?? '',
        telefono: json['telefono'] as String? ?? '',
        correo: json['correo'] as String? ?? '',
        activo: json['activo'] as bool? ?? true,
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
