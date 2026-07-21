import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Retorna la URL base del backend adaptada según la plataforma de ejecución.
  /// - Android Emulator: requiere usar 10.0.2.2 para comunicarse con el localhost de la máquina host.
  /// - iOS Simulator / Desktop / Web: se comunican directamente con localhost (127.0.0.1).
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api';
    }
    return 'http://localhost:8081/api';
  }
}
