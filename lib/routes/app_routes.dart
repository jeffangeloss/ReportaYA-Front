import 'package:get/get.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_tabs.dart';
import '../screens/home_screen_operador.dart';
import '../screens/home_screen_tecnico.dart';
import '../screens/gestion_reportes_screen.dart';
import '../screens/tecnico_reportes_screen.dart';
import '../screens/asignacion_tecnicos_screen.dart';
import '../screens/auditar_reporte_screen.dart';
import '../screens/historial_screen.dart';
import '../screens/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainTabs = '/main';
  static const String homeOperador = '/operador';
  static const String homeTecnico = '/tecnico';
  static const String gestionReportes = '/gestion-reportes';
  static const String tecnicoReportes = '/tecnico-reportes';
  static const String asignacionTecnicos = '/asignacion-tecnicos';
  static const String auditarReporte = '/auditar-reporte';
  static const String historial = '/historial';

  static List<GetPage> get pages => [
        GetPage(name: splash, page: () => const SplashScreen()),
        GetPage(name: login, page: () => const LoginScreen()),
        GetPage(name: register, page: () => const RegisterScreen()),
        GetPage(name: mainTabs, page: () => const MainTabs()),
        GetPage(name: homeOperador, page: () => const HomeScreenOperador()),
        GetPage(name: homeTecnico, page: () => const HomeScreenTecnico()),
        GetPage(name: gestionReportes, page: () => const GestionReportesScreen()),
        GetPage(name: tecnicoReportes, page: () => const TecnicoReportesScreen()),
        GetPage(name: asignacionTecnicos, page: () => const AsignacionTecnicosScreen()),
        GetPage(name: auditarReporte, page: () => const AuditarReporteScreen()),
        GetPage(name: historial, page: () => const HistorialScreen()),
      ];
}
