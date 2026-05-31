import 'package:get/get.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main_tabs.dart';
import '../screens/home_screen_operador.dart';
import '../screens/coming_soon_screen.dart';
import '../widgets/app_colors.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String mainTabs = '/main';
  static const String homeOperador = '/operador';
  static const String homeTecnico = '/tecnico';

  static List<GetPage> get pages => [
        GetPage(name: splash, page: () => const SplashScreen()),
        GetPage(name: login, page: () => const LoginScreen()),
        GetPage(name: register, page: () => const RegisterScreen()),
        GetPage(name: mainTabs, page: () => const MainTabs()),
        GetPage(name: homeOperador, page: () => const HomeScreenOperador()),
        // Fase 3: reemplaza este placeholder.
        GetPage(
          name: homeTecnico,
          page: () => const ComingSoonScreen(
            titulo: 'Panel del Tecnico',
            colors: AppColors.tecnicoGradient,
          ),
        ),
      ];
}
