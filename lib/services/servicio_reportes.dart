import '../models/models.dart';
import 'api_client.dart';

/// Logica de reportes contra el backend REST real.
/// Mantiene las mismas firmas que la version local (entrega 2), asi que los
/// controllers y pantallas no cambian.
class ServicioReportes {
  final ApiClient _api = ApiClient.instance;

  // ---------------- Lectura (CU-05 / CU-06 / CU-08) ----------------

  Future<List<ReporteResponse>> obtenerReportesPorCuenta(int cuentaId) async {
    final items = await _api.fetchAllPages('/api/reportes/cuenta/$cuentaId');
    final list = items.map(ReporteResponse.fromJson).toList();
    list.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return list;
  }

  Future<List<ReporteResponse>> obtenerTodos({String? estado}) async {
    final items = await _api.fetchAllPages('/api/reportes', query: {'estado': estado});
    final list = items.map(ReporteResponse.fromJson).toList();
    list.sort((a, b) => b.fechaActualizacion.compareTo(a.fechaActualizacion));
    return list;
  }

  Future<List<ReporteResponse>> obtenerParaMapa({String? estado, String? tipo}) async {
    final data = await _api.getJson('/api/reportes/mapa',
        query: {'estado': estado, 'tipo': tipo});
    return (data as List)
        .map((e) => ReporteResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ReporteResponse>> obtenerAsignadosATecnico(int tecnicoId) async {
    // /mapa devuelve el DTO completo (incluye tecnicoAsignadoId) como lista.
    final data = await _api.getJson('/api/reportes/mapa');
    final list = (data as List)
        .map((e) => ReporteResponse.fromJson(e as Map<String, dynamic>))
        .where((r) => r.tecnicoAsignadoId == tecnicoId)
        .toList();
    list.sort((a, b) => b.fechaActualizacion.compareTo(a.fechaActualizacion));
    return list;
  }

  Future<List<HistorialEstado>> obtenerHistorialEstados(int reporteId) async {
    final data = await _api.getJson('/api/historial-estados/reporte/$reporteId');
    return (data as List)
        .map((e) => HistorialEstado.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Foto>> obtenerFotos(int reporteId, {String? tipo}) async {
    // Las fotos vienen embebidas en el detalle del reporte (ReporteDTO.fotos).
    final data = await _api.getJson('/api/reportes/$reporteId') as Map<String, dynamic>;
    final fotosJson = (data['fotos'] as List?) ?? const [];
    var fotos = fotosJson
        .map((e) => Foto.fromJson(e as Map<String, dynamic>))
        .toList();
    if (tipo != null) fotos = fotos.where((f) => f.tipo == tipo).toList();
    return fotos;
  }

  // ---------------- Escritura ----------------

  /// CU-04: crea un reporte en estado PENDIENTE.
  /// Nota: `urlsFotos` son rutas de assets simuladas (la camara real llega en
  /// una entrega posterior); el backend exige base64, por eso aqui no se suben.
  Future<ReporteResponse> crearReporte(
    CrearReporteRequest req, {
    String? nombreCiudadano,
    List<String> urlsFotos = const [],
  }) async {
    final data = await _api.postJson('/api/reportes', body: req.toJson());
    return ReporteResponse.fromJson(data as Map<String, dynamic>);
  }

  /// CU-06: el operador acepta -> PENDIENTE pasa a REVISION.
  Future<ReporteResponse> aceptarReporte(int id) async {
    final data = await _api.patchJson('/api/reportes/$id/estado',
        query: {'nuevoEstado': EstadoReporte.REVISION});
    return ReporteResponse.fromJson(data as Map<String, dynamic>);
  }

  /// CU-06: el operador rechaza con motivo -> RECHAZADO.
  Future<ReporteResponse> rechazarReporte(int id, String motivo) async {
    final data =
        await _api.postJson('/api/reportes/$id/rechazar', query: {'motivo': motivo});
    return ReporteResponse.fromJson(data as Map<String, dynamic>);
  }

  /// CU-07: asigna un tecnico (el estado se mantiene en REVISION).
  /// El backend exige operadorId; se toma de la sesion del operador logueado.
  /// La asignacion no devuelve el reporte, asi que se re-consulta.
  Future<ReporteResponse> asignarTecnico(int id, TecnicoResponse tecnico) async {
    final operadorId = _api.currentUserId;
    if (operadorId == null) {
      throw ApiException(401, 'Sesion no valida. Inicia sesion de nuevo.');
    }
    await _api.postJson('/api/asignaciones', body: {
      'reporteId': id,
      'operadorId': operadorId,
      'tecnicoId': tecnico.id,
    });
    final data = await _api.getJson('/api/reportes/$id');
    return ReporteResponse.fromJson(data as Map<String, dynamic>);
  }

  /// CU-08: el tecnico finaliza -> REVISION pasa a FINALIZADO.
  /// tecnicoId se toma de la sesion del tecnico logueado. Las fotos FINAL van
  /// vacias (simuladas en el front); el backend acepta lista vacia.
  Future<ReporteResponse> finalizarReporte(
    int id,
    String comentarioResolucion,
    List<String> urlsFotos,
  ) async {
    final tecnicoId = _api.currentUserId;
    if (tecnicoId == null) {
      throw ApiException(401, 'Sesion no valida. Inicia sesion de nuevo.');
    }
    final data = await _api.patchJson(
      '/api/tecnicos/$tecnicoId/reportes/$id/completar',
      body: {
        'comentarioResolucion': comentarioResolucion,
        'fotos': const [],
      },
    ) as Map<String, dynamic>;
    // El endpoint responde {mensaje, reporte, fotosAdjuntadas, estadoFinal}.
    return ReporteResponse.fromJson(data['reporte'] as Map<String, dynamic>);
  }
}
