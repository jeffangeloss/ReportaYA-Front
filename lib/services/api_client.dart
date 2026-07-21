import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../configs/api_config.dart';

/// Error de API con el mensaje que devuelve el backend ({"error": "..."}).
/// Su toString() es el mensaje limpio, para mostrarlo tal cual en la UI.
class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => message;
}

/// Cliente HTTP central hacia el backend ReportaYA.
///
/// - Agrega `Authorization: Bearer <token>` leyendo el token de la sesion
///   guardada por AuthController en GetStorage (clave 'auth_user').
/// - Traduce las respuestas de error del backend a [ApiException].
/// - Agrega paginas de un Spring `Page<T>` en una lista plana.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  final GetStorage _box = GetStorage();
  static const String _authKey = 'auth_user'; // misma clave que AuthController
  static const Duration _timeout = Duration(seconds: 12);

  String get baseUrl => ApiConfig.baseUrl;

  Map<String, dynamic>? _sesion() {
    final raw = _box.read<String>(_authKey);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String? get _token => _sesion()?['token'] as String?;

  /// Id de la cuenta logueada (operador/tecnico) para endpoints que lo exigen.
  int? get currentUserId => _sesion()?['id'] as int?;

  Map<String, String> _headers({required bool auth, bool json = true}) {
    final h = <String, String>{};
    if (json) h['Content-Type'] = 'application/json';
    if (auth) {
      final t = _token;
      if (t != null && t.isNotEmpty) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final qp = <String, String>{};
    query?.forEach((k, v) {
      if (v != null) qp[k] = v.toString();
    });
    return Uri.parse('$baseUrl$path')
        .replace(queryParameters: qp.isEmpty ? null : qp);
  }

  Future<dynamic> getJson(String path,
      {Map<String, dynamic>? query, bool auth = true}) async {
    final res = await http
        .get(_uri(path, query), headers: _headers(auth: auth, json: false))
        .timeout(_timeout);
    return _decode(res);
  }

  Future<dynamic> postJson(String path,
      {Object? body, Map<String, dynamic>? query, bool auth = true}) async {
    final res = await http
        .post(_uri(path, query),
            headers: _headers(auth: auth),
            body: body == null ? null : jsonEncode(body))
        .timeout(_timeout);
    return _decode(res);
  }

  Future<dynamic> patchJson(String path,
      {Object? body, Map<String, dynamic>? query, bool auth = true}) async {
    final res = await http
        .patch(_uri(path, query),
            headers: _headers(auth: auth),
            body: body == null ? null : jsonEncode(body))
        .timeout(_timeout);
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    final code = res.statusCode;
    dynamic parsed;
    if (res.body.isNotEmpty) {
      try {
        parsed = jsonDecode(res.body);
      } catch (_) {
        parsed = res.body;
      }
    }
    if (code >= 200 && code < 300) return parsed;

    String msg;
    if (parsed is Map && (parsed['error'] != null || parsed['message'] != null)) {
      msg = (parsed['error'] ?? parsed['message']).toString();
    } else if (code == 401) {
      msg = 'Tu sesion expiro. Inicia sesion de nuevo.';
    } else if (code == 403) {
      msg = 'No tienes permiso para esta accion.';
    } else {
      msg = 'Error del servidor ($code).';
    }
    throw ApiException(code, msg);
  }

  /// Recorre todas las paginas de un endpoint que devuelve `Page<T>` de Spring
  /// y las junta en una sola lista de mapas JSON.
  Future<List<Map<String, dynamic>>> fetchAllPages(String path,
      {Map<String, dynamic>? query}) async {
    final all = <Map<String, dynamic>>[];
    const maxPages = 100; // tope de seguridad
    for (var page = 0; page < maxPages; page++) {
      final data = await getJson(path, query: {...?query, 'page': page});
      if (data is! Map) break;
      final content = data['content'];
      if (content is List) {
        all.addAll(content.cast<Map<String, dynamic>>());
      }
      if (data['last'] == true) break;
      final totalPages = data['totalPages'];
      if (totalPages is int && page >= totalPages - 1) break;
      if (content is! List || content.isEmpty) break;
    }
    return all;
  }
}
