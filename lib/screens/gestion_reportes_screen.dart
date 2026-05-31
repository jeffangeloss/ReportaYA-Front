import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/operador_reportes_controller.dart';
import '../controllers/tecnicos_controller.dart';
import '../models/enums.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/confirmation_modal.dart';
import '../widgets/custom_toast.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/rejection_modal.dart';
import '../widgets/report_card_operador.dart';

class GestionReportesScreen extends StatefulWidget {
  const GestionReportesScreen({super.key});

  @override
  State<GestionReportesScreen> createState() => _GestionReportesScreenState();
}

class _GestionReportesScreenState extends State<GestionReportesScreen> {
  final OperadorReportesController ctrl = Get.find();
  final TecnicosController tecnicosCtrl = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.cargarReportes());
  }

  final estados = const ['TODOS', ...EstadoReporte.values];

  Future<void> _onCambiarEstado(int reporteId) async {
    final ok = await ConfirmationModal.show(
      title: 'Cambiar Estado',
      message: '¿Cambiar el estado del reporte a "EN REVISIÓN"?',
    );
    if (ok != true) return;
    try {
      await ctrl.cambiarEstadoARevision(reporteId);
      AppToast.success('Estado actualizado a "En Revisión"');
    } catch (_) {
      AppToast.error('Error al cambiar estado');
    }
  }

  Future<void> _onRechazar(int reporteId) async {
    final motivo = await RejectionModal.show();
    if (motivo == null) return;
    try {
      await ctrl.rechazarReporte(reporteId, motivo);
      AppToast.success('Reporte rechazado correctamente');
    } catch (_) {
      AppToast.error('Error al rechazar reporte');
    }
  }

  Future<void> _onAsignar(int reporteId) async {
    try {
      await tecnicosCtrl.cargarTecnicos();
    } catch (_) {}
    Get.toNamed(AppRoutes.asignacionTecnicos, arguments: reporteId);
  }

  void _onAuditar(int reporteId) {
    Get.toNamed(AppRoutes.auditarReporte, arguments: reporteId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.ciudadanoGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
                  const Expanded(
                    child: Text('Gestión de Reportes',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: () => ctrl.cargarReportes(page: ctrl.currentPage.value),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: Obx(() => ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: estados.map((e) {
                      final sel = (e == 'TODOS' && ctrl.filtroEstado.value == null) ||
                          ctrl.filtroEstado.value == e;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => ctrl.setFiltroEstado(e == 'TODOS' ? null : e),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? Colors.white : Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(e, style: TextStyle(color: sel ? const Color(0xFFA27EFF) : Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Obx(() {
                  if (ctrl.loading.value && ctrl.reportes.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFA27EFF)));
                  }
                  if (ctrl.error.value != null && ctrl.reportes.isEmpty) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(ctrl.error.value!, style: const TextStyle(color: Color(0xFFFF6B6B))),
                        TextButton(
                            onPressed: () => ctrl.cargarReportes(),
                            child: const Text('Toca para reintentar', style: TextStyle(color: Color(0xFFA27EFF)))),
                      ]),
                    );
                  }
                  if (ctrl.reportes.isEmpty) {
                    return const Center(child: Text('No hay reportes disponibles', style: TextStyle(color: Color(0xFF999999))));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xFFA27EFF),
                          onRefresh: () => ctrl.cargarReportes(page: ctrl.currentPage.value),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: ctrl.reportes.length,
                            itemBuilder: (_, i) {
                              final r = ctrl.reportes[i];
                              final ubic = r.ubicacion.direccion ??
                                  '${r.ubicacion.latitud.toStringAsFixed(6)}, ${r.ubicacion.longitud.toStringAsFixed(6)}';
                              final fecha = _formatFecha(r.fechaCreacion);
                              return ReportCardOperador(
                                titulo: r.titulo,
                                tipo: r.prioridad,
                                estado: r.estado,
                                fecha: fecha,
                                ubicacion: ubic,
                                onCambiarEstado: () => _onCambiarEstado(r.id),
                                onAsignarTecnico: () => _onAsignar(r.id),
                                onAuditar: () => _onAuditar(r.id),
                                onRechazar: () => _onRechazar(r.id),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        color: const Color(0xFFA27EFF),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: PaginationFooter(
                          currentPage: ctrl.currentPage.value,
                          totalPages: ctrl.totalPages.value,
                          loading: ctrl.loading.value,
                          onPrev: () => ctrl.prevPage(),
                          onNext: () => ctrl.nextPage(),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  String _formatFecha(String iso) {
    try {
      return DateFormat('dd MMM yyyy', 'es').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
