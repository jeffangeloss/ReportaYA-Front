import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../configs/api_config.dart';
import '../controllers/auth_controller.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    try {
      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        final token = auth.usuario.value?.token;
        if (token != null && token.isNotEmpty) {
          headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Ignorar si el controlador aún no está registrado
    }

    return headers;
  }

  Future<dynamic> get(String path) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _buildHeaders(),
    );
    return _processResponse(response);
  }

  Future<dynamic> post(String path, dynamic body) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> patch(String path, dynamic body) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> put(String path, dynamic body) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _buildHeaders(),
      body: jsonEncode(body),
    );
    return _processResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _buildHeaders(),
    );
    return _processResponse(response);
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      dynamic errorMsg;
      try {
        final Map<String, dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        errorMsg = body['error'] ?? body['message'];
      } catch (_) {
        // Fallback si no es un JSON válido
      }
      throw Exception(errorMsg ?? 'Error en la petición: ${response.statusCode}');
    }
  }
}
