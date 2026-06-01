import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/operador_reportes_controller.dart';
import '../../models/enums.dart';
import '../../routes/app_routes.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/report_card.dart';
import '../../widgets/common/gradient_header.dart';
import '../../widgets/common/counter_card.dart';
import '../../widgets/common/estado_chips.dart';
import 'gestion_reportes_screen.dart';

/// Vista 01 Cola de reportes (CU-06 / CU-07).
class HomeScreenOperador extends StatefulWidget {
  const HomeScreenOperador({super.key});
  @override
  State<HomeScreenOperador> createState() => _HomeScreenOperadorState();
}

class _HomeScreenOperadorState extends State<HomeScreenOperador> {
  final _auth = Get.find<AuthController>();
  final _ctrl = Get.find<OperadorReportesController>();
  final RxString _filtro = ''.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.cargar());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: Column(
        children: [
          GradientHeader(
            overline: 'Panel del',
            title: 'Operador Municipal',
            subtitle: 'Gestiona y valida reportes ciudadanos',
            gradient: AppColors.operadorGradient,
            onLogout: () { _auth.logout(); Get.offAllNamed(AppRoutes.login); },
          ),
          Obx(() => CountersRow(children: [
                CounterCard(label: 'Pendientes', value: _ctrl.pendientes, color: AppColors.estadoPendiente),
                CounterCard(label: 'En revision', value: _ctrl.enRevision, color: AppColors.estadoRevision),
                CounterCard(label: 'Finalizados', value: _ctrl.finalizados, color: AppColors.estadoFinalizado),
              ])),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 0, 8),
            child: SectionLabel('COLA DE REPORTES'),
          ),
          Obx(() => EstadoFilterChips(selected: _filtro.value, onSelected: (c) => _filtro.value = c)),
          Expanded(
            child: Obx(() {
              if (_ctrl.loading.value) return const Center(child: CircularProgressIndicator());
              final list = _ctrl.filtrar(_filtro.value);
              if (list.isEmpty) {
                return const Center(child: Text('No hay reportes en este estado.', style: TextStyle(color: Color(0xFF9AA0AB))));
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                children: list
                    .map((r) => ReportCard(
                          reporte: r,
                          mostrarTecnico: r.estado == EstadoReporte.REVISION,
                          usarFechaActualizacion: true,
                          onTap: () => Get.to(() => GestionReportesScreen(reporteId: r.id)),
                        ))
                    .toList(),
              );
            }),
          ),
        ],
      ),
    );
  }
}
