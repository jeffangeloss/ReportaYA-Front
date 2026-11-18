import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../configs/api_config.dart';
import '../controllers/auth_controller.dart';

/// Cliente HTTP único hacia el backend.
///
/// - Agrega `Authorization: Bearer <token>` si hay sesión (salvo `auth: false`).
/// - Tiempo límite de 60 s: Render (plan gratis) puede tardar ~50 s en despertar.
/// - Convierte errores de red y respuestas no JSON en mensajes legibles.
/// - Si el backend responde 401 a una petición autenticada, la sesión venció
///   (o el servidor cambió): cierra sesión y vuelve al login.
class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();

  static const Duration _timeout = Duration(seconds: 60);

  String? _tokenActual() {
    try {
      if (Get.isRegistered<AuthController>()) {
        final token = Get.find<AuthController>().usuario.value?.token;
        if (token != null && token.isNotEmpty) return token;
      }
    } catch (_) {
      // El controlador aún no está registrado.
    }
    return null;
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Uri _uri(String path) => Uri.parse('${ApiConfig.baseUrl}$path');

  Future<dynamic> get(String path, {bool auth = true}) =>
      _send(path, auth, (u, h) => http.get(u, headers: h));

  Future<dynamic> post(String path, dynamic body, {bool auth = true}) =>
      _send(path, auth, (u, h) => http.post(u, headers: h, body: jsonEncode(body)));

  Future<dynamic> patch(String path, dynamic body, {bool auth = true}) =>
      _send(path, auth, (u, h) => http.patch(u, headers: h, body: jsonEncode(body)));

  Future<dynamic> put(String path, dynamic body, {bool auth = true}) =>
      _send(path, auth, (u, h) => http.put(u, headers: h, body: jsonEncode(body)));

  Future<dynamic> delete(String path, {bool auth = true}) =>
      _send(path, auth, (u, h) => http.delete(u, headers: h));

  /// Recorre todas las páginas de un endpoint paginado de Spring y devuelve
  /// el `content` unido. Antes solo se leía la primera página (10 elementos).
  Future<List<dynamic>> getTodasLasPaginas(String path, {int maxPaginas = 100}) async {
    final todos = <dynamic>[];
    final sep = path.contains('?') ? '&' : '?';
    for (var page = 0; page < maxPaginas; page++) {
      final res = await get('$path${sep}page=$page');
      if (res is! Map) break;
      final content = res['content'];
      if (content is List) todos.addAll(content);
      if (_esUltimaPagina(res, page, content)) break;
    }
    return todos;
  }

  bool _esUltimaPagina(Map res, int page, dynamic content) {
    if (res['last'] is bool) return res['last'] as bool;
    // Formato "via DTO" de Spring Data: {"content":[...],"page":{"totalPages":N}}
    final meta = res['page'];
    final totalPages = (res['totalPages'] ?? (meta is Map ? meta['totalPages'] : null)) as num?;
    if (totalPages != null) return page + 1 >= totalPages.toInt();
    return content is! List || content.isEmpty;
  }

  Future<dynamic> _send(
    String path,
    bool auth,
    Future<http.Response> Function(Uri, Map<String, String>) request,
  ) async {
    final token = auth ? _tokenActual() : null;
    final http.Response response;
    try {
      response = await request(_uri(path), _headers(token)).timeout(_timeout);
    } on TimeoutException {
      throw Exception(
          'El servidor (${ApiConfig.descripcionCorta}) no respondió a tiempo. '
          'Si es la nube, puede estar despertando: intenta de nuevo en un momento.');
    } on SocketException {
      throw Exception(_mensajeSinConexion());
    } on http.ClientException {
      throw Exception(_mensajeSinConexion());
    }
    return _procesar(response, enviadoConToken: token != null);
  }

  String _mensajeSinConexion() =>
      'No se pudo conectar con ${ApiConfig.descripcionCorta}. Revisa que el backend '
      'esté encendido y, si es tu PC, que el celular esté en la misma red.';

  dynamic _procesar(http.Response response, {required bool enviadoConToken}) {
    final texto = utf8.decode(response.bodyBytes, allowMalformed: true);
    dynamic body;
    if (texto.isNotEmpty) {
      try {
        body = jsonDecode(texto);
      } catch (_) {
        body = null; // HTML de error de un proxy, texto plano, etc.
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body ?? (texto.isEmpty ? null : texto);
    }

    if (response.statusCode == 401 && enviadoConToken) {
      if (Get.isRegistered<AuthController>()) {
        Get.find<AuthController>().sesionExpirada();
      }
      throw Exception('Tu sesión expiró. Inicia sesión nuevamente.');
    }

    throw Exception(_mensajeError(body, response.statusCode));
  }

  String _mensajeError(dynamic body, int status) {
    if (body is Map) {
      // Formato de validación de Spring: {"errors":[{"defaultMessage":"..."}]}
      final errors = body['errors'];
      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map && first['defaultMessage'] != null) return '${first['defaultMessage']}';
        if (first is String) return first;
      }
      final msg = body['error'] ?? body['message'];
      if (msg != null && '$msg'.trim().isNotEmpty) return '$msg';
    }
    switch (status) {
      case 403:
        return 'No tienes permiso para realizar esta acción.';
      case 404:
        return 'No se encontró lo solicitado.';
      case 502:
      case 503:
      case 504:
        return 'El servidor no está disponible en este momento. Intenta de nuevo.';
      default:
        return 'Error en la petición ($status).';
    }
  }
}
