import 'package:dio/dio.dart';
import 'http_service.dart';

class ServicioNotificaciones {
  final HttpService _http = HttpService.instance;

  Future<String> registrarToken({required int cuentaId, required String token}) async {
    try {
      final data = await _http.post(
        '/notificaciones/registrar-token',
        data: {'cuentaId': cuentaId, 'token': token},
      );
      return data?.toString() ?? '';
    } on DioException catch (e) {
      throw Exception(e.message ?? 'Error al registrar token');
    }
  }
}
