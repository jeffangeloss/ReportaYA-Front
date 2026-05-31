import 'package:dio/dio.dart';

class HttpService {
  // Android emulator uses 10.0.2.2 to reach host machine.
  // Backend clone (ReportaYA-Backend-Flutter) runs on port 8081 to avoid clash with original 8080.
  static const String baseUrl = 'http://10.0.2.2:8081';

  late final Dio _dio;

  HttpService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        print('HTTP error: ${e.response?.data ?? e.message}');
        handler.next(e);
      },
    ));
  }

  static final HttpService instance = HttpService._internal();

  Future<dynamic> get(String url, {Map<String, dynamic>? query}) async {
    final res = await _dio.get(url, queryParameters: query);
    return res.data;
  }

  Future<dynamic> post(String url, {dynamic data, Map<String, dynamic>? query}) async {
    final res = await _dio.post(url, data: data, queryParameters: query);
    return res.data;
  }

  Future<dynamic> put(String url, {dynamic data}) async {
    final res = await _dio.put(url, data: data);
    return res.data;
  }

  Future<dynamic> patch(String url, {dynamic data, Map<String, dynamic>? query}) async {
    final res = await _dio.patch(url, data: data, queryParameters: query);
    return res.data;
  }

  Future<dynamic> delete(String url) async {
    final res = await _dio.delete(url);
    return res.data;
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
