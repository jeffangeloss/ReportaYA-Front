import '../data/local_store.dart';
import '../models/models.dart';

/// Logica de reportes contra el almacen local (sin REST).
/// Mismas firmas que tendra la version API en la entrega 3/4.
class ServicioReportes {
  final LocalStore _store = LocalStore.instance;

  String _ahora() => DateTime.now().toIso8601String();

  // ---------------- Lectura (CU-05 / CU-06 / CU-08) ----------------

  /// Reportes creados por un ciudadano (vista 03 Mis reportes).
  Future<List<ReporteResponse>> obtenerReportesPorCuenta(int cuentaId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = _store.reportes.where((r) => r.cuentaId == cuentaId).toList();
    list.sort((a, b) => b.fechaCreacion.compareTo(a.fechaCreacion));
    return list;
  }

  /// Reportes recientes para la vista 02 Inicio.
  Future<List<ReporteResponse>> obtenerRecientes(int cuentaId, {int limit = 5}) async {
    final list = await obtenerReportesPorCuenta(cuentaId);
    return list.take(limit).toList();
  }

  /// Todos los reportes, opcionalmente filtrados por estado (vista 01 Cola).
  Future<List<ReporteResponse>> obtenerTodos({String? estado}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = _store.reportes
        .where((r) => estado == null || r.estado == estado)
        .toList();
    list.sort((a, b) => b.fechaActualizacion.compareTo(a.fechaActualizacion));
    return list;
  }

  /// Reportes con ubicacion para la vista 06 Mapa.
  Future<List<ReporteResponse>> obtenerParaMapa({String? estado, String? tipo}) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _store.reportes
        .where((r) => (estado == null || r.estado == estado) &&
            (tipo == null || r.tipoProblema == tipo))
        .toList();
  }

  /// Reportes asignados a un tecnico (vista 01 Mis asignaciones).
  Future<List<ReporteResponse>> obtenerAsignadosATecnico(int tecnicoId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = _store.reportes
        .where((r) => r.tecnicoAsignadoId == tecnicoId)
        .toList();
    list.sort((a, b) => b.fechaActualizacion.compareTo(a.fechaActualizacion));
    return list;
  }

  Future<ReporteResponse?> obtenerDetalle(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final i = _store.indexReporte(id);
    return i >= 0 ? _store.reportes[i] : null;
  }

  Future<List<HistorialEstado>> obtenerHistorialEstados(int reporteId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _store.historialDe(reporteId);
  }

  Future<List<Foto>> obtenerFotos(int reporteId, {String? tipo}) async {
    return _store.fotosDe(reporteId, tipo: tipo);
  }

  /// Conteo por estado (contadores de las vistas 01).
  Future<Map<String, int>> contarPorEstado() async {
    final map = {for (final e in EstadoReporte.values) e: 0};
    for (final r in _store.reportes) {
      map[r.estado] = (map[r.estado] ?? 0) + 1;
    }
    return map;
  }

  Future<Map<String, int>> contarPorEstadoTecnico(int tecnicoId) async {
    final map = {EstadoReporte.REVISION: 0, EstadoReporte.FINALIZADO: 0};
    for (final r in _store.reportes.where((r) => r.tecnicoAsignadoId == tecnicoId)) {
      map[r.estado] = (map[r.estado] ?? 0) + 1;
    }
    return map;
  }

  // ---------------- Escritura ----------------

  /// CU-04: crea un reporte en estado PENDIENTE.
  Future<ReporteResponse> crearReporte(CrearReporteRequest req, {String? nombreCiudadano}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = _store.nextReporteId();
    final ahora = _ahora();
    final reporte = ReporteResponse(
      id: id,
      titulo: req.titulo,
      descripcion: req.descripcion,
      cuentaId: req.cuentaId,
      nombreCiudadano: nombreCiudadano,
      estado: EstadoReporte.PENDIENTE,
      tipoProblema: req.tipoProblema,
      ubicacion: Ubicacion(
        id: id,
        latitud: req.ubicacion.latitud,
        longitud: req.ubicacion.longitud,
        direccion: req.ubicacion.direccion,
      ),
      fechaCreacion: ahora,
      fechaActualizacion: ahora,
    );
    _store.reportes.add(reporte);
    _store.registrarCambioEstado(id, null, EstadoReporte.PENDIENTE);
    return reporte;
  }

  /// CU-06: el operador acepta -> PENDIENTE pasa a REVISION.
  Future<ReporteResponse> aceptarReporte(int id) async {
    return _transicion(id, EstadoReporte.REVISION);
  }

  /// CU-06: el operador rechaza con motivo -> PENDIENTE pasa a RECHAZADO.
  Future<ReporteResponse> rechazarReporte(int id, String motivo) async {
    final i = _requireIndex(id);
    final anterior = _store.reportes[i].estado;
    final actualizado = _store.reportes[i].copyWith(
      estado: EstadoReporte.RECHAZADO,
      comentarioResolucion: motivo,
      fechaActualizacion: _ahora(),
      fechaCierre: _ahora(),
    );
    _store.reportes[i] = actualizado;
    _store.registrarCambioEstado(id, anterior, EstadoReporte.RECHAZADO);
    return actualizado;
  }

  /// CU-07: asigna un tecnico. El estado se mantiene en REVISION.
  Future<ReporteResponse> asignarTecnico(int id, TecnicoResponse tecnico) async {
    final i = _requireIndex(id);
    final actualizado = _store.reportes[i].copyWith(
      tecnicoAsignadoId: tecnico.id,
      tecnicoNombre: tecnico.nombreCompleto,
      fechaActualizacion: _ahora(),
    );
    _store.reportes[i] = actualizado;
    return actualizado;
  }

  /// CU-08: el tecnico finaliza -> REVISION pasa a FINALIZADO.
  Future<ReporteResponse> finalizarReporte(
    int id,
    String comentarioResolucion,
    List<String> urlsFotos,
  ) async {
    final i = _requireIndex(id);
    final anterior = _store.reportes[i].estado;
    final actualizado = _store.reportes[i].copyWith(
      estado: EstadoReporte.FINALIZADO,
      comentarioResolucion: comentarioResolucion,
      fechaActualizacion: _ahora(),
      fechaCierre: _ahora(),
    );
    _store.reportes[i] = actualizado;
    for (final url in urlsFotos) {
      _store.fotos.add(Foto(
        id: _store.nextFotoId(),
        reporteId: id,
        url: url,
        tipo: TipoFoto.FINAL,
        descripcion: 'Foto de resolucion',
        fechaCarga: _ahora(),
      ));
    }
    _store.registrarCambioEstado(id, anterior, EstadoReporte.FINALIZADO);
    return actualizado;
  }

  // ---------------- internos ----------------

  Future<ReporteResponse> _transicion(int id, String nuevo) async {
    final i = _requireIndex(id);
    final anterior = _store.reportes[i].estado;
    final actualizado = _store.reportes[i].copyWith(
      estado: nuevo,
      fechaActualizacion: _ahora(),
    );
    _store.reportes[i] = actualizado;
    _store.registrarCambioEstado(id, anterior, nuevo);
    return actualizado;
  }

  int _requireIndex(int id) {
    final i = _store.indexReporte(id);
    if (i < 0) throw Exception('Reporte no encontrado');
    return i;
  }
}
