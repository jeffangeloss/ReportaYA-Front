import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tecnico_reportes_controller.dart';
import '../../models/models.dart';
import '../../services/servicio_reportes.dart';
import '../../utils/fechas.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/estado_pill.dart';
import '../../widgets/foto_view.dart';
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
  final _service = ServicioReportes();
  late final TabController _tabs;
  late ReporteResponse r;

  final _comentarioCtrl = TextEditingController();
  List<Foto> _fotosIniciales = [];
  int _fotos = 0;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    r = _ctrl.asignaciones.firstWhere((x) => x.id == widget.reporteId);
    _cargarFotosIniciales();
  }

  Future<void> _cargarFotosIniciales() async {
    final f = await _service.obtenerFotos(r.id, tipo: TipoFoto.INICIAL);
    if (mounted) setState(() => _fotosIniciales = f);
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
    setState(() => _busy = true);
    final urls = List.filled(_fotos, 'assets/img/sample/generic_final.png');
    await _ctrl.finalizar(r.id, _comentarioCtrl.text.trim(), urls);
    AppToast.success('Reporte finalizado!');
    await Future.delayed(const Duration(milliseconds: 500));
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
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
        absorbing: _busy,
        child: TabBarView(controller: _tabs, children: [_infoTab(), _evidenciaTab()]),
      ),
    );
  }

  Widget _infoTab() {
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
        Container(
          height: 130,
          decoration: BoxDecoration(color: const Color(0xFFE6ECEF), borderRadius: BorderRadius.circular(12)),
          child: const Center(child: Icon(Icons.place, color: AppColors.tecnicoPrimary, size: 34)),
        ),
        const SizedBox(height: 16),
        WideButton('Iniciar trabajo de campo', AppColors.tecnicoPrimary, () => _tabs.animateTo(1), icon: Icons.play_arrow),
      ],
    );
  }

  Widget _evidenciaTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Fotos del incidente',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
        const SizedBox(height: 6),
        FotosStrip(fotos: _fotosIniciales, vacioTexto: 'Sin fotos del ciudadano', height: 96),
        const SizedBox(height: 14),
        const InfoCallout(
          'Registra la evidencia de la solucion y finaliza el reporte. El ciudadano sera notificado.',
          color: AppColors.tecnicoPrimary, bg: Color(0xFFEAFAF0), fg: Color(0xFF2C7A4F),
        ),
        const SizedBox(height: 14),
        const Text('Comentarios de la solucion', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
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
        Text('Fotos de la solucion ($_fotos/5)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
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
        WideButton('Finalizar reporte', AppColors.tecnicoPrimary, _busy ? null : _finalizar, icon: Icons.check),
      ],
    );
  }
}
