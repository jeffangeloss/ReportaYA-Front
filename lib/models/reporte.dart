import 'enums.dart';
import 'ubicacion.dart';

/// Reporte tal como lo consume la UI. Alineado a los CU: sin prioridad,
/// con tipoProblema, comentarioResolucion y tecnico asignado.
class ReporteResponse {
  final int id;
  final String titulo;
  final String descripcion;
  final int cuentaId;
  final String? nombreCiudadano;
  final String estado;
  final String? tipoProblema;
  final Ubicacion ubicacion;
  final String fechaCreacion;
  final String fechaActualizacion;
  final String? comentarioResolucion;
  final String? fechaCierre;
  final int? tecnicoAsignadoId;
  final String? tecnicoNombre;

  ReporteResponse({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.cuentaId,
    this.nombreCiudadano,
    required this.estado,
    this.tipoProblema,
    required this.ubicacion,
    required this.fechaCreacion,
    required this.fechaActualizacion,
    this.comentarioResolucion,
    this.fechaCierre,
    this.tecnicoAsignadoId,
    this.tecnicoNombre,
  });

  bool get tieneTecnico => tecnicoAsignadoId != null;

  factory ReporteResponse.fromJson(Map<String, dynamic> json) {
    return ReporteResponse(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      cuentaId: json['cuentaId'] as int,
      nombreCiudadano: json['nombreCiudadano'] as String?,
      estado: json['estado'] as String? ?? EstadoReporte.PENDIENTE,
      tipoProblema: json['tipoProblema'] as String?,
      ubicacion: Ubicacion.fromJson(json['ubicacion'] as Map<String, dynamic>),
      fechaCreacion: json['fechaCreacion'] as String? ?? '',
      fechaActualizacion: json['fechaActualizacion'] as String? ?? '',
      comentarioResolucion: json['comentarioResolucion'] as String?,
      fechaCierre: json['fechaCierre'] as String?,
      tecnicoAsignadoId: json['tecnicoAsignadoId'] as int?,
      tecnicoNombre: json['tecnicoNombre'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titulo': titulo,
        'descripcion': descripcion,
        'cuentaId': cuentaId,
        'nombreCiudadano': nombreCiudadano,
        'estado': estado,
        'tipoProblema': tipoProblema,
        'ubicacion': ubicacion.toJson(),
        'fechaCreacion': fechaCreacion,
        'fechaActualizacion': fechaActualizacion,
        'comentarioResolucion': comentarioResolucion,
        'fechaCierre': fechaCierre,
        'tecnicoAsignadoId': tecnicoAsignadoId,
        'tecnicoNombre': tecnicoNombre,
      };

  ReporteResponse copyWith({
    String? estado,
    String? tipoProblema,
    String? comentarioResolucion,
    String? fechaActualizacion,
    String? fechaCierre,
    int? tecnicoAsignadoId,
    String? tecnicoNombre,
  }) {
    return ReporteResponse(
      id: id,
      titulo: titulo,
      descripcion: descripcion,
      cuentaId: cuentaId,
      nombreCiudadano: nombreCiudadano,
      estado: estado ?? this.estado,
      tipoProblema: tipoProblema ?? this.tipoProblema,
      ubicacion: ubicacion,
      fechaCreacion: fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
      comentarioResolucion: comentarioResolucion ?? this.comentarioResolucion,
      fechaCierre: fechaCierre ?? this.fechaCierre,
      tecnicoAsignadoId: tecnicoAsignadoId ?? this.tecnicoAsignadoId,
      tecnicoNombre: tecnicoNombre ?? this.tecnicoNombre,
    );
  }
}

/// Datos que el ciudadano envia al crear un reporte (CU-04).
class CrearReporteRequest {
  final String titulo;
  final String descripcion;
  final int cuentaId;
  final String tipoProblema;
  final CrearUbicacionRequest ubicacion;

  CrearReporteRequest({
    required this.titulo,
    required this.descripcion,
    required this.cuentaId,
    required this.tipoProblema,
    required this.ubicacion,
  });

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'cuentaId': cuentaId,
        'tipoProblema': tipoProblema,
        'ubicacion': ubicacion.toJson(),
      };
}

/// Filtros de listado (CU-05 / CU-06). Sin prioridad.
class FiltrosReporte {
  String? estado;
  String? tipoProblema;
  String? busqueda;

  FiltrosReporte({this.estado, this.tipoProblema, this.busqueda});
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
