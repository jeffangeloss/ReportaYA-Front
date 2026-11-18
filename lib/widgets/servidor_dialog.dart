import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../configs/api_config.dart';
import 'app_colors.dart';

/// Diálogo para elegir a qué backend se conecta la app: la nube (Render),
/// el de la compilación (p. ej. la PC del laboratorio) u otra dirección.
/// Devuelve true si se guardó un cambio.
Future<bool> mostrarDialogoServidor() async {
  final cambiado = await Get.dialog<bool>(const _ServidorDialog());
  return cambiado ?? false;
}

enum _Opcion { compilada, nube, otra }

class _ServidorDialog extends StatefulWidget {
  const _ServidorDialog();

  @override
  State<_ServidorDialog> createState() => _ServidorDialogState();
}

class _ServidorDialogState extends State<_ServidorDialog> {
  late _Opcion _opcion;
  final _otraCtrl = TextEditingController();
  bool _probando = false;
  String? _resultado;
  bool _resultadoOk = false;

  bool get _compiladaEsNube => ApiConfig.urlCompilada == ApiConfig.productionUrl;

  @override
  void initState() {
    super.initState();
    final actual = ApiConfig.baseUrl;
    if (actual == ApiConfig.urlCompilada) {
      _opcion = _compiladaEsNube ? _Opcion.nube : _Opcion.compilada;
    } else if (actual == ApiConfig.productionUrl) {
      _opcion = _Opcion.nube;
    } else {
      _opcion = _Opcion.otra;
      _otraCtrl.text = actual;
    }
  }

  @override
  void dispose() {
    _otraCtrl.dispose();
    super.dispose();
  }

  String? _urlElegida() {
    switch (_opcion) {
      case _Opcion.compilada:
        return ApiConfig.urlCompilada;
      case _Opcion.nube:
        return ApiConfig.productionUrl;
      case _Opcion.otra:
        final t = _otraCtrl.text.trim();
        return t.isEmpty ? null : ApiConfig.normalizar(t);
    }
  }

  /// Sin token, /reportes/mapa responde 401 si el backend está vivo.
  Future<void> _probar() async {
    final url = _urlElegida();
    if (url == null) {
      setState(() { _resultado = 'Escribe una dirección.'; _resultadoOk = false; });
      return;
    }
    setState(() { _probando = true; _resultado = null; });
    try {
      final r = await http
          .get(Uri.parse('$url/reportes/mapa'))
          .timeout(const Duration(seconds: 60));
      final ok = r.statusCode == 401 || r.statusCode == 200;
      setState(() {
        _resultadoOk = ok;
        _resultado = ok
            ? 'Conectado: el backend responde.'
            : 'Respondió ${r.statusCode}: no parece ser el backend de ReportaYA.';
      });
    } on TimeoutException {
      setState(() { _resultadoOk = false; _resultado = 'Sin respuesta en 60 s.'; });
    } catch (_) {
      setState(() {
        _resultadoOk = false;
        _resultado = 'No se pudo conectar. ¿Backend encendido y misma red?';
      });
    } finally {
      if (mounted) setState(() => _probando = false);
    }
  }

  Future<void> _guardar() async {
    final url = _urlElegida();
    if (url == null) {
      setState(() { _resultado = 'Escribe una dirección.'; _resultadoOk = false; });
      return;
    }
    // Si coincide con la de compilación no se guarda nada (queda el valor por defecto).
    await ApiConfig.guardar(url == ApiConfig.urlCompilada ? null : url);
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Servidor'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RadioGroup<_Opcion>(
              groupValue: _opcion,
              onChanged: (v) => setState(() { _opcion = v!; _resultado = null; }),
              child: Column(
                children: [
                  if (!_compiladaEsNube)
                    RadioListTile<_Opcion>(
                      value: _Opcion.compilada,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Mi PC (por defecto)'),
                      subtitle: Text(ApiConfig.urlCompilada, style: const TextStyle(fontSize: 12)),
                    ),
                  const RadioListTile<_Opcion>(
                    value: _Opcion.nube,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Nube (Render)'),
                    subtitle: Text(ApiConfig.productionUrl, style: TextStyle(fontSize: 12)),
                  ),
                  const RadioListTile<_Opcion>(
                    value: _Opcion.otra,
                    contentPadding: EdgeInsets.zero,
                    title: Text('Otra dirección'),
                  ),
                ],
              ),
            ),
            if (_opcion == _Opcion.otra)
              TextField(
                controller: _otraCtrl,
                keyboardType: TextInputType.url,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: '192.168.1.50:8081',
                  helperText: 'IP y puerto de la PC con el backend',
                  isDense: true,
                ),
              ),
            const SizedBox(height: 12),
            if (_resultado != null)
              Text(_resultado!,
                  style: TextStyle(
                      fontSize: 13,
                      color: _resultadoOk ? AppColors.estadoFinalizado : AppColors.error)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _probando ? null : _probar,
          child: _probando
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Probar'),
        ),
        TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _guardar,
          child: const Text('Guardar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
