import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/operador_reportes_controller.dart';
import '../controllers/tecnicos_controller.dart';
import '../models/enums.dart';
import '../services/servicio_asignaciones.dart';
import '../widgets/app_colors.dart';
import '../widgets/confirmation_modal.dart';
import '../widgets/custom_toast.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/tecnico_card.dart';

class AsignacionTecnicosScreen extends StatefulWidget {
  const AsignacionTecnicosScreen({super.key});

  @override
  State<AsignacionTecnicosScreen> createState() => _AsignacionTecnicosScreenState();
}

class _AsignacionTecnicosScreenState extends State<AsignacionTecnicosScreen> {
  final TecnicosController ctrl = Get.find();
  final AuthController auth = Get.find();
  late final int reporteId;
  String _prioridad = Prioridad.MEDIA;
  int? _asignandoId;
  bool _prioridadOpen = false;

  @override
  void initState() {
    super.initState();
    reporteId = Get.arguments as int;
    WidgetsBinding.instance.addPostFrameCallback((_) => ctrl.cargarTecnicos());
  }

  Future<void> _asignar(int tecnicoId, String nombre) async {
    final ok = await ConfirmationModal.show(
      title: 'Confirmar Asignación',
      message: '¿Asignar el reporte #$reporteId al técnico $nombre?',
      confirmText: 'Asignar',
    );
    if (ok != true) return;

    final operadorId = auth.usuario.value?.id;
    if (operadorId == null) {
      AppToast.error('Información de usuario incompleta');
      return;
    }
    setState(() => _asignandoId = tecnicoId);
    try {
      await ServicioAsignaciones().crearAsignacion(
        reporteId: reporteId,
        operadorId: operadorId,
        tecnicoId: tecnicoId,
        prioridad: _prioridad,
      );
      try {
        Get.find<OperadorReportesController>()
            .actualizarEstadoReporte(reporteId, EstadoReporte.PROCESO);
      } catch (_) {}
      AppToast.success('Técnico asignado correctamente');
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.back();
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _asignandoId = null);
    }
  }

  static const _opciones = [
    {'label': '🟢 Baja', 'value': Prioridad.BAJA},
    {'label': '🟡 Media', 'value': Prioridad.MEDIA},
    {'label': '🔴 Alta', 'value': Prioridad.ALTA},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.ciudadanoGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Asignar Técnico',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Reporte #$reporteId', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selecciona Prioridad:',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => setState(() => _prioridadOpen = !_prioridadOpen),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _opciones.firstWhere((o) => o['value'] == _prioridad)['label']!,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          Icon(_prioridadOpen ? Icons.expand_less : Icons.expand_more, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  if (_prioridadOpen)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: _opciones.map((o) {
                          final sel = _prioridad == o['value'];
                          return InkWell(
                            onTap: () => setState(() {
                              _prioridad = o['value']!;
                              _prioridadOpen = false;
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              color: sel ? const Color(0xFFF0EAFF) : Colors.transparent,
                              child: Text(o['label']!,
                                  style: TextStyle(color: sel ? const Color(0xFFA27EFF) : Colors.black87)),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: Obx(() {
                  if (ctrl.loading.value && ctrl.tecnicos.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFA27EFF)));
                  }
                  if (ctrl.error.value != null && ctrl.tecnicos.isEmpty) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(ctrl.error.value!, style: const TextStyle(color: Color(0xFFFF6B6B))),
                        TextButton(
                            onPressed: () => ctrl.cargarTecnicos(),
                            child: const Text('Toca para reintentar', style: TextStyle(color: Color(0xFFA27EFF)))),
                      ]),
                    );
                  }
                  if (ctrl.tecnicos.isEmpty) {
                    return const Center(child: Text('No hay técnicos disponibles', style: TextStyle(color: Color(0xFF999999))));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: ctrl.tecnicos.length,
                          itemBuilder: (_, i) {
                            final t = ctrl.tecnicos[i];
                            return TecnicoCard(
                              nombre: t.nombreCompleto,
                              especialidad: 'Técnico Municipal',
                              asignando: _asignandoId == t.id,
                              onAsignar: () => _asignar(t.id, t.nombreCompleto),
                            );
                          },
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
    );
  }
}
