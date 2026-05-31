import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/operador_reportes_controller.dart';
import '../models/enums.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/report_card.dart';
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

  static const _chips = <String>[
    '', EstadoReporte.PENDIENTE, EstadoReporte.REVISION,
    EstadoReporte.FINALIZADO, EstadoReporte.RECHAZADO,
  ];

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
          Container(
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 22),
            width: double.infinity,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.operadorGradient)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Panel del', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('Operador Municipal',
                          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      SizedBox(height: 2),
                      Text('Gestiona y valida reportes ciudadanos',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
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
                      _contador('Pendientes', _ctrl.pendientes, AppColors.estadoPendiente),
                      const SizedBox(width: 10),
                      _contador('En revision', _ctrl.enRevision, AppColors.estadoRevision),
                      const SizedBox(width: 10),
                      _contador('Finalizados', _ctrl.finalizados, AppColors.estadoFinalizado),
                    ],
                  ),
                )),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 8),
              child: Text('COLA DE REPORTES',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
            ),
          ),
          SizedBox(
            height: 44,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: _chips.map((c) {
                    final on = _filtro.value == c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.isEmpty ? 'Todos' : AppColors.textoEstado(c)),
                        selected: on,
                        onSelected: (_) => _filtro.value = c,
                        selectedColor: c.isEmpty ? AppColors.primary : AppColors.forEstado(c),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(color: on ? Colors.white : const Color(0xFF5B5F6B), fontWeight: FontWeight.w600),
                      ),
                    );
                  }).toList(),
                )),
          ),
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

  Widget _contador(String label, int n, Color color) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Color(0x11141028), blurRadius: 6, offset: Offset(0, 1))],
          ),
          child: Column(
            children: [
              Text('$n', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      );
}
