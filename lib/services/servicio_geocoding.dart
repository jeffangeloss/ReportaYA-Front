import 'dart:convert';
import 'package:http/http.dart' as http;

class DireccionCompleta {
  final String? calle;
  final String distrito;
  final String ciudad;
  final String departamento;
  final String pais;
  final String direccionCompleta;

  DireccionCompleta({
    this.calle,
    required this.distrito,
    required this.ciudad,
    required this.departamento,
    required this.pais,
    required this.direccionCompleta,
  });
}

/// Geocodificacion inversa usando la API publica de Nominatim (OpenStreetMap).
/// Sin API key. Requiere User-Agent identificador per politica de uso de OSM.
class ServicioGeocoding {
  static const _userAgent = 'ReportaYA/1.0 (app movil de reportes urbanos)';

  Future<DireccionCompleta> obtenerDireccion(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?format=json&lat=$lat&lon=$lng&accept-language=es&zoom=17',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        final calle = _buildCalle(address);
        final distrito = (address['suburb'] ??
                address['city_district'] ??
                address['town'] ??
                'Lima')
            .toString();
        final ciudad =
            (address['city'] ?? address['town'] ?? 'Lima').toString();
        final dpto = (address['state'] ?? 'Lima').toString();
        final pais = (address['country'] ?? 'Peru').toString();
        final display = data['display_name'] as String? ??
            'Ubicacion ($lat, $lng)';

        return DireccionCompleta(
          calle: calle,
          distrito: distrito,
          ciudad: ciudad,
          departamento: dpto,
          pais: pais,
          direccionCompleta: _formatear(calle, distrito, ciudad),
        );
      }
    } catch (_) {
      // Fallo silencioso: devuelve coordenadas como fallback
    }
    final coord =
        '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    return DireccionCompleta(
      calle: null,
      distrito: 'Lima',
      ciudad: 'Lima',
      departamento: 'Lima',
      pais: 'Peru',
      direccionCompleta: 'Ubicacion seleccionada ($coord)',
    );
  }

  String? _buildCalle(Map<String, dynamic> addr) {
    final road = addr['road'] as String?;
    final number = addr['house_number'] as String?;
    if (road == null) return null;
    return number != null ? '$road $number' : road;
  }

  String _formatear(String? calle, String distrito, String ciudad) {
    final parts = <String>[
      if (calle != null) calle,
      distrito,
      ciudad,
    ];
    return parts.join(', ');
  }
}
