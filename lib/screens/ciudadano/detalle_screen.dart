import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/servicio_reportes.dart';
import '../../utils/fechas.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/estado_pill.dart';
import '../../widgets/foto_view.dart';
import '../../widgets/common/gradient_header.dart';
import '../../widgets/common/detail_widgets.dart';

/// Vista 05 Detalle (CU-05). El contenido varia segun el estado del reporte.
class DetalleScreen extends StatefulWidget {
  final ReporteResponse reporte;
  const DetalleScreen({super.key, required this.reporte});
  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _service = ServicioReportes();
  List<HistorialEstado> _historial = [];
  List<Foto> _fotos = [];
  bool _loading = true;

  ReporteResponse get r => widget.reporte;
  List<Foto> get _iniciales => _fotos.where((f) => f.tipo == TipoFoto.INICIAL).toList();
  List<Foto> get _finales => _fotos.where((f) => f.tipo == TipoFoto.FINAL).toList();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final h = await _service.obtenerHistorialEstados(r.id);
    final f = await _service.obtenerFotos(r.id);
    if (mounted) setState(() { _historial = h; _fotos = f; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Reporte #${r.id}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                FotosStrip(fotos: _iniciales, vacioTexto: 'Sin fotos del incidente'),
                const SizedBox(height: 12),
                Row(children: [EstadoPill(r.estado)]),
                const SizedBox(height: 12),
                WhiteCard([
                  KeyValue('Descripcion', r.descripcion),
                  KeyValue('Tipo', TipoProblema.label(r.tipoProblema)),
                  KeyValue('Direccion', r.ubicacion.direccion ?? 'Sin direccion'),
                  KeyValue('Ultima actualizacion', fmtFechaHora(r.fechaActualizacion)),
                  ..._extraPorEstado(),
                ]),
                const SizedBox(height: 16),
                const SectionLabel('CRONOLOGIA'),
                const SizedBox(height: 10),
                _timeline(),
              ],
            ),
    );
  }

  List<Widget> _extraPorEstado() {
    switch (r.estado) {
      case EstadoReporte.PENDIENTE:
        return [const SizedBox(height: 8), const InfoCallout('Tu reporte esta pendiente de revision por la oficina municipal.')];
      case EstadoReporte.REVISION:
        return [KeyValue('Tecnico asignado', r.tieneTecnico ? r.tecnicoNombre! : 'Sin asignar tecnico')];
      case EstadoReporte.FINALIZADO:
        return [
          KeyValue('Tecnico asignado', r.tecnicoNombre ?? '-'),
          KeyValue('Comentario de resolucion', r.comentarioResolucion ?? '-'),
          const SizedBox(height: 8),
          const Text('Fotos de resolucion', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          FotosStrip(fotos: _finales, vacioTexto: 'Sin fotos de resolucion'),
        ];
      case EstadoReporte.RECHAZADO:
        return [const SizedBox(height: 8), InfoCallout('Motivo del rechazo: ${r.comentarioResolucion ?? '-'}')];
      default:
        return [];
    }
  }

  Widget _timeline() {
    if (_historial.isEmpty) {
      return const Text('Sin cambios de estado', style: TextStyle(color: Color(0xFF9AA0AB)));
    }
    return WhiteCard(_historial.map((h) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 12, height: 12, margin: const EdgeInsets.only(top: 3),
              decoration: BoxDecoration(color: AppColors.forEstado(h.estadoNuevo), shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppColors.textoEstado(h.estadoNuevo), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  Text(fmtFechaHora(h.fechaCambio), style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList());
  }
}
