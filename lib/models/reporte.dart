import 'ubicacion.dart';

class ReporteResponse {
  final int id;
  final String titulo;
  final String descripcion;
  final int cuentaId;
  final String? nombreCiudadano;
  final String prioridad;
  final String estado;
  final String? tipoProblema;
  final Ubicacion ubicacion;
  final String fechaCreacion;
  final String fechaActualizacion;

  ReporteResponse({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cuentaId,
    this.nombreCiudadano,
    required this.prioridad,
    required this.estado,
    this.tipoProblema,
    required this.ubicacion,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  factory ReporteResponse.fromJson(Map<String, dynamic> json) {
    return ReporteResponse(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      cuentaId: json['cuentaId'] as int,
      nombreCiudadano: json['nombreCiudadano'] as String?,
      prioridad: json['prioridad'] as String? ?? 'MEDIA',
      estado: json['estado'] as String? ?? 'PENDIENTE',
      tipoProblema: json['tipoProblema'] as String?,
      ubicacion: json['ubicacion'] != null
          ? Ubicacion.fromJson(json['ubicacion'] as Map<String, dynamic>)
          : Ubicacion.unavailable(),
      fechaCreacion: json['fechaCreacion'] as String? ?? '',
      fechaActualizacion: json['fechaActualizacion'] as String? ?? '',
    );
  }

  ReporteResponse copyWith({String? estado, String? prioridad}) {
    return ReporteResponse(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      cuentaId: cuentaId,
      nombreCiudadano: nombreCiudadano,
      prioridad: prioridad ?? this.prioridad,
      estado: estado ?? this.estado,
      tipoProblema: tipoProblema,
      ubicacion: ubicacion,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion,
    );
  }
}

class CrearReporteRequest {
  final String titulo;
  final String descripcion;
  final int cuentaId;
  final CrearUbicacionRequest ubicacion;
  final String? prioridad;
  final String? tipoProblema;

  CrearReporteRequest({
    required this.titulo,
    required this.descripcion,
    required this.cuentaId,
    required this.ubicacion,
    this.prioridad,
    this.tipoProblema,
  });

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'cuentaId': cuentaId,
        'ubicacion': ubicacion.toJson(),
        if (prioridad != null) 'prioridad': prioridad,
        if (tipoProblema != null) 'tipoProblema': tipoProblema,
      };
}

class FiltrosReporte {
  String? estado;
  String? tipoProblema;
  String? prioridad;

  FiltrosReporte({this.estado, this.tipoProblema, this.prioridad});
}

class HistorialEstado {
  final int id;
  final int reporteId;
  final String? estadoAnterior;
  final String estadoNuevo;
  final String fechaCambio;

  HistorialEstado({
    required this.id,
    required this.reporteId,
    this.estadoAnterior,
    required this.estadoNuevo,
    required this.fechaCambio,
  });

  factory HistorialEstado.fromJson(Map<String, dynamic> json) => HistorialEstado(
        id: json['id'] as int,
        reporteId: json['reporteId'] as int,
        estadoAnterior: json['estadoAnterior'] as String?,
        estadoNuevo: json['estadoNuevo'] as String,
        fechaCambio: json['fechaCambio'] as String,
      );
}
