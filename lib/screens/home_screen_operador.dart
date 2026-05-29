import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/confirmation_modal.dart';
import '../widgets/gradient_scaffold.dart';

class HomeScreenOperador extends StatelessWidget {
  const HomeScreenOperador({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    Future<void> handleLogout() async {
      final ok = await ConfirmationModal.show(
        title: 'Cerrar Sesión',
        message: '¿Estás seguro de que quieres cerrar sesión?',
        confirmText: 'Cerrar Sesión',
        danger: true,
      );
      if (ok == true) {
        await auth.logout();
        Get.offAllNamed(AppRoutes.login);
      }
    }

    return GradientScaffold(
      colors: AppColors.ciudadanoGradient,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final u = auth.usuario.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Panel de Operador',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        if (u != null)
                          Text('Hola, ${u.nombre}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    );
                  }),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                  child: IconButton(icon: const Icon(Icons.logout, color: Colors.white), onPressed: handleLogout),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text('¿Qué deseas hacer hoy?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            _menuCard(
              icon: Icons.description_outlined,
              iconBg: const Color(0xFFF0EAFF),
              iconColor: const Color(0xFFA27EFF),
              title: 'Gestión de Reportes',
              description: 'Ver, asignar y gestionar los reportes ciudadanos.',
              onTap: () => Get.toNamed(AppRoutes.gestionReportes),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.3)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}
