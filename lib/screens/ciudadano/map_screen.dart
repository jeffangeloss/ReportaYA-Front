import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../../models/models.dart';
import '../../services/servicio_reportes.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/common/gradient_header.dart';
import 'detalle_screen.dart';
import 'main_tabs.dart';

/// Vista 06 Mapa (CU-05). Mapa real con OSM + marcadores por estado.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _service = ServicioReportes();
  List<ReporteResponse> _reportes = [];
  bool _loading = true;
  Worker? _tabWorker;

  // Centro de Lima por defecto
  static const _defaultCenter = LatLng(-12.0464, -77.0428);

  @override
  void initState() {
    super.initState();
    _cargar();
    _tabWorker = ever(Get.find<TabsController>().index, (int i) {
      if (i == 1 && mounted) _cargar();
    });
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    if (mounted) setState(() => _loading = true);
    final list = await _service.obtenerParaMapa();
    if (mounted) setState(() { _reportes = list; _loading = false; });
  }

  LatLng _centroMapa() {
    final validos = _reportes
        .where((r) => r.ubicacion.latitud != 0 && r.ubicacion.longitud != 0)
        .toList();
    if (validos.isEmpty) return _defaultCenter;
    final avgLat = validos.map((r) => r.ubicacion.latitud).reduce((a, b) => a + b) / validos.length;
    final avgLng = validos.map((r) => r.ubicacion.longitud).reduce((a, b) => a + b) / validos.length;
    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: Column(
        children: [
          const GradientHeader(title: 'Mapa de incidencias', compact: true),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      _mapa(),
                      Positioned(top: 10, left: 10, right: 10, child: _leyenda()),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _mapa() {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _centroMapa(),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.reportaya.app',
        ),
        MarkerLayer(
          markers: _reportes
              .where((r) => r.ubicacion.latitud != 0 && r.ubicacion.longitud != 0)
              .map((r) => _marker(r))
              .toList(),
        ),
      ],
    );
  }

  Marker _marker(ReporteResponse r) {
    final color = AppColors.forEstado(r.estado);
    return Marker(
      point: LatLng(r.ubicacion.latitud, r.ubicacion.longitud),
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () => Get.to(() => DetalleScreen(reporte: r)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.location_on, color: color, size: 40),
            Positioned(
              top: 4,
              child: Icon(AppColors.iconoTipo(r.tipoProblema), color: Colors.white, size: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _leyenda() {
    Widget item(String estado) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: AppColors.forEstado(estado), shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(AppColors.textoEstado(estado), style: const TextStyle(fontSize: 11)),
          ],
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 6,
        children: EstadoReporte.values.map(item).toList(),
      ),
    );
  }
}
