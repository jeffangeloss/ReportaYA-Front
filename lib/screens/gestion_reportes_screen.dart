import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/operador_reportes_controller.dart';
import '../controllers/tecnicos_controller.dart';
import '../models/models.dart';
import '../utils/fechas.dart';
import '../widgets/app_colors.dart';
import '../widgets/custom_toast.dart';
import '../widgets/estado_pill.dart';

/// Vista 02 Gestion (CU-06 aceptar/rechazar, CU-07 asignar tecnico).
class GestionReportesScreen extends StatefulWidget {
  final int reporteId;
  const GestionReportesScreen({super.key, required this.reporteId});
  @override
  State<GestionReportesScreen> createState() => _GestionReportesScreenState();
}

class _GestionReportesScreenState extends State<GestionReportesScreen> {
  final _ctrl = Get.find<OperadorReportesController>();
  late ReporteResponse r;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    r = _ctrl.reportes.firstWhere((x) => x.id == widget.reporteId);
  }

  Future<void> _aceptar() async {
    setState(() => _busy = true);
    final upd = await _ctrl.aceptar(r.id);
    setState(() { r = upd; _busy = false; });
    AppToast.success('Reporte aceptado. Ahora en Revision.');
  }

  void _rechazar() {
    final motivoCtrl = TextEditingController();
    Get.dialog(AlertDialog(
      title: const Text('Rechazar reporte'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Indica el motivo. Se notificara al ciudadano.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 10),
          TextField(
            controller: motivoCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Motivo del rechazo',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.estadoRechazado),
          onPressed: () async {
            final motivo = motivoCtrl.text.trim();
            if (motivo.isEmpty) { AppToast.error('Ingresa un motivo'); return; }
            Get.back();
            setState(() => _busy = true);
            await _ctrl.rechazar(r.id, motivo);
            AppToast.success('Reporte rechazado.');
            Get.back(); // volver a la cola
          },
          child: const Text('Confirmar rechazo', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _asignar() async {
    final tc = Get.find<TecnicosController>();
    await tc.cargar();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
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
              const Text('Asignar Tecnico',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('El estado se mantiene en Revision.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280))),
              const SizedBox(height: 12),
              ...tc.tecnicos.map((t) => ListTile(
                    leading: const CircleAvatar(backgroundColor: Color(0xFFEFEAFF), child: Icon(Icons.engineering, color: AppColors.primary)),
                    title: Text(t.nombreCompleto),
                    subtitle: const Text('Disponible'),
                    onTap: () async {
                      Get.back();
                      setState(() => _busy = true);
                      final upd = await _ctrl.asignar(r.id, t);
                      setState(() { r = upd; _busy = false; });
                      AppToast.success('Tecnico asignado: ${t.nombreCompleto}');
                    },
                  )),
            ],
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esPendiente = r.estado == EstadoReporte.PENDIENTE;
    final esRevision = r.estado == EstadoReporte.REVISION;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Gestion del Reporte'),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [EstadoPill(r.estado), const Spacer(), Text('#${r.id}', style: const TextStyle(color: Color(0xFF9AA0AB)))]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Icon(AppColors.iconoTipo(r.tipoProblema), color: AppColors.forEstado(r.estado)),
                    const SizedBox(width: 6),
                    Expanded(child: Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
                  ]),
                  const SizedBox(height: 4),
                  Text('${r.ubicacion.direccion ?? ''} - ${fmtFecha(r.fechaCreacion)}',
                      style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  Text(r.descripcion, style: const TextStyle(fontSize: 13.5)),
                  const Divider(height: 24),
                  _kv('Tipo', TipoProblema.label(r.tipoProblema)),
                  _kv('Reportado por', r.nombreCiudadano ?? '-'),
                  _kv('Tecnico asignado', r.tieneTecnico ? r.tecnicoNombre! : 'Sin tecnico asignado'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (esPendiente) ...[
              _btn('Aceptar reporte', AppColors.estadoFinalizado, _aceptar, icon: Icons.check),
              const SizedBox(height: 10),
              _btnOutline('Rechazar reporte', AppColors.estadoRechazado, _rechazar, icon: Icons.close),
            ] else if (esRevision) ...[
              _callout(r.tieneTecnico
                  ? 'Reporte en Revision. Tecnico asignado: ${r.tecnicoNombre}.'
                  : 'Reporte aceptado y en Revision. Falta asignar tecnico (CU-07).'),
              const SizedBox(height: 10),
              _btn(r.tieneTecnico ? 'Reasignar Tecnico' : 'Asignar Tecnico', AppColors.estadoFinalizado, _asignar, icon: Icons.person_add_alt),
            ] else if (r.estado == EstadoReporte.FINALIZADO)
              _callout('Reporte finalizado por ${r.tecnicoNombre ?? 'el tecnico'}.')
            else if (r.estado == EstadoReporte.RECHAZADO)
              _callout('Rechazado: ${r.comentarioResolucion ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
            Text(v, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _btn(String text, Color color, VoidCallback onTap, {IconData? icon}) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: color, padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onTap,
          icon: Icon(icon, color: Colors.white, size: 20),
          label: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      );

  Widget _btnOutline(String text, Color color, VoidCallback onTap, {IconData? icon}) => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: color, side: BorderSide(color: color),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ),
      );

  Widget _callout(String text) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEAFF),
          borderRadius: BorderRadius.circular(12),
          border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF4A3F7A))),
      );
}
