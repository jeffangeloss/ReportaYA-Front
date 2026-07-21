import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/reportes_controller.dart';
import '../../models/models.dart';
import '../../services/servicio_geocoding.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_toast.dart';
import '../../widgets/foto_picker.dart';
import '../../widgets/map_view.dart';
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
  final _reportes = Get.find<ReportesController>();
  final _geo = ServicioGeocoding(); // frontend: geocodifica coordenadas del mapa

  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _tipo = TipoProblema.INFRAESTRUCTURA;
  double? _lat, _lng;
  String? _direccion;
  bool _geocodificando = false;
  List<FotoLocal> _fotos = [];
  int _pickerVersion = 0; // cambia su key para reiniciar el selector al enviar
  bool _enviando = false;

  static const _demoAssetsInicial = [
    'assets/img/sample/poste_1.png',
    'assets/img/sample/semaforo_1.png',
    'assets/img/sample/basura_1.png',
    'assets/img/sample/hueco_1.png',
    'assets/img/sample/hueco_2.png',
    'assets/img/sample/vidrio_1.png',
    'assets/img/sample/generic_inicial.png',
  ];

  Future<void> _onUbicacionSeleccionada(double lat, double lng) async {
    setState(() { _lat = lat; _lng = lng; _geocodificando = true; });
    final dir = await _geo.obtenerDireccion(lat, lng);
    if (mounted) setState(() { _direccion = dir.direccionCompleta; _geocodificando = false; });
  }

  Future<void> _enviar() async {
    if (_tituloCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      AppToast.error('Completa titulo y descripcion');
      return;
    }
    if (_lat == null) { AppToast.error('Selecciona una ubicacion en el mapa'); return; }
    setState(() => _enviando = true);
    try {
      await _reportes.crearReporte(
        CrearReporteRequest(
          titulo: _tituloCtrl.text.trim(),
          descripcion: _descCtrl.text.trim(),
          cuentaId: _auth.cuentaId,
          tipoProblema: _tipo,
          ubicacion: CrearUbicacionRequest(latitud: _lat!, longitud: _lng!, direccion: _direccion),
        ),
        nombreCiudadano: _auth.usuario.value?.nombre,
        fotosBase64: _fotos.map((f) => f.toBase64()).toList(),
      );
      AppToast.success('Reporte enviado!');
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
    setState(() {
      _tipo = TipoProblema.INFRAESTRUCTURA;
      _lat = null; _lng = null; _direccion = null;
      _fotos = [];
      _pickerVersion++; // fuerza un selector nuevo y vacio
    });
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
                _label('Ubicacion — toca el mapa para marcar'),
                MapPickerView(
                  initialLat: _lat,
                  initialLng: _lng,
                  onLocationPicked: _onUbicacionSeleccionada,
                  height: 200,
                ),
                if (_geocodificando)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Row(children: [
                      SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 8),
                      Text('Obteniendo direccion...', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ]),
                  )
                else if (_direccion != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.place, size: 14, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(_direccion!, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 14),
                _label('Fotos (${_fotos.length}/5)'),
                FotoPickerField(
                  key: ValueKey(_pickerVersion),
                  accent: AppColors.primary,
                  demoAssets: _demoAssetsInicial,
                  onChanged: (fotos) => setState(() => _fotos = fotos),
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
