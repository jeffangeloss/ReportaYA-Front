import '../models/models.dart';
import 'api_client.dart';

/// Servicio de cuenta y autenticacion (CU-01, CU-02, CU-03) contra el backend
/// REST real. Mantiene las mismas firmas que la version local (entrega 2).
class ServicioAuth {
  final ApiClient _api = ApiClient.instance;

  // --- CU-01 Login ---

  Future<AuthLoginResponse> login(String usuario, String password) async {
    final data = await _api.postJson(
      '/api/auth/login',
      body: {'usuario': usuario, 'password': password},
      auth: false, // el login es publico y aun no hay token
    );
    return AuthLoginResponse.fromJson(data as Map<String, dynamic>);
  }

  // --- CU-02 Registro ---

  Future<CuentaResponse> crearCuenta(CrearCuentaRequest req) async {
    final data = await _api.postJson('/api/cuenta', body: req.toJson(), auth: false);
    return CuentaResponse.fromJson(data as Map<String, dynamic>);
  }

  // --- CU-03 Recuperar contraseña ---

  Future<void> solicitarRecuperacion(String correo) async {
    await _api.postJson('/api/auth/recuperar-password',
        body: {'correo': correo}, auth: false);
  }

  /// CU-03: completa el reset con el CODIGO de 6 caracteres que llego al correo.
  /// POST /api/auth/restablecer-password {token, password}
  Future<void> restablecerContrasena(String codigo, String nuevaPassword) async {
    await _api.postJson(
      '/api/auth/restablecer-password',
      body: {
        // el codigo se genera en mayusculas; normalizamos por si lo escriben/pegan distinto
        'token': codigo.trim().toUpperCase(),
        'password': nuevaPassword,
        'nuevaContrasena': nuevaPassword, // por si el backend usa esa clave
      },
      auth: false,
    );
  }
}
