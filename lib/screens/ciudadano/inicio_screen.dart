import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/reportes_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/report_card.dart';
import '../../widgets/common/gradient_header.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _reportes.cargarReportes(_auth.cuentaId));
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _auth.usuario.value?.nombre ?? 'Ciudadano';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          GradientHeader(
            overline: 'Hola,',
            title: nombre,
            subtitle: 'Que quieres reportar hoy?',
            onLogout: () { _auth.logout(); Get.offAllNamed(AppRoutes.login); },
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _MenuCard(icon: Icons.add_circle_outline, title: 'Reportar Incidencia',
                    subtitle: 'Crea un nuevo reporte con foto y ubicacion',
                    onTap: () => Get.find<TabsController>().go(2)),
                const SizedBox(height: 12),
                _MenuCard(icon: Icons.list_alt_outlined, title: 'Mis Reportes',
                    subtitle: 'Revisa el estado de tus reportes',
                    onTap: () => Get.find<TabsController>().go(3)),
                const SizedBox(height: 18),
                const SectionLabel('RECIENTES'),
                const SizedBox(height: 10),
                Obx(() {
                  if (_reportes.loading.value) {
                    return const Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator());
                  }
                  final recientes = _reportes.recientes;
                  if (recientes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('Aun no tienes reportes. Crea el primero.', style: TextStyle(color: Color(0xFF9AA0AB))),
                    );
                  }
                  return Column(
                    children: recientes
                        .map((r) => ReportCard(reporte: r, onTap: () => Get.to(() => DetalleScreen(reporte: r))))
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
  Widget build(BuildContext context) => GestureDetector(
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
