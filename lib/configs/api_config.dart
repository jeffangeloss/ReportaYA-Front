import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// Dirección del backend.
///
/// Orden de prioridad:
/// 1. La URL elegida en la app (pantalla de login → "Servidor"), guardada en el
///    teléfono. Permite cambiar entre la PC local y la nube sin recompilar.
/// 2. La URL de compilación: `--dart-define=API_BASE_URL=http://IP:8081/api`.
/// 3. Release sin define: el backend desplegado en Render.
/// 4. Debug sin define: el backend local según la plataforma
///    (emulador Android → 10.0.2.2; web/escritorio/iOS → localhost).
class ApiConfig {
  static const String _compileOverride =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  /// Backend en la nube. Se puede cambiar al compilar sin tocar el código:
  /// `--dart-define=NUBE_URL=https://otro-servicio.onrender.com/api`.
  static const String productionUrl = String.fromEnvironment('NUBE_URL',
      defaultValue: 'https://reportaya-backend.onrender.com/api');

  static const String _storageKey = 'api_base_url';

  static String? _runtimeUrl;

  /// Lee la URL guardada. Llamar una vez tras `GetStorage.init()`.
  static void cargar() {
    try {
      final v = GetStorage().read<String>(_storageKey);
      _runtimeUrl = (v != null && v.trim().isNotEmpty) ? v.trim() : null;
    } catch (_) {
      _runtimeUrl = null;
    }
  }

  /// Guarda la URL elegida por el usuario; `null` vuelve a la de compilación.
  static Future<void> guardar(String? url) async {
    final box = GetStorage();
    if (url == null || url.trim().isEmpty) {
      _runtimeUrl = null;
      await box.remove(_storageKey);
    } else {
      _runtimeUrl = normalizar(url);
      await box.write(_storageKey, _runtimeUrl);
    }
  }

  /// URL con la que se compiló la app (sin la elección del usuario).
  static String get urlCompilada {
    if (_compileOverride.isNotEmpty) return normalizar(_compileOverride);
    if (kReleaseMode) return productionUrl;
    if (kIsWeb) return 'http://localhost:8081/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:8081/api';
    return 'http://localhost:8081/api';
  }

  static bool get usaUrlPersonalizada => _runtimeUrl != null;

  static String get baseUrl => _runtimeUrl ?? urlCompilada;

  /// Raíz del servidor sin el sufijo /api (para fotos servidas en /media/...).
  static String get origen {
    final b = baseUrl;
    return b.endsWith('/api') ? b.substring(0, b.length - 4) : b;
  }

  /// Texto corto para mostrar al usuario: "192.168.18.8:8081" o "reportaya-backend.onrender.com".
  static String get descripcionCorta {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) return baseUrl;
    return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }

  /// Acepta "192.168.18.8:8081", "http://192.168.18.8:8081/", ".../api" y
  /// devuelve siempre "http(s)://host[:puerto]/api".
  static String normalizar(String input) {
    var u = input.trim();
    if (!u.startsWith('http://') && !u.startsWith('https://')) u = 'http://$u';
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (!u.endsWith('/api')) u = '$u/api';
    return u;
  }

  /// Convierte la URL de una foto en algo que Image.network pueda abrir.
  /// - http(s)://... → tal cual (Firebase o backend nuevo).
  /// - /media/... o uploads/... → relativa al servidor actual.
  /// - assets/... → se devuelve igual (la vista la abre como asset).
  static String resolverUrlFoto(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$origen$url';
    if (url.startsWith('uploads/')) return '$origen/$url';
    return url;
  }
}
