/// Geocodificacion. En la entrega 2 (sin red) devuelve una direccion local
/// a partir de las coordenadas. En la entrega 3/4 se conecta a Nominatim.
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
  Future<DireccionCompleta> obtenerDireccion(double lat, double lng) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final coord = '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}';
    return DireccionCompleta(
      calle: null,
      distrito: 'Lima',
      ciudad: 'Lima',
      departamento: 'Lima',
      pais: 'Peru',
      direccionCompleta: 'Ubicacion seleccionada ($coord)',
    );
  }
}
