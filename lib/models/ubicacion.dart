class Ubicacion {
  final int? id;
  final double latitud;
  final double longitud;
  final String? direccion;
  final String? fechaRegistro;

  Ubicacion({
    this.id,
    required this.latitud,
    required this.longitud,
    this.direccion,
    this.fechaRegistro,
  });

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      id: json['id'] as int?,
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      direccion: json['direccion'] as String?,
      fechaRegistro: json['fechaRegistro'] as String?,
    );
  }

  factory Ubicacion.unavailable() =>
      Ubicacion(latitud: 0, longitud: 0, direccion: 'Ubicación no disponible');

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'latitud': latitud,
        'longitud': longitud,
        if (direccion != null) 'direccion': direccion,
        if (fechaRegistro != null) 'fechaRegistro': fechaRegistro,
      };
}

class CrearUbicacionRequest {
  final double latitud;
  final double longitud;
  final String? direccion;

  CrearUbicacionRequest({
    required this.latitud,
    required this.longitud,
    this.direccion,
  });

  Map<String, dynamic> toJson() => {
        'latitud': latitud,
        'longitud': longitud,
        if (direccion != null) 'direccion': direccion,
      };
}
