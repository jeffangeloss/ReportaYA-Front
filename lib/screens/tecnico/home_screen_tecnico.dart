import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/tecnico_reportes_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/report_card.dart';
import '../../widgets/common/gradient_header.dart';
import '../../widgets/common/counter_card.dart';
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
          Obx(() => GradientHeader(
                overline: 'Hola,',
                title: nombre,
                subtitle: 'Tienes ${_ctrl.porAtender} reporte(s) por atender',
                gradient: AppColors.tecnicoGradient,
                onLogout: () { _auth.logout(); Get.offAllNamed(AppRoutes.login); },
              )),
          Obx(() => CountersRow(children: [
                CounterCard(label: 'Por atender', value: _ctrl.porAtender, color: AppColors.estadoRevision),
                CounterCard(label: 'Resueltos', value: _ctrl.resueltos, color: AppColors.estadoFinalizado),
              ])),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 0, 8),
            child: SectionLabel('MIS ASIGNACIONES', color: AppColors.tecnicoPrimary),
          ),
          Expanded(
            child: Obx(() {
              if (_ctrl.loading.value) return const Center(child: CircularProgressIndicator());
              final pendientes = _ctrl.pendientes;
              final completados = _ctrl.completados;
              if (pendientes.isEmpty && completados.isEmpty) {
                return const Center(child: Text('No tienes reportes asignados.', style: TextStyle(color: Color(0xFF9AA0AB))));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                children: [
                  if (pendientes.isNotEmpty) ...[
                    ...pendientes.map((r) => ReportCard(
                          reporte: r,
                          usarFechaActualizacion: true,
                          onTap: () => Get.to(() => EjecutarReporteScreen(reporteId: r.id)),
                        )),
                  ] else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('No tienes reportes por atender.', style: TextStyle(color: Color(0xFF9AA0AB))),
                    ),
                  if (completados.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(8, 16, 0, 8),
                      child: SectionLabel('RESUELTOS', color: AppColors.estadoFinalizado),
                    ),
                    ...completados.map((r) => ReportCard(
                          reporte: r,
                          usarFechaActualizacion: true,
                          onTap: () => Get.to(() => EjecutarReporteScreen(reporteId: r.id)),
                        )),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
