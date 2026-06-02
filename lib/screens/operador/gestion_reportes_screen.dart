import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/operador_reportes_controller.dart';
import '../../controllers/tecnicos_controller.dart';
import '../../models/models.dart';
import '../../services/servicio_reportes.dart';
import '../../utils/fechas.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/estado_pill.dart';
import '../../widgets/foto_view.dart';
import '../../widgets/map_view.dart';
import '../../widgets/common/detail_widgets.dart';

/// Vista 02 Gestion (CU-06 aceptar/rechazar, CU-07 asignar tecnico).
class GestionReportesScreen extends StatefulWidget {
  final int reporteId;
  const GestionReportesScreen({super.key, required this.reporteId});
  @override
  State<GestionReportesScreen> createState() => _GestionReportesScreenState();
}

class _GestionReportesScreenState extends State<GestionReportesScreen> {
  final _ctrl = Get.find<OperadorReportesController>();
  final _service = ServicioReportes();
  late ReporteResponse r;
  List<Foto> _fotos = [];
  List<Foto> _fotosFinales = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    r = _ctrl.reportes.firstWhere((x) => x.id == widget.reporteId);
    _cargarFotos();
  }

  Future<void> _cargarFotos() async {
    final iniciales = await _service.obtenerFotos(r.id, tipo: TipoFoto.INICIAL);
    final finales = await _service.obtenerFotos(r.id, tipo: TipoFoto.FINAL);
    if (mounted) setState(() { _fotos = iniciales; _fotosFinales = finales; });
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
            decoration: InputDecoration(hintText: 'Motivo del rechazo', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
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
            Get.back();
          },
          child: const Text('Confirmar rechazo', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  void _asignar() async {
    final tc = Get.find<TecnicosController>();
    await tc.cargar();
    Get.bottomSheet(Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      child: Obx(() {
        if (tc.tecnicos.isEmpty) {
          return const Padding(padding: EdgeInsets.all(16), child: Text('No hay tecnicos disponibles.'));
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Asignar Tecnico', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('El estado se mantiene en Revision.', style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280))),
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
    ));
  }

  @override
  Widget build(BuildContext context) {
    final esPendiente = r.estado == EstadoReporte.PENDIENTE;
    final esRevision = r.estado == EstadoReporte.REVISION;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(backgroundColor: AppColors.primary, foregroundColor: Colors.white, title: const Text('Gestion del Reporte')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FotosStrip(fotos: _fotos, vacioTexto: 'Sin fotos del ciudadano'),
            const SizedBox(height: 12),
            WhiteCard([
              Row(children: [EstadoPill(r.estado), const Spacer(), Text('#${r.id}', style: const TextStyle(color: Color(0xFF9AA0AB)))]),
              const SizedBox(height: 8),
              Row(children: [
                Icon(AppColors.iconoTipo(r.tipoProblema), color: AppColors.forEstado(r.estado)),
                const SizedBox(width: 6),
                Expanded(child: Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
              ]),
              const SizedBox(height: 10),
              Text(r.descripcion, style: const TextStyle(fontSize: 13.5)),
              const Divider(height: 24),
              KeyValue('Tipo', TipoProblema.label(r.tipoProblema)),
              KeyValue('Direccion', r.ubicacion.direccion ?? '-'),
              KeyValue('Reportado por', r.nombreCiudadano ?? '-'),
              KeyValue('Ultima actualizacion', fmtFechaHora(r.fechaActualizacion)),
              KeyValue('Tecnico asignado', r.tieneTecnico ? r.tecnicoNombre! : 'Sin tecnico asignado'),
            ]),
            const SizedBox(height: 12),
            MapPinView(
              lat: r.ubicacion.latitud,
              lng: r.ubicacion.longitud,
              color: AppColors.forEstado(r.estado),
              height: 150,
            ),
            const SizedBox(height: 16),
            if (esPendiente) ...[
              WideButton('Aceptar reporte', AppColors.estadoFinalizado, _aceptar, icon: Icons.check),
              const SizedBox(height: 10),
              WideButton('Rechazar reporte', AppColors.estadoRechazado, _rechazar, icon: Icons.close, outline: true),
            ] else if (esRevision) ...[
              InfoCallout(r.tieneTecnico
                  ? 'Reporte en Revision. Tecnico asignado: ${r.tecnicoNombre}.'
                  : 'Reporte aceptado y en Revision. Falta asignar tecnico (CU-07).'),
              const SizedBox(height: 10),
              WideButton(r.tieneTecnico ? 'Reasignar Tecnico' : 'Asignar Tecnico', AppColors.estadoFinalizado, _asignar, icon: Icons.person_add_alt),
            ] else if (r.estado == EstadoReporte.FINALIZADO) ...[
              InfoCallout('Reporte finalizado por ${r.tecnicoNombre ?? 'el tecnico'}.', color: AppColors.estadoFinalizado, bg: const Color(0xFFEAFAF0), fg: const Color(0xFF2C7A4F)),
              if (r.comentarioResolucion != null && r.comentarioResolucion!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Comentario del tecnico', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                  child: Text(r.comentarioResolucion!, style: const TextStyle(fontSize: 13.5)),
                ),
              ],
              if (_fotosFinales.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Fotos de la solucion', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
                const SizedBox(height: 6),
                FotosStrip(fotos: _fotosFinales, vacioTexto: 'Sin fotos de resolucion', height: 96),
              ],
            ] else if (r.estado == EstadoReporte.RECHAZADO)
              InfoCallout('Rechazado: ${r.comentarioResolucion ?? '-'}', color: AppColors.estadoRechazado, bg: const Color(0xFFF3F3F5), fg: const Color(0xFF555555)),
          ],
        ),
      ),
    );
  }
}
