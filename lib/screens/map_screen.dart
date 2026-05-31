import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/enums.dart';
import '../models/reporte.dart';
import '../services/servicio_reportes.dart';
import '../widgets/custom_toast.dart';
import '../utils/geo.dart';
import '../widgets/report_detail_modal.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  WebViewController? _webCtrl;
  List<ReporteResponse> _reportes = [];
  bool _loading = false;
  double? _userLat;
  double? _userLng;
  String? _filtroEstado;
  String? _filtroTipo;
  String? _filtroPrioridad;
  bool _filterOpen = false;

  static const List<String> _mapEstados = ['PENDIENTE', 'REVISION', 'PROCESO', 'RESUELTA'];

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  void reload() => _cargarReportes();

  Future<void> _initLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      Position? pos;
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        try {
          pos = await Geolocator.getCurrentPosition();
        } catch (_) {}
      }
      _userLat = limaLat;
      _userLng = limaLng;
      if (pos != null && isInPeru(pos.latitude, pos.longitude)) {
        _userLat = pos.latitude;
        _userLng = pos.longitude;
      }
      await _cargarReportes();
      _initWebView();
      setState(() {});
    } catch (_) {
      _userLat = limaLat;
      _userLng = limaLng;
      await _cargarReportes();
      _initWebView();
      setState(() {});
    }
  }

  Future<void> _cargarReportes() async {
    setState(() => _loading = true);
    try {
      _reportes = await ServicioReportes().obtenerReportesMapa(
        estado: _filtroEstado,
        tipo: _filtroTipo,
        prioridad: _filtroPrioridad,
      );
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (_webCtrl != null) await _webCtrl!.loadHtmlString(_buildHtml());
  }

  void _initWebView() {
    _webCtrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (msg) {
          try {
            final data = jsonDecode(msg.message) as Map<String, dynamic>;
            if (data['type'] == 'markerClick') {
              final id = data['id'] as int;
              ReporteResponse? r;
              for (final e in _reportes) {
                if (e.id == id) {
                  r = e;
                  break;
                }
              }
              if (r != null) ReportDetailModal.show(r);
            }
          } catch (_) {}
        },
      )
      ..loadHtmlString(_buildHtml());
  }

  String _markerColor(String estado) {
    switch (estado.toUpperCase()) {
      case 'RESUELTA':
        return 'green';
      case 'PROCESO':
        return 'yellow';
      case 'REVISION':
        return 'blue';
      case 'PENDIENTE':
        return 'red';
      default:
        return 'gray';
    }
  }

  String _buildHtml() {
    final markers = _reportes
        .where((r) => _mapEstados.contains(r.estado.toUpperCase()))
        .map((r) => {
              'id': r.id,
              'lat': r.ubicacion.latitud,
              'lng': r.ubicacion.longitud,
              'title': r.titulo,
              'tipo': r.tipoProblema ?? '',
              'estado': r.estado,
              'color': _markerColor(r.estado),
            })
        .toList();
    return '''
<!DOCTYPE html>
<html><head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>body { margin:0; padding:0; } #map { width:100vw; height:100vh; }</style>
</head><body>
  <div id="map"></div>
  <script>
    const map = L.map('map', { zoomControl:false }).setView([$_userLat, $_userLng], 13);
    L.control.zoom({ position:'bottomright' }).addTo(map);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution:'© OpenStreetMap contributors', maxZoom: 19 }).addTo(map);
    L.marker([$_userLat, $_userLng], {
      icon: L.divIcon({ className: 'user-marker',
        html: '<div style="background-color:blue;width:12px;height:12px;border-radius:50%;border:2px solid white;"></div>',
        iconSize: [16, 16] })
    }).addTo(map).bindPopup('Mi Ubicación');

    const markers = ${jsonEncode(markers)};
    markers.forEach(m => {
      const icon = L.divIcon({ className: 'custom-marker',
        html: '<div style="background:'+m.color+';width:25px;height:25px;border-radius:50% 50% 50% 0;transform:rotate(-45deg);border:2px solid white;"><div style="transform:rotate(45deg);color:white;text-align:center;line-height:21px;">📍</div></div>',
        iconSize: [30, 30], iconAnchor: [15, 30] });
      L.marker([m.lat, m.lng], { icon })
        .addTo(map)
        .bindPopup('<div style="min-width:150px;"><strong>'+m.title+'</strong><br/><span>'+m.tipo+'</span><br/><span style="color:'+m.color+'">'+m.estado+'</span><br/><a href="#" onclick="FlutterChannel.postMessage(JSON.stringify({type:\\'markerClick\\', id:'+m.id+'}));return false;" style="color:blue;text-decoration:underline;">Ver detalle</a></div>');
    });
  </script>
</body></html>
''';
  }

  @override
  Widget build(BuildContext context) {
    if (_userLat == null || _webCtrl == null) {
      return const Center(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [CircularProgressIndicator(color: Color(0xFFA27EFF)), SizedBox(height: 10), Text('Obteniendo ubicación...')],
      ));
    }
    return Stack(
      children: [
        WebViewWidget(controller: _webCtrl!),
        Positioned(
          top: 10,
          left: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
            child: InkWell(
              onTap: () => setState(() => _filterOpen = true),
              child: const Row(children: [
                Icon(Icons.filter_list, color: Color(0xFFA27EFF)),
                SizedBox(width: 10),
                Text('Filtrar Reportes'),
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 10,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text('Leyenda', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              _LegendRow(color: Colors.red, label: 'Pendiente'),
              _LegendRow(color: Colors.blue, label: 'En Revisión'),
              _LegendRow(color: Colors.yellow, label: 'En Proceso'),
              _LegendRow(color: Colors.green, label: 'Resuelto'),
            ]),
          ),
        ),
        if (_loading)
          const Positioned.fill(child: Center(child: CircularProgressIndicator(color: Color(0xFFA27EFF)))),
        if (_filterOpen) _buildFilterModal(),
      ],
    );
  }

  Widget _buildFilterModal() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _filterOpen = false),
        child: Container(
          color: Colors.black54,
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _filterSection('Estado', _mapEstados, _filtroEstado, (v) => setState(() => _filtroEstado = v)),
                    _filterSection('Tipo de Problema', TipoProblema.values, _filtroTipo, (v) => setState(() => _filtroTipo = v)),
                    _filterSection('Prioridad', Prioridad.values, _filtroPrioridad, (v) => setState(() => _filtroPrioridad = v)),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _filtroEstado = null;
                                _filtroTipo = null;
                                _filtroPrioridad = null;
                                _filterOpen = false;
                              });
                              _cargarReportes();
                            },
                            child: const Text('Limpiar'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA27EFF)),
                            onPressed: () {
                              setState(() => _filterOpen = false);
                              _cargarReportes();
                            },
                            child: const Text('Aplicar', style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterSection(String title, List<String> options, String? selected, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, runSpacing: 6, children: options.map((opt) {
            final sel = selected == opt;
            return GestureDetector(
              onTap: () => onChanged(sel ? null : opt),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFFA27EFF) : const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(opt, style: TextStyle(color: sel ? Colors.white : Colors.black87, fontSize: 12)),
              ),
            );
          }).toList()),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendRow({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]);
}
