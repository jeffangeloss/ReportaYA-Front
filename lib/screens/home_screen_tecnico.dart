import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/confirmation_modal.dart';
import '../widgets/gradient_scaffold.dart';

class HomeScreenTecnico extends StatelessWidget {
  const HomeScreenTecnico({super.key});

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
      colors: AppColors.tecnicoGradient,
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
                        const Text('Panel de Técnico',
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
            InkWell(
              onTap: () => Get.toNamed(AppRoutes.tecnicoReportes),
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
                      decoration: const BoxDecoration(color: Color(0xFFE8F5E9), shape: BoxShape.circle),
                      child: const Icon(Icons.description_outlined, size: 36, color: Color(0xFF4CAF50)),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reportes Asignados',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                          SizedBox(height: 4),
                          Text('Ver y ejecutar los reportes que te han sido asignados.',
                              style: TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.3)),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
