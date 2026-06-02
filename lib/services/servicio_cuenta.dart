import '../data/local_store.dart';
import '../models/models.dart';

/// CU-02 Registrarse (solo CIUDADANO). Fuente local.
class ServicioCuenta {
  final LocalStore _store = LocalStore.instance;

  Future<CuentaResponse> crearCuenta(CrearCuentaRequest req) async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (final c in _store.cuentas) {
      if (c.usuario.toLowerCase() == req.usuario.toLowerCase()) {
        throw Exception('El usuario ya esta registrado');
      }
      if (c.correo.toLowerCase() == req.correo.toLowerCase()) {
        throw Exception('El correo ya esta registrado');
      }
    }
    final nuevaId = (_store.cuentas.map((c) => c.id).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
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
}
