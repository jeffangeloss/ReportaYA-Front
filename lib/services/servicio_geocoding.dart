import 'package:dio/dio.dart';

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

class ServicioGeocoding {
  static const String _url = 'https://nominatim.openstreetmap.org/reverse';
  final Dio _dio = Dio();

  Future<DireccionCompleta> obtenerDireccion(double lat, double lng) async {
    try {
      final res = await _dio.get(
        _url,
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
          'addressdetails': 1,
          'accept-language': 'es',
        },
        options: Options(
          headers: {'User-Agent': 'ReportaYA/1.0'},
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final address = (res.data as Map<String, dynamic>)['address'] as Map<String, dynamic>?;
      if (address == null) throw Exception('No address');

      final calle = address['road'] ?? address['amenity'] ?? address['building'];
      final distrito = address['suburb'] ??
          address['neighbourhood'] ??
          address['quarter'] ??
          address['city_district'] ??
          address['municipality'] ??
          'Desconocido';
      final ciudad = address['city'] ?? address['town'] ?? address['village'] ?? 'Lima';
      final departamento = address['state'] ?? address['county'] ?? 'Lima';
      final pais = address['country'] ?? 'Perú';

      final partes = <String>[];
      if (calle != null) partes.add(calle.toString());
      partes.add(distrito.toString());
      if (ciudad != null && ciudad != distrito) partes.add(ciudad.toString());

      return DireccionCompleta(
        calle: calle?.toString(),
        distrito: distrito.toString(),
        ciudad: ciudad.toString(),
        departamento: departamento.toString(),
        pais: pais.toString(),
        direccionCompleta: partes.join(', '),
      );
    } catch (_) {
      return DireccionCompleta(
        calle: null,
        distrito: 'No disponible',
        ciudad: 'No disponible',
        departamento: 'No disponible',
        pais: 'No disponible',
        direccionCompleta: '$lat, $lng',
      );
    }
  }
}
