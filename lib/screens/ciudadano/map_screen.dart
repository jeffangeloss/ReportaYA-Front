import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/models.dart';
import '../../services/servicio_reportes.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/common/gradient_header.dart';
import 'detalle_screen.dart';

/// Vista 06 Mapa (CU-05). Version nativa simple con leyenda de estados.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _service = ServicioReportes();
  List<ReporteResponse> _reportes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final list = await _service.obtenerParaMapa();
    if (mounted) setState(() { _reportes = list; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: Column(
        children: [
          const GradientHeader(title: 'Mapa de incidencias', compact: true),
          _leyenda(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
                    children: _reportes.map(_pinTile).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _leyenda() {
    Widget item(String estado) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.forEstado(estado), shape: BoxShape.circle)),
            const SizedBox(width: 5),
            Text(AppColors.textoEstado(estado), style: const TextStyle(fontSize: 11.5)),
          ],
        );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Wrap(spacing: 16, runSpacing: 8, children: EstadoReporte.values.map(item).toList()),
    );
  }

  Widget _pinTile(ReporteResponse r) {
    final color = AppColors.forEstado(r.estado);
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.location_on, color: color, size: 30),
        title: Text(r.titulo, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        subtitle: Text(r.ubicacion.direccion ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
          child: Text(AppColors.textoEstado(r.estado), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        ),
        onTap: () => Get.to(() => DetalleScreen(reporte: r)),
      ),
    );
  }
}
