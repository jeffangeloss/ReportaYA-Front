import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/reportes_controller.dart';
import '../../models/models.dart';
import '../../services/servicio_geocoding.dart';
import '../../services/servicio_reportes.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/common/gradient_header.dart';
import '../../widgets/common/detail_widgets.dart';
import 'main_tabs.dart';

/// Vista 04 Reportar (CU-04). Crea un reporte en estado PENDIENTE.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _auth = Get.find<AuthController>();
  final _service = ServicioReportes();
  final _geo = ServicioGeocoding();

  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _tipo = TipoProblema.INFRAESTRUCTURA;
  double? _lat, _lng;
  String? _direccion;
  int _fotos = 0;
  bool _enviando = false;

  Future<void> _usarUbicacion() async {
    _lat = -12.08530; _lng = -77.03760;
    final dir = await _geo.obtenerDireccion(_lat!, _lng!);
    setState(() => _direccion = dir.direccionCompleta);
  }

  Future<void> _enviar() async {
    if (_tituloCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      AppToast.error('Completa titulo y descripcion');
      return;
    }
    if (_lat == null) { AppToast.error('Selecciona una ubicacion'); return; }
    setState(() => _enviando = true);
    try {
      await _service.crearReporte(
        CrearReporteRequest(
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          cuentaId: _auth.cuentaId,
          tipoProblema: _tipo,
          ubicacion: CrearUbicacionRequest(latitud: _lat!, longitud: _lng!, direccion: _direccion),
        ),
        nombreCiudadano: _auth.usuario.value?.nombre,
        urlsFotos: List.filled(_fotos, 'assets/img/sample/generic_inicial.png'),
      );
      AppToast.success('Reporte enviado!');
      await Get.find<ReportesController>().cargarReportes(_auth.cuentaId);
      _reset();
      Get.find<TabsController>().go(3);
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _reset() {
    _tituloCtrl.clear();
    _descCtrl.clear();
    setState(() { _tipo = TipoProblema.INFRAESTRUCTURA; _lat = null; _lng = null; _direccion = null; _fotos = 0; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          const GradientHeader(title: 'Reportar Incidencia', compact: true),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('Titulo'),
                _input(_tituloCtrl, 'Ej. Hueco en la pista'),
                const SizedBox(height: 14),
                _label('Tipo de problema'),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: TipoProblema.values.map((t) {
                    final on = _tipo == t;
                    return ChoiceChip(
                      avatar: Icon(AppColors.iconoTipo(t), size: 16, color: on ? Colors.white : AppColors.primary),
                      label: Text(TipoProblema.label(t)),
                      selected: on,
                      onSelected: (_) => setState(() => _tipo = t),
                      selectedColor: AppColors.primary,
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(color: on ? Colors.white : const Color(0xFF555555), fontWeight: FontWeight.w600),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                _label('Descripcion detallada'),
                _input(_descCtrl, 'Describe la incidencia con detalle', maxLines: 4),
                const SizedBox(height: 14),
                _label('Ubicacion'),
                GestureDetector(
                  onTap: _usarUbicacion,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6ECEF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD7DEE2)),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_lat == null ? Icons.add_location_alt_outlined : Icons.place, color: AppColors.primary, size: 30),
                          const SizedBox(height: 6),
                          Text(_direccion ?? 'Toca para usar una ubicacion de ejemplo',
                              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _label('Fotos ($_fotos/5)'),
                Row(
                  children: [
                    ...List.generate(_fotos, (i) => Container(
                          width: 56, height: 56, margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(color: const Color(0xFF5B4636), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.image, color: Colors.white54, size: 20),
                        )),
                    if (_fotos < 5)
                      GestureDetector(
                        onTap: () => setState(() => _fotos++),
                        child: Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(color: const Color(0xFFEDEDF2), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.add, color: Color(0xFF9AA0AB)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                WideButton('Enviar reporte', AppColors.primary, _enviando ? null : _enviar, icon: Icons.send),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF444444))),
      );

  Widget _input(TextEditingController c, String hint, {int maxLines = 1}) => TextField(
        controller: c,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      );
}
