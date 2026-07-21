/// Configuracion de red del backend ReportaYA.
///
/// La URL base se puede sobreescribir al compilar sin tocar codigo:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.50:8081
///
/// Valor por defecto: la IP LAN del laptop del backend en el hotspot de la demo.
/// IMPORTANTE: en un dispositivo fisico (iPhone/Android) NO uses "localhost";
/// debe ser la IP del laptop en la MISMA red. Esa IP la asigna el router por
/// DHCP y puede cambiar al reconectar; si la app deja de cargar, actualizala
/// aqui (o pasala por --dart-define) y vuelve a correr.
///   - Emulador Android:  http://10.0.2.2:8081
///   - Web (Chrome) local: http://localhost:8081 tambien sirve
class ApiConfig {
  // Simulador iOS / Desktop: 'localhost' comparte la red del Mac y NO se rompe
  // al cambiar de WiFi/hotspot (la IP LAN por DHCP cambia; localhost no).
  // Dispositivo fisico (iPhone/Android real): usa la IP LAN del laptop via
  //   --dart-define=API_BASE_URL=http://<IP_LAN>:8081
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8081',
  );
}
