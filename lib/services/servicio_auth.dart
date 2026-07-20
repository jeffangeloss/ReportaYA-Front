import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/api_config.dart';
import '../models/models.dart';

/// Servicio de cuenta y autenticacion (CU-01, CU-02, CU-03).
/// Conexión real con el backend mediante peticiones REST HTTP.
class ServicioAuth {
  // --- CU-01 Login ---

  Future<AuthLoginResponse> login(String usuario, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario': usuario,
        'password': password,
      }),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return AuthLoginResponse.fromJson(body);
    } else {
      final errorMsg = body['error'] ?? body['message'] ?? 'Error al iniciar sesión';
      throw Exception(errorMsg);
    }
  }

  // --- CU-02 Registro ---

  Future<CuentaResponse> crearCuenta(CrearCuentaRequest req) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/cuenta'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(req.toJson()),
    );

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return CuentaResponse.fromJson(body);
    } else {
      final errorMsg = body['error'] ?? body['message'] ?? 'Error al crear la cuenta';
      throw Exception(errorMsg);
    }
  }

  // --- CU-03 Recuperar contraseña ---

  Future<void> solicitarRecuperacion(String correo) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/recuperar-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo}),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final errorMsg = body['error'] ?? body['message'] ?? 'Error al solicitar la recuperación';
      throw Exception(errorMsg);
    }
  }

  /// Restablece la contraseña usando el token de recuperación y la nueva contraseña.
  Future<void> restablecerContrasena(String token, String nuevaPassword) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/restablecer-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'nuevaContrasena': nuevaPassword,
      }),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      final errorMsg = body['error'] ?? body['message'] ?? 'Error al restablecer la contraseña';
      throw Exception(errorMsg);
    }
  }
}
