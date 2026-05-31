import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/servicio_reportes.dart';
import '../utils/fechas.dart';
import '../widgets/app_colors.dart';
import '../widgets/estado_pill.dart';

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
                _fotosStrip(TipoFoto.INICIAL),
                const SizedBox(height: 12),
                Row(children: [EstadoPill(r.estado)]),
                const SizedBox(height: 12),
                _card([
                  _kv('Descripcion', r.descripcion),
                  _kv('Tipo', TipoProblema.label(r.tipoProblema)),
                  _kv('Direccion', r.ubicacion.direccion ?? 'Sin direccion'),
                  ..._extraPorEstado(),
                ]),
                const SizedBox(height: 16),
                const Text('CRONOLOGIA',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
                const SizedBox(height: 10),
                _timeline(),
              ],
            ),
    );
  }

  List<Widget> _extraPorEstado() {
    switch (r.estado) {
      case EstadoReporte.PENDIENTE:
        return [_callout('Tu reporte esta pendiente de revision por la oficina municipal.')];
      case EstadoReporte.REVISION:
        return [_kv('Tecnico asignado', r.tieneTecnico ? r.tecnicoNombre! : 'Sin asignar tecnico')];
      case EstadoReporte.FINALIZADO:
        return [
          _kv('Tecnico asignado', r.tecnicoNombre ?? '-'),
          _kv('Comentario de resolucion', r.comentarioResolucion ?? '-'),
          const SizedBox(height: 8),
          const Text('Fotos de resolucion', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
          const SizedBox(height: 6),
          _fotosStrip(TipoFoto.FINAL),
        ];
      case EstadoReporte.RECHAZADO:
        return [_callout('Motivo del rechazo: ${r.comentarioResolucion ?? '-'}')];
      default:
        return [];
    }
  }

  Widget _fotosStrip(String tipo) {
    final fotos = _fotos.where((f) => f.tipo == tipo).toList();
    if (fotos.isEmpty) {
      return Container(
        height: 84,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xFFEDEDF2), borderRadius: BorderRadius.circular(10)),
        child: const Text('Sin fotos', style: TextStyle(color: Color(0xFF9AA0AB))),
      );
    }
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => Container(
          width: 120,
          decoration: BoxDecoration(
            color: tipo == TipoFoto.FINAL ? const Color(0xFF2F5D3A) : const Color(0xFF5B4636),
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(6),
          child: Text(fotos[i].descripcion ?? 'Foto',
              style: const TextStyle(color: Colors.white, fontSize: 10)),
        ),
      ),
    );
  }

  Widget _timeline() {
    if (_historial.isEmpty) {
      return const Text('Sin cambios de estado', style: TextStyle(color: Color(0xFF9AA0AB)));
    }
    return _card(_historial.map((h) {
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
                  Text(AppColors.textoEstado(h.estadoNuevo),
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                  Text(fmtFechaHora(h.fechaCambio),
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList());
  }

  Widget _card(List<Widget> children) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(k, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
            const SizedBox(height: 2),
            Text(v, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Widget _callout(String text) => Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: const Color(0xFFEFEAFF),
          borderRadius: BorderRadius.circular(10),
          border: const Border(left: BorderSide(color: AppColors.primary, width: 3)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12.5, color: Color(0xFF4A3F7A))),
      );
}
