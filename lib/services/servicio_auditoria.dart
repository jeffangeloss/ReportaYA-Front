import 'package:dio/dio.dart';
import '../models/auditoria.dart';
import 'http_service.dart';

class ServicioAuditoria {
  static const String _endpoint = '/api/reportes';
  final HttpService _http = HttpService.instance;

  Future<ReporteAuditoria> obtenerReporteParaAuditoria(int reporteId) async {
    try {
      final data = await _http.get('$_endpoint/$reporteId');
      return ReporteAuditoria.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener reporte para auditoría'));
    }
  }

  Future<RespuestaAuditoriaResponse> aceptarAuditoria(int reporteId, String comentarioCierre, {int operadorId = 1}) async {
    try {
      final data = await _http.post(
        '/api/operador/reportes/$reporteId/cerrar',
        data: {
          'operadorId': operadorId,
          'reporteId': reporteId,
          'comentarioCierre': comentarioCierre,
        },
      );
      return RespuestaAuditoriaResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al aceptar auditoría'));
    }
  }

  Future<RespuestaAuditoriaResponse> rechazarAuditoria(int reporteId, String comentarioRechazo, {int operadorId = 1}) async {
    if (comentarioRechazo.trim().isEmpty) {
      throw Exception('El comentario de rechazo es obligatorio');
    }
    try {
      final data = await _http.post(
        '/api/operador/reportes/$reporteId/rechazar-audito',
        data: {
          'operadorId': operadorId,
          'reporteId': reporteId,
          'comentarioRechazo': comentarioRechazo,
        },
      );
      return RespuestaAuditoriaResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al rechazar auditoría'));
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
