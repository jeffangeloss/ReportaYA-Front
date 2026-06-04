import '../data/local_store.dart';
import '../models/models.dart';

/// CU-01 Iniciar sesion. Fuente local (JSON). En entrega 3/4 solo cambia
/// la implementacion para llamar a la API; la firma se mantiene.
class ServicioAuth {
  final LocalStore _store = LocalStore.instance;

  Future<AuthLoginResponse> login(String usuario, String password) async {
    await Future.delayed(const Duration(milliseconds: 300)); // simula latencia
    CuentaResponse? cuenta;
    for (final c in _store.cuentas) {
      if (c.usuario.toLowerCase() == usuario.toLowerCase()) {
        cuenta = c;
        break;
      }
    }
    if (cuenta == null) {
      throw Exception('El usuario no esta registrado');
    }
    if (cuenta.contrasena != null && cuenta.contrasena != password) {
      throw Exception('Usuario o contrasena incorrectos');
    }
    return AuthLoginResponse(
      cuentaId: cuenta.id,
      usuario: cuenta.usuario,
      nombreCompleto: cuenta.nombreCompleto,
      message: 'Inicio de sesion exitoso',
      tipoCuenta: cuenta.tipoCuenta,
      token: 'local-token-${cuenta.id}',
    );
  }

  /// CU-03 Recuperar contraseña. Fuente local (JSON).
  /// Busca si el correo existe en LocalStorage
  Future<void> solicitarRecuperacion(String correo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    final existe = LocalStore.instance.cuentas.any(
      (c) => c.correo.toLowerCase() == correo.toLowerCase().trim()
    );
    
    if (!existe) {
      throw Exception('El correo electrónico no está asociado a ninguna cuenta');
    }
  }

  /// Restablece la contraseña de la cuenta asociada al correo.
  Future<void> restablecerContrasena(String correo, String nuevaPassword, String confirmacion) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (nuevaPassword != confirmacion) {
      throw Exception('Las contraseñas no coinciden');
    }
    
    if (nuevaPassword.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    final index = LocalStore.instance.cuentas.indexWhere(
      (c) => c.correo.toLowerCase() == correo.toLowerCase().trim()
    );
    if (index == -1) {
      throw Exception('No se encontró una cuenta asociada a este correo');
    }
    // Actualiza la contraseña
    final cuenta = LocalStore.instance.cuentas[index];
    LocalStore.instance.cuentas[index] = CuentaResponse(
      id: cuenta.id,
      tipoCuenta: cuenta.tipoCuenta,
      usuario: cuenta.usuario,
      nombres: cuenta.nombres,
      apellidos: cuenta.apellidos,
      dni: cuenta.dni,
      telefono: cuenta.telefono,
      correo: cuenta.correo,
      activo: cuenta.activo,
      contrasena: nuevaPassword, // Nueva contraseña
    );
  }

}
