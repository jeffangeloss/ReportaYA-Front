import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/models.dart';
import '../services/servicio_auth.dart';

enum AuthState { checking, authenticated, unauthenticated }

/// CU-01/02/03. Sesion local con persistencia en GetStorage (TTL 24h).
class AuthController extends GetxController {
  static const String _storageKey = 'auth_user';
  final GetStorage _box = GetStorage();
  final ServicioAuth _auth = ServicioAuth();

  final Rxn<UsuarioAutenticado> usuario = Rxn<UsuarioAutenticado>();
  final Rx<AuthState> estado = AuthState.checking.obs;

  bool get isAuthenticated => estado.value == AuthState.authenticated;
  bool get isCiudadano => usuario.value?.tipoCuenta == TipoCuenta.CIUDADANO;
  bool get isTecnico => usuario.value?.tipoCuenta == TipoCuenta.TECNICO;
  bool get isOperador => usuario.value?.tipoCuenta == TipoCuenta.OPERADOR_MUNICIPAL;
  int get cuentaId => usuario.value?.id ?? 0;

  @override
  void onInit() {
    super.onInit();
    verificarAutenticacionInicial();
  }

  Future<void> verificarAutenticacionInicial() async {
    try {
      estado.value = AuthState.checking;
      final raw = _box.read<String>(_storageKey);
      if (raw != null) {
        final user = UsuarioAutenticado.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        final horas = DateTime.now().difference(user.loginTime).inHours;
        if (horas < 24) {
          usuario.value = user;
          estado.value = AuthState.authenticated;
          return;
        }
        await _box.remove(_storageKey);
      }
      estado.value = AuthState.unauthenticated;
    } catch (_) {
      estado.value = AuthState.unauthenticated;
    }
  }

  // --- CU-01 Login ---

  Future<AuthLoginResponse> login(String usuarioInput, String password) async {
    try {
      estado.value = AuthState.checking;
      final response = await _auth.login(usuarioInput, password);
      final u = UsuarioAutenticado(
        id: response.cuentaId,
        usuario: response.usuario,
        nombre: response.nombreCompleto,
        tipoCuenta: response.tipoCuenta,
        loginTime: DateTime.now(),
        token: response.token,
      );
      usuario.value = u;
      estado.value = AuthState.authenticated;
      await _box.write(_storageKey, jsonEncode(u.toJson()));
      return response;
    } catch (e) {
      estado.value = AuthState.unauthenticated;
      rethrow;
    }
  }

  Future<void> logout() async {
    usuario.value = null;
    estado.value = AuthState.unauthenticated;
    await _box.remove(_storageKey);
  }

  // --- CU-02 Registro ---

  Future<void> registrar(CrearCuentaRequest req) async {
    await _auth.crearCuenta(req);
  }

  // --- CU-03 Recuperar contraseña ---

  Future<void> solicitarRecuperacion(String correo) async {
    await _auth.solicitarRecuperacion(correo);
  }

  Future<void> restablecerContrasena(
    String correo,
    String nueva,
    String confirmacion,
  ) async {
    if (nueva != confirmacion) throw Exception('Las contraseñas no coinciden');
    if (nueva.length < 6) throw Exception('La contraseña debe tener al menos 6 caracteres');
    await _auth.restablecerContrasena(correo, nueva);
  }
}
