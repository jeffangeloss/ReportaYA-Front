import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/auth.dart';
import '../models/enums.dart';
import '../services/http_service.dart';
import '../services/servicio_auth.dart';
import '../services/servicio_notificaciones.dart';

enum AuthState { checking, authenticated, unauthenticated }

class AuthController extends GetxController {
  static const String _storageKey = 'auth_user';
  final GetStorage _box = GetStorage();
  final ServicioAuth _auth = ServicioAuth();
  final ServicioNotificaciones _notif = ServicioNotificaciones();

  final Rxn<UsuarioAutenticado> usuario = Rxn<UsuarioAutenticado>();
  final Rx<AuthState> estado = AuthState.checking.obs;

  bool get isAuthenticated => estado.value == AuthState.authenticated;
  bool get isLoading => estado.value == AuthState.checking;
  bool get isCiudadano => usuario.value?.tipoCuenta == TipoCuenta.CIUDADANO;
  bool get isTecnico => usuario.value?.tipoCuenta == TipoCuenta.TECNICO;
  bool get isOperador => usuario.value?.tipoCuenta == TipoCuenta.OPERADOR_MUNICIPAL;

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
        final user = UsuarioAutenticado.fromJson(
            jsonDecode(raw) as Map<String, dynamic>);
        final ahora = DateTime.now();
        final horas = ahora.difference(user.loginTime).inHours;
        if (horas < 24) {
          usuario.value = user;
          estado.value = AuthState.authenticated;
          if (user.token != null) {
            HttpService.instance.setAuthToken(user.token!);
          }
          _registrarTokenFCM(user.id);
          return;
        } else {
          await _box.remove(_storageKey);
        }
      }
      estado.value = AuthState.unauthenticated;
    } catch (e) {
      estado.value = AuthState.unauthenticated;
    }
  }

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
      if (response.token != null) {
        HttpService.instance.setAuthToken(response.token!);
      }
      await _box.write(_storageKey, jsonEncode(u.toJson()));
      _registrarTokenFCM(u.id);
      return response;
    } catch (e) {
      estado.value = AuthState.unauthenticated;
      rethrow;
    }
  }

  Future<void> logout() async {
    usuario.value = null;
    estado.value = AuthState.unauthenticated;
    HttpService.instance.removeAuthToken();
    await _box.remove(_storageKey);
  }

  Future<void> _registrarTokenFCM(int cuentaId) async {
    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _notif.registrarToken(cuentaId: cuentaId, token: token);
        }
      }
    } catch (e) {
      // Silenciar — notificaciones son best-effort.
      print('FCM register failed: $e');
    }
  }
}
