import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/gradient_scaffold.dart';

/// Placeholder para los roles que se construyen en las Fases 2 y 3.
class ComingSoonScreen extends StatelessWidget {
  final String titulo;
  final List<Color> colors;
  const ComingSoonScreen({super.key, required this.titulo, required this.colors});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      colors: colors,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build_circle_outlined, color: Colors.white, size: 64),
            const SizedBox(height: 16),
            Text(titulo,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('Disponible en la siguiente fase',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                Get.find<AuthController>().logout();
                Get.offAllNamed(AppRoutes.login);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text('Cerrar sesion', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
