import 'package:dio/dio.dart';
import '../models/pagination.dart';
import '../models/reporte.dart';
import 'http_service.dart';

class ServicioReportes {
  static const String _endpoint = '/api/reportes';
  final HttpService _http = HttpService.instance;

  Future<ReporteResponse> crearReporte(CrearReporteRequest reporte) async {
    try {
      final data = await _http.post(_endpoint, data: reporte.toJson());
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al crear el reporte'));
    }
  }

  Future<ReporteResponse> actualizarReporte(int id, Map<String, dynamic> reporte) async {
    try {
      final data = await _http.put('$_endpoint/$id', data: reporte);
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al actualizar el reporte'));
    }
  }

  Future<Page<ReporteResponse>> obtenerTodosReportes({int page = 0, String? estado}) async {
    try {
      final query = <String, dynamic>{'page': page};
      if (estado != null) query['estado'] = estado;
      final data = await _http.get(_endpoint, query: query);
      return Page.fromJson(data as Map<String, dynamic>, ReporteResponse.fromJson);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener los reportes'));
    }
  }

  Future<List<ReporteResponse>> obtenerReportesMapa({String? estado, String? tipo, String? prioridad}) async {
    try {
      final query = <String, dynamic>{};
      if (estado != null) query['estado'] = estado;
      if (tipo != null) query['tipo'] = tipo;
      if (prioridad != null) query['prioridad'] = prioridad;
      final data = await _http.get('$_endpoint/mapa', query: query);
      return (data as List<dynamic>)
          .map((e) => ReporteResponse.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener reportes del mapa'));
    }
  }

  Future<ReporteResponse> rechazarReporte(int id, String motivo) async {
    try {
      final data = await _http.post(
        '$_endpoint/$id/rechazar',
        data: null,
      );
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al rechazar el reporte'));
    }
  }

  // Note: server expects motivo as query param (matches RN call).
  Future<ReporteResponse> rechazarReporteConMotivo(int id, String motivo) async {
    try {
      final data = await _http.post('$_endpoint/$id/rechazar', query: {'motivo': motivo});
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al rechazar el reporte'));
    }
  }

  Future<List<HistorialEstado>> obtenerHistorialEstados(int reporteId) async {
    try {
      final data = await _http.get('/historial-estados/reporte/$reporteId');
      return (data as List<dynamic>)
          .map((e) => HistorialEstado.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener historial'));
    }
  }

  Future<Page<ReporteResponse>> obtenerReportesPorCuenta(int cuentaId, {int page = 0}) async {
    try {
      final data = await _http.get('$_endpoint/cuenta/$cuentaId', query: {'page': page});
      return Page.fromJson(data as Map<String, dynamic>, ReporteResponse.fromJson);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener los reportes'));
    }
  }

  Future<ReporteResponse> cambiarEstadoReporte(int id, String nuevoEstado) async {
    try {
      final data = await _http.patch('$_endpoint/$id/estado', query: {'nuevoEstado': nuevoEstado});
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al cambiar estado del reporte'));
    }
  }

  Future<ReporteResponse> cambiarPrioridadReporte(int id, String nuevaPrioridad) async {
    try {
      final data = await _http.patch('$_endpoint/$id/prioridad', query: {'nuevaPrioridad': nuevaPrioridad});
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al cambiar prioridad'));
    }
  }

  Future<void> eliminarReporte(int id) async {
    try {
      await _http.delete('$_endpoint/$id');
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al eliminar el reporte'));
    }
  }

  String _msg(DioException e, String fallback) {
    if (e.response?.data is Map) {
      final m = e.response!.data['message'];
      if (m != null) return m.toString();
    }
    return e.message ?? fallback;
  }
}
