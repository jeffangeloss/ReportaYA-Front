import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/tecnico_reportes_controller.dart';
import '../widgets/app_colors.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/report_card.dart';

class TecnicoReportesScreen extends StatefulWidget {
  const TecnicoReportesScreen({super.key});

  @override
  State<TecnicoReportesScreen> createState() => _TecnicoReportesScreenState();
}

class _TecnicoReportesScreenState extends State<TecnicoReportesScreen> {
  final TecnicoReportesController ctrl = Get.find();
  final estados = const ['PROCESO', 'RESUELTA', 'RECHAZADO_AUDITO'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.cargarReportes());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.tecnicoGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
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
                    child: Text('Mis Reportes Asignados',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
                      final sel = ctrl.filtroEstado.value == e;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => ctrl.setFiltroEstado(sel ? null : e),
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? Colors.white : Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(e, style: TextStyle(color: sel ? const Color(0xFF4CAF50) : Colors.white, fontWeight: FontWeight.bold)),
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
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)));
                  }
                  if (ctrl.error.value != null && ctrl.reportes.isEmpty) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(ctrl.error.value!, style: const TextStyle(color: Color(0xFFFF6B6B))),
                        TextButton(
                            onPressed: () => ctrl.cargarReportes(),
                            child: const Text('Toca para reintentar', style: TextStyle(color: Color(0xFF4CAF50)))),
                      ]),
                    );
                  }
                  if (ctrl.reportes.isEmpty) {
                    return const Center(child: Text('No hay reportes asignados', style: TextStyle(color: Color(0xFF999999))));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xFF4CAF50),
                          onRefresh: () => ctrl.cargarReportes(page: ctrl.currentPage.value),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: ctrl.reportes.length,
                            itemBuilder: (_, i) {
                              final r = ctrl.reportes[i];
                              final ubic = r.ubicacion.direccion ??
                                  '${r.ubicacion.latitud.toStringAsFixed(6)}, ${r.ubicacion.longitud.toStringAsFixed(6)}';
                              final fecha = _formatFecha(r.fechaCreacion);
                              return ReportCard(
                                titulo: r.titulo,
                                tipo: r.prioridad,
                                estado: r.estado,
                                fecha: fecha,
                                ubicacion: ubic,
                                onPress: () {},
                                onAtender: () {
                                  // TODO: completar reporte con fotos (futura iteración)
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        color: const Color(0xFF4CAF50),
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
    );
  }

  String _formatFecha(String iso) {
    try {
      return DateFormat('dd MMM yyyy', 'es').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
