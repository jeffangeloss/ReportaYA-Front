import 'package:dio/dio.dart';
import '../models/cuenta.dart';
import 'http_service.dart';

class ServicioCuenta {
  static const String _endpoint = '/api/cuenta';
  final HttpService _http = HttpService.instance;

  Future<CuentaResponse> crearCuenta(CrearCuentaRequest cuenta) async {
    try {
      final data = await _http.post(_endpoint, data: cuenta.toJson());
      return CuentaResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errMsg = e.response?.data is Map
          ? e.response!.data['message']
          : null;
      throw Exception(errMsg ?? 'Error al crear la cuenta');
    }
  }
}
