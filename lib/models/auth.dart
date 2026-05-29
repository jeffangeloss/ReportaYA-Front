class AuthLoginRequest {
  final String usuario;
  final String password;

  AuthLoginRequest({required this.usuario, required this.password});

  Map<String, dynamic> toJson() => {'usuario': usuario, 'password': password};
}

class AuthLoginResponse {
  final int cuentaId;
  final String usuario;
  final String nombreCompleto;
  final String message;
  final String tipoCuenta;
  final String? token;

  AuthLoginResponse({
    required this.cuentaId,
    required this.usuario,
    required this.nombreCompleto,
    required this.message,
    required this.tipoCuenta,
    this.token,
  });

  factory AuthLoginResponse.fromJson(Map<String, dynamic> json) {
    return AuthLoginResponse(
      cuentaId: json['cuentaId'] as int,
      usuario: json['usuario'] as String,
      nombreCompleto: json['nombreCompleto'] as String? ?? '',
      message: json['message'] as String? ?? '',
      tipoCuenta: json['tipoCuenta'] as String,
      token: json['token'] as String?,
    );
  }
}

class UsuarioAutenticado {
  final int id;
  final String usuario;
  final String nombre;
  final String tipoCuenta;
  final DateTime loginTime;
  final String? token;

  UsuarioAutenticado({
    required this.id,
    required this.usuario,
    required this.nombre,
    required this.tipoCuenta,
    required this.loginTime,
    this.token,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'usuario': usuario,
        'nombre': nombre,
        'tipoCuenta': tipoCuenta,
        'loginTime': loginTime.toIso8601String(),
        if (token != null) 'token': token,
      };

  factory UsuarioAutenticado.fromJson(Map<String, dynamic> json) =>
      UsuarioAutenticado(
        id: json['id'] as int,
        usuario: json['usuario'] as String,
        nombre: json['nombre'] as String,
        tipoCuenta: json['tipoCuenta'] as String,
        loginTime: DateTime.parse(json['loginTime'] as String),
        token: json['token'] as String?,
      );
}
