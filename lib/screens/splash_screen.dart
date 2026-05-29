import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/enums.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAuth());
  }

  void _checkAuth() {
    final auth = Get.find<AuthController>();
    void route(AuthState state) {
      if (state == AuthState.authenticated) {
        final u = auth.usuario.value;
        if (u == null) return;
        switch (u.tipoCuenta) {
          case TipoCuenta.OPERADOR_MUNICIPAL:
            Get.offAllNamed(AppRoutes.homeOperador);
            break;
          case TipoCuenta.TECNICO:
            Get.offAllNamed(AppRoutes.homeTecnico);
            break;
          default:
            Get.offAllNamed(AppRoutes.mainTabs);
        }
      } else if (state == AuthState.unauthenticated) {
        Get.offAllNamed(AppRoutes.login);
      }
    }

    if (auth.estado.value != AuthState.checking) {
      route(auth.estado.value);
      return;
    }
    ever<AuthState>(auth.estado, route);
  }

  @override
  Widget build(BuildContext context) {
    return const GradientScaffold(
      colors: AppColors.ciudadanoGradient,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ReportaYA',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
