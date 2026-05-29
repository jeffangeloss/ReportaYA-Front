import 'ubicacion.dart';

class FotoAuditoria {
  final int? id;
  final String tipo;
  final String descripcion;
  final String? archivoBase64;
  final String? url;
  final String? fechaCarga;

  FotoAuditoria({
    this.id,
    required this.tipo,
    required this.descripcion,
    this.archivoBase64,
    this.url,
    this.fechaCarga,
  });

  factory FotoAuditoria.fromJson(Map<String, dynamic> json) => FotoAuditoria(
        id: json['id'] as int?,
        tipo: json['tipo'] as String? ?? 'INICIAL',
        descripcion: json['descripcion'] as String? ?? '',
        archivoBase64: json['archivoBase64'] as String?,
        url: json['url'] as String?,
        fechaCarga: json['fechaCarga'] as String?,
      );
}

class ReporteAuditoria {
  final int id;
  final String titulo;
  final String descripcion;
  final Ubicacion ubicacion;
  final String estado;
  final String prioridad;
  final int tecnicoId;
  final String tecnicoNombre;
  final String comentarioResolucion;
  final List<FotoAuditoria> fotos;
  final int contadorRechazos;
  final String fechaCreacion;
  final String? fechaAsignacion;
  final String? fechaCompletacion;

  ReporteAuditoria({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.ubicacion,
    required this.estado,
    required this.prioridad,
    required this.tecnicoId,
    required this.tecnicoNombre,
    required this.comentarioResolucion,
    required this.fotos,
    required this.contadorRechazos,
    required this.fechaCreacion,
    this.fechaAsignacion,
    this.fechaCompletacion,
  });

  factory ReporteAuditoria.fromJson(Map<String, dynamic> json) {
    final fotosList = (json['fotos'] as List<dynamic>?) ?? [];
    return ReporteAuditoria(
      id: json['id'] as int,
      titulo: json['titulo'] as String? ?? '',
      descripcion: json['descripcion'] as String? ?? '',
      ubicacion: Ubicacion.fromJson(json['ubicacion'] as Map<String, dynamic>),
      estado: json['estado'] as String? ?? '',
      prioridad: json['prioridad'] as String? ?? 'MEDIA',
      tecnicoId: json['tecnicoId'] as int? ?? 0,
      tecnicoNombre: json['tecnicoNombre'] as String? ?? 'No asignado',
      comentarioResolucion: json['comentarioResolucion'] as String? ?? '',
      fotos: fotosList
          .map((e) => FotoAuditoria.fromJson(e as Map<String, dynamic>))
          .toList(),
      contadorRechazos: json['contadorRechazos'] as int? ?? 0,
      fechaCreacion: json['fechaCreacion'] as String? ?? '',
      fechaAsignacion: json['fechaAsignacion'] as String?,
      fechaCompletacion: json['fechaCompletacion'] as String?,
    );
  }
}

class RespuestaAuditoriaResponse {
  final bool exito;
  final String mensaje;
  final int reporteId;
  final String nuevoEstado;

  RespuestaAuditoriaResponse({
    required this.exito,
    required this.mensaje,
    required this.reporteId,
    required this.nuevoEstado,
  });

  factory RespuestaAuditoriaResponse.fromJson(Map<String, dynamic> json) =>
      RespuestaAuditoriaResponse(
        exito: json['exito'] as bool? ?? true,
        mensaje: json['mensaje'] as String? ?? '',
        reporteId: json['reporteId'] as int? ?? 0,
        nuevoEstado: json['nuevoEstado'] as String? ?? '',
      );
}
