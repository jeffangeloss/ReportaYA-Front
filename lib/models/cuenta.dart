class CrearCuentaRequest {
  final String tipoCuenta;
  final String usuario;
  final String contrasena;
  final String nombres;
  final String apellidos;
  final String dni;
  final String telefono;
  final String correo;
  final bool activo;

  CrearCuentaRequest({
    required this.tipoCuenta,
    required this.usuario,
    required this.contrasena,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.telefono,
    required this.correo,
    required this.activo,
  });

  Map<String, dynamic> toJson() => {
        'tipoCuenta': tipoCuenta,
        'usuario': usuario,
        'contrasena': contrasena,
        'nombres': nombres,
        'apellidos': apellidos,
        'dni': dni,
        'telefono': telefono,
        'correo': correo,
        'activo': activo,
      };
}

class CuentaResponse {
  final int id;
  final String tipoCuenta;
  final String usuario;
  final String nombres;
  final String apellidos;
  final String dni;
  final String telefono;
  final String correo;
  final bool activo;

  CuentaResponse({
    required this.id,
    required this.tipoCuenta,
    required this.usuario,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.telefono,
    required this.correo,
    required this.activo,
  });

  factory CuentaResponse.fromJson(Map<String, dynamic> json) => CuentaResponse(
        id: json['id'] as int,
        tipoCuenta: json['tipoCuenta'] as String,
        usuario: json['usuario'] as String,
        nombres: json['nombres'] as String,
        apellidos: json['apellidos'] as String,
        dni: json['dni'] as String,
        telefono: json['telefono'] as String,
        correo: json['correo'] as String,
        activo: json['activo'] as bool,
      );
}
