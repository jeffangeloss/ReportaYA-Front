import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const _userAgent = 'com.reportaya.app';

/// Mapa estatico de solo lectura con un pin en [lat]/[lng].
/// Usado en DetalleScreen, GestionReportesScreen y EjecutarReporteScreen.
class MapPinView extends StatelessWidget {
  final double lat;
  final double lng;
  final Color color;
  final double height;
  final double zoom;

  const MapPinView({
    super.key,
    required this.lat,
    required this.lng,
    this.color = const Color(0xFF7C3AED), // primary default
    this.height = 130,
    this.zoom = 15.0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: zoom,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: _tileUrl,
              userAgentPackageName: _userAgent,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, lng),
                  width: 42,
                  height: 42,
                  child: Icon(Icons.location_on, color: color, size: 38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Mapa interactivo para seleccionar una ubicacion tocando la pantalla.
/// Llama a [onLocationPicked] con las coordenadas seleccionadas.
/// Usado en ReportScreen.
class MapPickerView extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final void Function(double lat, double lng) onLocationPicked;
  final double height;

  const MapPickerView({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.onLocationPicked,
    this.height = 200,
  });

  @override
  State<MapPickerView> createState() => _MapPickerViewState();
}

class _MapPickerViewState extends State<MapPickerView> {
  LatLng? _selected;

  // Centro por defecto: Lima, Peru
  static const _limaCenter = LatLng(-12.0464, -77.0428);

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selected = LatLng(widget.initialLat!, widget.initialLng!);
    }
  }

  void _onTap(TapPosition _, LatLng point) {
    setState(() => _selected = point);
    widget.onLocationPicked(point.latitude, point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    final center = _selected ?? _limaCenter;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13.0,
                onTap: _onTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: _tileUrl,
                  userAgentPackageName: _userAgent,
                ),
                if (_selected != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selected!,
                        width: 42,
                        height: 42,
                        child: const Icon(
                          Icons.location_on,
                          color: Color(0xFF7C3AED),
                          size: 38,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (_selected == null)
              Positioned.fill(
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Toca el mapa para marcar la ubicacion',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
