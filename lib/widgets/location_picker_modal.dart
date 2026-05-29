import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LocationPickerModal extends StatefulWidget {
  final double initialLat;
  final double initialLng;
  final Future<void> Function(double lat, double lng) onConfirm;

  const LocationPickerModal({
    super.key,
    required this.initialLat,
    required this.initialLng,
    required this.onConfirm,
  });

  @override
  State<LocationPickerModal> createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  late final WebViewController _controller;
  double _selectedLat = 0;
  double _selectedLng = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _selectedLat = widget.initialLat;
    _selectedLng = widget.initialLng;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (msg) {
          try {
            final data = jsonDecode(msg.message) as Map<String, dynamic>;
            if (data['type'] == 'locationChange') {
              setState(() {
                _selectedLat = (data['lat'] as num).toDouble();
                _selectedLng = (data['lng'] as num).toDouble();
              });
            } else if (data['type'] == 'mapReady') {
              setState(() => _loading = false);
            }
          } catch (_) {}
        },
      )
      ..loadHtmlString(_html());
  }

  String _html() => '''
<!DOCTYPE html>
<html><head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
  <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
  <style>
    body { margin: 0; padding: 0; font-family: sans-serif; }
    #map { width: 100vw; height: 100vh; }
    .instruction-banner { position:absolute; top:10px; left:50%; transform:translateX(-50%);
      background:white; padding:12px 20px; border-radius:20px; box-shadow:0 2px 6px rgba(0,0,0,0.3);
      z-index:1000; text-align:center; max-width:80%; }
    .center-marker { position:absolute; top:50%; left:50%; transform:translate(-50%, -100%);
      z-index:1000; pointer-events:none; }
    .marker-pin { width:30px; height:30px; background:#a27eff; border-radius:50% 50% 50% 0;
      transform:rotate(-45deg); border:3px solid white; box-shadow:0 3px 10px rgba(0,0,0,0.4); }
    .marker-icon { transform:rotate(45deg); color:white; text-align:center; line-height:24px; font-size:18px; }
  </style>
</head><body>
  <div class="instruction-banner"><p style="margin:0; font-size:14px; color:#333;">🗺️ Mueve el mapa para ajustar la ubicación del marcador</p></div>
  <div class="center-marker"><div class="marker-pin"><div class="marker-icon">📍</div></div></div>
  <div id="map"></div>
  <script>
    const map = L.map('map', { zoomControl: true }).setView([${widget.initialLat}, ${widget.initialLng}], 16);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: '© OpenStreetMap contributors', maxZoom: 19 }).addTo(map);
    function send(lat, lng) {
      FlutterChannel.postMessage(JSON.stringify({ type: 'locationChange', lat, lng }));
    }
    map.on('moveend', function() { const c = map.getCenter(); send(c.lat, c.lng); });
    send(${widget.initialLat}, ${widget.initialLng});
    setTimeout(() => { FlutterChannel.postMessage(JSON.stringify({ type: 'mapReady' })); }, 500);
  </script>
</body></html>
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 1,
        title: const Text('Seleccionar Ubicación', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFFA27EFF)),
            onPressed: _confirm,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  Container(
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: const Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(color: Color(0xFFA27EFF)),
                      SizedBox(height: 10),
                      Text('Cargando mapa...', style: TextStyle(color: Color(0xFF666666))),
                    ]),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF666666), size: 20),
                      const SizedBox(width: 8),
                      Text('${_selectedLat.toStringAsFixed(6)}, ${_selectedLng.toStringAsFixed(6)}',
                          style: const TextStyle(color: Color(0xFF666666), fontFamily: 'monospace')),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle, color: Colors.white),
                    label: const Text('Confirmar Ubicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA27EFF),
                      padding: const EdgeInsets.all(15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _confirm,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    await widget.onConfirm(_selectedLat, _selectedLng);
    if (mounted) Navigator.of(context).pop();
  }
}
