class TecnicoResponse {
  final int id;
  final String usuario;
  final String nombres;
  final String apellidos;
  final String dni;
  final String telefono;
  final String correo;
  final bool activo;

  TecnicoResponse({
    required this.id,
    required this.usuario,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.telefono,
    required this.correo,
    required this.activo,
  });

  factory TecnicoResponse.fromJson(Map<String, dynamic> json) => TecnicoResponse(
        id: (json['id'] as num?)?.toInt() ?? 0,
        usuario: json['usuario'] as String? ?? '',
        nombres: json['nombres'] as String? ?? '',
        apellidos: json['apellidos'] as String? ?? '',
        dni: json['dni'] as String? ?? '',
        telefono: json['telefono'] as String? ?? '',
        correo: json['correo'] as String? ?? '',
        activo: json['activo'] as bool? ?? true,
      );

  String get nombreCompleto => '$nombres $apellidos';
}
