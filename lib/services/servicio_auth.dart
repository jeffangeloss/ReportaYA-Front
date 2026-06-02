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
}
