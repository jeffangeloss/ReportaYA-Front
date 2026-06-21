import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reportes_controller.dart';
import '../../models/models.dart';
import '../../utils/fechas.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/estado_pill.dart';
import '../../widgets/foto_view.dart';
import '../../widgets/map_view.dart';
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
  final _ctrl = Get.find<ReportesController>();

  ReporteResponse get r => widget.reporte;

  @override
  void initState() {
    super.initState();
    _ctrl.cargarDetalle(r.id);
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
      body: Obx(() {
        if (_ctrl.loadingDetalle.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final iniciales = _ctrl.fotosDetalle.where((f) => f.tipo == TipoFoto.INICIAL).toList();
        final finales = _ctrl.fotosDetalle.where((f) => f.tipo == TipoFoto.FINAL).toList();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FotosStrip(fotos: iniciales, vacioTexto: 'Sin fotos del incidente'),
            const SizedBox(height: 12),
            Row(children: [EstadoPill(r.estado)]),
            const SizedBox(height: 12),
            WhiteCard([
              KeyValue('Descripcion', r.descripcion),
              KeyValue('Tipo', TipoProblema.label(r.tipoProblema)),
              KeyValue('Direccion', r.ubicacion.direccion ?? 'Sin direccion'),
              KeyValue('Ultima actualizacion', fmtFechaHora(r.fechaActualizacion)),
              ..._extraPorEstado(finales),
            ]),
            const SizedBox(height: 16),
            MapPinView(
              lat: r.ubicacion.latitud,
              lng: r.ubicacion.longitud,
              color: AppColors.forEstado(r.estado),
              height: 150,
            ),
            const SizedBox(height: 16),
            const SectionLabel('CRONOLOGIA'),
            const SizedBox(height: 10),
            _timeline(),
          ],
        );
      }),
    );
  }

  List<Widget> _extraPorEstado(List<Foto> finales) {
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
          FotosStrip(fotos: finales, vacioTexto: 'Sin fotos de resolucion'),
        ];
      case EstadoReporte.RECHAZADO:
        return [const SizedBox(height: 8), InfoCallout('Motivo del rechazo: ${r.comentarioResolucion ?? '-'}')];
      default:
        return [];
    }
  }

  Widget _timeline() {
    if (_ctrl.historial.isEmpty) {
      return const Text('Sin cambios de estado', style: TextStyle(color: Color(0xFF9AA0AB)));
    }
    return WhiteCard(_ctrl.historial.map((h) {
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
