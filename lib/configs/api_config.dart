import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// URL base del backend.
  ///
  /// Para apuntar al backend DESPLEGADO (nube/túnel), se pasa en build/run:
  ///   flutter run   --dart-define=API_BASE_URL=https://tu-backend.com/api
  ///   flutter build --dart-define=API_BASE_URL=https://tu-backend.com/api
  ///
  /// Si no se define, cae al backend local según la plataforma (desarrollo):
  /// - Android Emulator: 10.0.2.2 (localhost del host)
  /// - iOS Simulator / Desktop / Web: localhost (127.0.0.1)
  static const String _override =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_override.isNotEmpty) {
      return _override;
    }
    if (kIsWeb) {
      return 'http://localhost:8081/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api';
    }
    return 'http://localhost:8081/api';
  }
}
