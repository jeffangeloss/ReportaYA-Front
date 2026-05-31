import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/reportes_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/report_card.dart';
import 'detalle_screen.dart';
import 'main_tabs.dart';

/// Vista 02 Inicio (CU-05). Saludo, accesos y reportes recientes.
class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _auth = Get.find<AuthController>();
  final _reportes = Get.find<ReportesController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportes.cargarReportes(_auth.cuentaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _auth.usuario.value?.nombre ?? 'Ciudadano';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 26),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: AppColors.ciudadanoGradient),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hola,', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text(nombre,
                          style: const TextStyle(color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      const Text('Que quieres reportar hoy?',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _auth.logout();
                    Get.offAllNamed(AppRoutes.login);
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _MenuCard(
                  icon: Icons.add_circle_outline,
                  title: 'Reportar Incidencia',
                  subtitle: 'Crea un nuevo reporte con foto y ubicacion',
                  onTap: () => Get.find<TabsController>().go(2),
                ),
                const SizedBox(height: 12),
                _MenuCard(
                  icon: Icons.list_alt_outlined,
                  title: 'Mis Reportes',
                  subtitle: 'Revisa el estado de tus reportes',
                  onTap: () => Get.find<TabsController>().go(3),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('RECIENTES',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
                ),
                const SizedBox(height: 10),
                Obx(() {
                  if (_reportes.loading.value) {
                    return const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator());
                  }
                  final recientes = _reportes.recientes;
                  if (recientes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aun no tienes reportes. Crea el primero.',
                          style: TextStyle(color: Color(0xFF9AA0AB))),
                    );
                  }
                  return Column(
                    children: recientes
                        .map((r) => ReportCard(
                              reporte: r,
                              onTap: () => Get.to(() => DetalleScreen(reporte: r)),
                            ))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x11141028), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: const Color(0xFFEFEAFF), borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC4C4CF)),
          ],
        ),
      ),
    );
  }
}
