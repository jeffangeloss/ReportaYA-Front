import 'package:dio/dio.dart';
import '../models/auth.dart';
import 'http_service.dart';

class ServicioAuth {
  static const String _endpoint = '/api/auth';
  final HttpService _http = HttpService.instance;

  Future<AuthLoginResponse> login(String usuario, String password) async {
    try {
      final data = await _http.post(
        '$_endpoint/login',
        data: AuthLoginRequest(usuario: usuario, password: password).toJson(),
      );
      return AuthLoginResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 401) {
        throw Exception('Usuario o contraseña incorrectos');
      } else if (status == 400) {
        throw Exception('Datos de login inválidos');
      }
      final errMsg = e.response?.data is Map
          ? (e.response!.data['error'] ?? e.response!.data['message'])
          : null;
      throw Exception(errMsg ?? e.message ?? 'Error al iniciar sesión');
    }
  }
}
