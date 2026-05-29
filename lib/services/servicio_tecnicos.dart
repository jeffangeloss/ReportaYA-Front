import 'package:dio/dio.dart';
import '../models/pagination.dart';
import '../models/reporte.dart';
import '../models/tecnico.dart';
import 'http_service.dart';

class ServicioTecnicos {
  static const String _endpoint = '/api/tecnicos';
  final HttpService _http = HttpService.instance;

  Future<Page<TecnicoResponse>> obtenerTodosTecnicos({int page = 0}) async {
    try {
      final data = await _http.get(_endpoint, query: {'page': page});
      return Page.fromJson(data as Map<String, dynamic>, TecnicoResponse.fromJson);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener los técnicos'));
    }
  }

  Future<Page<ReporteResponse>> obtenerReportesAsignados(int tecnicoId, {String? estado, int page = 0}) async {
    try {
      final query = <String, dynamic>{'page': page};
      if (estado != null) query['estado'] = estado;
      final data = await _http.get('$_endpoint/$tecnicoId/reportes', query: query);
      return Page.fromJson(data as Map<String, dynamic>, ReporteResponse.fromJson);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener los reportes asignados'));
    }
  }

  Future<CompletarReporteResponse> completarReporte(
      int tecnicoId, int reporteId, CompletarReporteRequest request) async {
    try {
      final data = await _http.patch(
        '$_endpoint/$tecnicoId/reportes/$reporteId/completar',
        data: request.toJson(),
      );
      return CompletarReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al completar el reporte'));
    }
  }

  Future<ReporteResponse> obtenerReportePorId(int reporteId) async {
    try {
      final data = await _http.get('/api/reportes/$reporteId');
      return ReporteResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_msg(e, 'Error al obtener el reporte'));
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
