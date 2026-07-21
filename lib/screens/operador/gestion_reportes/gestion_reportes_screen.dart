import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/operador_reportes_controller.dart';
import '../../../controllers/tecnicos_controller.dart';
import '../../../widgets/app_colors.dart';
import '../../../widgets/custom_toast.dart';
import '../../../widgets/foto_view.dart';
import '../../../widgets/map_view.dart';
import 'acciones_gestion.dart';
import 'reporte_detalle_card.dart';

/// Vista 02 Gestion (CU-06 aceptar/rechazar, CU-07 asignar tecnico).
class GestionReportesScreen extends StatefulWidget {
  final int reporteId;
  const GestionReportesScreen({super.key, required this.reporteId});
  @override
  State<GestionReportesScreen> createState() => _GestionReportesScreenState();
}

class _GestionReportesScreenState extends State<GestionReportesScreen> {
  final _ctrl = Get.find<OperadorReportesController>();

  @override
  void initState() {
    super.initState();
    _ctrl.iniciarGestion(widget.reporteId);
  }

  /// Recoge el motivo del usuario y delega el rechazo al controller.
  void _mostrarDialogoRechazo() {
    final motivoCtrl = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Rechazar reporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Indica el motivo. Se notificara al ciudadano.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: motivoCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Motivo del rechazo',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.estadoRechazado,
            ),
            onPressed: () async {
              final motivo = motivoCtrl.text.trim();
              if (motivo.isEmpty) {
                AppToast.error('Ingresa un motivo');
                return;
              }
              Get.back();
              final ok = await _ctrl.rechazarGestion(motivo);
              if (ok) Get.back();
            },
            child: const Text(
              'Confirmar rechazo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Carga tecnicos, muestra el selector y delega la asignacion al controller.
  void _mostrarAsignarTecnico() async {
    final tc = Get.find<TecnicosController>();
    await tc.cargar();
    Get.bottomSheet(
      Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Obx(() {
            if (tc.tecnicos.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No hay tecnicos disponibles.'),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asignar Tecnico',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'El estado se mantiene en Revision.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 12),
                ...tc.tecnicos.map(
                  (t) => ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFEFEAFF),
                      child: Icon(Icons.engineering, color: AppColors.primary),
                    ),
                    title: Text(t.nombreCompleto),
                    subtitle: const Text('Disponible'),
                    onTap: () async {
                      Get.back();
                      await _ctrl.asignarGestion(t);
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = _ctrl.reporteActual.value;
      if (r == null) {
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      }
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F8),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Gestion del Reporte'),
        ),
        body: AbsorbPointer(
          absorbing: _ctrl.busy.value,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FotosStrip(
                fotos: _ctrl.fotosIniciales,
                vacioTexto: 'Sin fotos del ciudadano',
              ),
              const SizedBox(height: 12),
              ReporteDetalleCard(reporte: r),
              const SizedBox(height: 12),
              MapPinView(
                lat: r.ubicacion.latitud,
                lng: r.ubicacion.longitud,
                color: AppColors.forEstado(r.estado),
                height: 150,
              ),
              const SizedBox(height: 16),
              AccionesGestion(
                reporte: r,
                fotosFinales: _ctrl.fotosFinales,
                onAceptar: _ctrl.aceptarGestion,
                onRechazar: _mostrarDialogoRechazo,
                onAsignar: _mostrarAsignarTecnico,
              ),
            ],
          ),
        ),
      );
    });
  }
}
