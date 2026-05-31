import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/tecnico_reportes_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/report_card.dart';
import 'ejecutar_reporte_screen.dart';

/// Vista 01 Mis asignaciones (CU-08).
class HomeScreenTecnico extends StatefulWidget {
  const HomeScreenTecnico({super.key});
  @override
  State<HomeScreenTecnico> createState() => _HomeScreenTecnicoState();
}

class _HomeScreenTecnicoState extends State<HomeScreenTecnico> {
  final _auth = Get.find<AuthController>();
  final _ctrl = Get.find<TecnicoReportesController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.cargar(_auth.cuentaId));
  }

  @override
  Widget build(BuildContext context) {
    final nombre = _auth.usuario.value?.nombre ?? 'Tecnico';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 22),
            width: double.infinity,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.tecnicoGradient)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hola,', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          Text(nombre, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Tienes ${_ctrl.porAtender} reporte(s) por atender',
                              style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      )),
                ),
                IconButton(
                  onPressed: () { _auth.logout(); Get.offAllNamed(AppRoutes.login); },
                  icon: const Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -14),
            child: Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _contador('Por atender', _ctrl.porAtender, AppColors.estadoRevision),
                      const SizedBox(width: 10),
                      _contador('Resueltos', _ctrl.resueltos, AppColors.estadoFinalizado),
                    ],
                  ),
                )),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 8),
              child: Text('MIS ASIGNACIONES',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.tecnicoPrimary, letterSpacing: 1)),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_ctrl.loading.value) return const Center(child: CircularProgressIndicator());
              final list = _ctrl.pendientes;
              if (list.isEmpty) {
                return const Center(child: Text('No tienes reportes por atender.', style: TextStyle(color: Color(0xFF9AA0AB))));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                children: list
                    .map((r) => ReportCard(
                          reporte: r,
                          onTap: () => Get.to(() => EjecutarReporteScreen(reporteId: r.id)),
                        ))
                    .toList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _contador(String label, int n, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x11141028), blurRadius: 6, offset: Offset(0, 1))],
          ),
          child: Column(
            children: [
              Text('$n', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      );
}
