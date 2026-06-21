import '../data/local_store.dart';
import '../models/models.dart';

/// Servicio de cuenta y autenticacion (CU-01, CU-02, CU-03).
/// Fuente local (JSON). En entrega 3/4 solo cambia la implementacion
/// para llamar a la API; las firmas se mantienen.
class ServicioAuth {
  final LocalStore _store = LocalStore.instance;

  // --- CU-01 Login ---

  Future<AuthLoginResponse> login(String usuario, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    CuentaResponse? cuenta;
    for (final c in _store.cuentas) {
      if (c.usuario.toLowerCase() == usuario.toLowerCase()) {
        cuenta = c;
        break;
      }
    }
    if (cuenta == null) throw Exception('El usuario no esta registrado');
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

  // --- CU-02 Registro ---

  Future<CuentaResponse> crearCuenta(CrearCuentaRequest req) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final c in _store.cuentas) {
      if (c.usuario.toLowerCase() == req.usuario.toLowerCase()) {
        throw Exception('El usuario ya esta registrado');
      }
      if (c.correo.toLowerCase() == req.correo.toLowerCase()) {
        throw Exception('El correo ya esta registrado');
      }
      if (c.dni == req.dni) {
        throw Exception('El DNI ya esta registrado');
      }
    }
    final nuevaId =
        (_store.cuentas.map((c) => c.id).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
    final cuenta = CuentaResponse(
      id: nuevaId,
      tipoCuenta: TipoCuenta.CIUDADANO,
      usuario: req.usuario,
      nombres: req.nombres,
      apellidos: req.apellidos,
      dni: req.dni,
      telefono: req.telefono,
      correo: req.correo,
      activo: true,
      contrasena: req.contrasena,
    );
    _store.cuentas.add(cuenta);
    return cuenta;
  }

  // --- CU-03 Recuperar contraseña ---

  Future<void> solicitarRecuperacion(String correo) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final existe = _store.cuentas.any(
      (c) => c.correo.toLowerCase() == correo.toLowerCase().trim(),
    );
    if (!existe) {
      throw Exception('El correo electronico no esta asociado a ninguna cuenta');
    }
  }

  /// Solo ejecuta el cambio en el store. Las validaciones (coincidencia,
  /// longitud minima) se realizan en AuthController antes de llamar aqui.
  Future<void> restablecerContrasena(String correo, String nuevaPassword) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _store.cuentas.indexWhere(
      (c) => c.correo.toLowerCase() == correo.toLowerCase().trim(),
    );
    if (index == -1) {
      throw Exception('No se encontro una cuenta asociada a este correo');
    }
    final cuenta = _store.cuentas[index];
    _store.cuentas[index] = CuentaResponse(
      id: cuenta.id,
      tipoCuenta: cuenta.tipoCuenta,
      usuario: cuenta.usuario,
      nombres: cuenta.nombres,
      apellidos: cuenta.apellidos,
      dni: cuenta.dni,
      telefono: cuenta.telefono,
      correo: cuenta.correo,
      activo: cuenta.activo,
      contrasena: nuevaPassword,
    );
  }
}
