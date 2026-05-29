import 'package:dio/dio.dart';
import '../models/pagination.dart';
import '../models/reporte.dart';
import 'http_service.dart';

class ServicioOperador {
  static const String _endpoint = '/api/operador';
  final HttpService _http = HttpService.instance;

  Future<Page<ReporteResponse>> obtenerReportesParaAuditoria({
    String estado = 'RESUELTA',
    int page = 0,
  }) async {
    try {
      final data = await _http.get(
        '$_endpoint/reportes-auditoria',
        query: {'estado': estado, 'page': page},
      );
      return Page.fromJson(data as Map<String, dynamic>, ReporteResponse.fromJson);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener reportes'));
    }
  }

  Future<ReporteResponse> cerrarReporte(int reporteId, int operadorId, String comentarioCierre) async {
    try {
      final data = await _http.post(
        '$_endpoint/reportes/$reporteId/cerrar',
        data: {'operadorId': operadorId, 'comentarioCierre': comentarioCierre},
      );
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al cerrar el reporte'));
    }
  }

  Future<ReporteResponse> rechazarAudito(int reporteId, int operadorId, String comentarioRechazo) async {
    try {
      final data = await _http.post(
        '$_endpoint/reportes/$reporteId/rechazar-audito',
        data: {'operadorId': operadorId, 'comentarioRechazo': comentarioRechazo},
      );
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al rechazar el reporte'));
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
