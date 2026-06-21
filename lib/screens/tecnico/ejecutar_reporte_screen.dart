import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tecnico_reportes_controller.dart';
import '../../models/models.dart';
import '../../utils/fechas.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/estado_pill.dart';
import '../../widgets/foto_view.dart';
import '../../widgets/map_view.dart';
import '../../widgets/common/detail_widgets.dart';

/// Vistas 02 Informacion y 03 Evidencia (CU-08), en pestanas.
class EjecutarReporteScreen extends StatefulWidget {
  final int reporteId;
  const EjecutarReporteScreen({super.key, required this.reporteId});
  @override
  State<EjecutarReporteScreen> createState() => _EjecutarReporteScreenState();
}

class _EjecutarReporteScreenState extends State<EjecutarReporteScreen>
    with SingleTickerProviderStateMixin {
  final _ctrl = Get.find<TecnicoReportesController>();
  late final TabController _tabs;

  final _comentarioCtrl = TextEditingController();
  int _fotos = 0;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _ctrl.iniciarEjecucion(widget.reporteId);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _finalizar() async {
    if (_comentarioCtrl.text.trim().isEmpty) {
      AppToast.error('Escribe el comentario de la solucion');
      return;
    }
    final urls = List.filled(_fotos, 'assets/img/sample/generic_final.png');
    await _ctrl.finalizarGestion(_comentarioCtrl.text.trim(), urls);
    await Future.delayed(const Duration(milliseconds: 500));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = _ctrl.reporteActual.value;
      if (r == null) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return Scaffold(
        backgroundColor: const Color(0xFFF4F4F8),
        appBar: AppBar(
          backgroundColor: AppColors.tecnicoPrimary,
          foregroundColor: Colors.white,
          title: const Text('Ejecutar Reporte'),
          bottom: TabBar(
            controller: _tabs,
            indicatorColor: Colors.white,
            tabs: const [Tab(text: 'Informacion'), Tab(text: 'Evidencia')],
          ),
        ),
        body: AbsorbPointer(
          absorbing: _ctrl.busy.value,
          child: TabBarView(
            controller: _tabs,
            children: [_infoTab(r), _evidenciaTab(r)],
          ),
        ),
      );
    });
  }

  Widget _infoTab(ReporteResponse r) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        WhiteCard([
          Row(children: [EstadoPill(r.estado), const Spacer(), Text('#${r.id}', style: const TextStyle(color: Color(0xFF9AA0AB)))]),
          const SizedBox(height: 8),
          Row(children: [
            Icon(AppColors.iconoTipo(r.tipoProblema), color: AppColors.tecnicoPrimary),
            const SizedBox(width: 6),
            Expanded(child: Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17))),
          ]),
          const Divider(height: 22),
          KeyValue('Descripcion', r.descripcion),
          KeyValue('Direccion', r.ubicacion.direccion ?? '-'),
          KeyValue('Reportado por', '${r.nombreCiudadano ?? '-'} - ${fmtFecha(r.fechaCreacion)}'),
        ]),
        const SizedBox(height: 14),
        MapPinView(
          lat: r.ubicacion.latitud,
          lng: r.ubicacion.longitud,
          color: AppColors.tecnicoPrimary,
          height: 150,
        ),
        const SizedBox(height: 16),
        if (r.estado != EstadoReporte.FINALIZADO)
          WideButton('Iniciar trabajo de campo', AppColors.tecnicoPrimary, () => _tabs.animateTo(1), icon: Icons.play_arrow)
        else
          InfoCallout('Reporte ya finalizado. Consulta el tab Evidencia para ver los detalles.',
              color: AppColors.estadoFinalizado, bg: const Color(0xFFEAFAF0), fg: const Color(0xFF2C7A4F)),
      ],
    );
  }

  Widget _evidenciaTab(ReporteResponse r) {
    final esFinalizado = r.estado == EstadoReporte.FINALIZADO;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Fotos del incidente',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
        const SizedBox(height: 6),
        FotosStrip(fotos: _ctrl.fotosIniciales, vacioTexto: 'Sin fotos del ciudadano', height: 96),
        const SizedBox(height: 14),
        if (esFinalizado) ...[
          const InfoCallout('Reporte finalizado. A continuacion se muestra la resolucion registrada.',
              color: AppColors.estadoFinalizado, bg: Color(0xFFEAFAF0), fg: Color(0xFF2C7A4F)),
          const SizedBox(height: 14),
          const Text('Comentario de la solucion',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            child: Text(r.comentarioResolucion ?? '-', style: const TextStyle(fontSize: 13.5)),
          ),
          const SizedBox(height: 14),
          const Text('Fotos de la solucion',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
          const SizedBox(height: 6),
          FotosStrip(fotos: _ctrl.fotosFinales, vacioTexto: 'Sin fotos de resolucion', height: 96),
        ] else ...[
          const InfoCallout(
            'Registra la evidencia de la solucion y finaliza el reporte. El ciudadano sera notificado.',
            color: AppColors.tecnicoPrimary, bg: Color(0xFFEAFAF0), fg: Color(0xFF2C7A4F),
          ),
          const SizedBox(height: 14),
          const Text('Comentarios de la solucion',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
          const SizedBox(height: 6),
          TextField(
            controller: _comentarioCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Describe el trabajo realizado',
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 14),
          Text('Fotos de la solucion ($_fotos/5)',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
          const SizedBox(height: 6),
          Row(
            children: [
              ...List.generate(_fotos, (i) => Container(
                    width: 56, height: 56, margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(color: const Color(0xFF2F5D3A), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.image, color: Colors.white54, size: 20),
                  )),
              if (_fotos < 5)
                GestureDetector(
                  onTap: () => setState(() => _fotos++),
                  child: Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(color: const Color(0xFFEDEDF2), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.add, color: Color(0xFF9AA0AB)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 22),
          WideButton('Finalizar reporte', AppColors.tecnicoPrimary, _ctrl.busy.value ? null : _finalizar, icon: Icons.check),
        ],
      ],
    );
  }
}
