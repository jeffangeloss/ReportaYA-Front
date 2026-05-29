import 'package:dio/dio.dart';
import 'http_service.dart';

class ServicioAsignaciones {
  static const String _endpoint = '/api/asignaciones';
  final HttpService _http = HttpService.instance;

  Future<Map<String, dynamic>> crearAsignacion({
    required int reporteId,
    required int operadorId,
    required int tecnicoId,
    required String prioridad,
  }) async {
    try {
      final data = await _http.post(_endpoint, data: {
        'reporteId': reporteId,
        'operadorId': operadorId,
        'tecnicoId': tecnicoId,
        'prioridad': prioridad,
      });
      return data as Map<String, dynamic>;
    } on DioException catch (e) {
      final errMsg = e.response?.data is Map ? e.response!.data['error'] : null;
      throw Exception(errMsg ?? e.message ?? 'Error al crear la asignación');
    }
  }
}
