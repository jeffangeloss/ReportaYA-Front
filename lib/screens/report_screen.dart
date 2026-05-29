import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/reportes_controller.dart';
import '../models/reporte.dart';
import '../models/ubicacion.dart';
import '../services/servicio_geocoding.dart';
import '../services/servicio_reportes.dart';
import '../widgets/app_colors.dart';
import '../widgets/custom_toast.dart';
import '../widgets/location_picker_modal.dart';

class _UbicacionSeleccionada {
  double lat;
  double lng;
  String? direccion;
  _UbicacionSeleccionada({required this.lat, required this.lng, this.direccion});
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _descripcionCtrl = TextEditingController();
  String _tipo = '';
  _UbicacionSeleccionada? _ubicacion;
  String? _imagenPath;
  bool _loading = false;

  Future<void> _pickLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        AppToast.error('Permiso de ubicación denegado');
        return;
      }
      AppToast.info('Obteniendo ubicación...');
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)));
      } catch (_) {
        AppToast.info('Usando ubicación por defecto. Ajusta el marcador.');
      }
      final lat = pos?.latitude ?? _ubicacion?.lat ?? -12.046374;
      final lng = pos?.longitude ?? _ubicacion?.lng ?? -77.042793;

      await Get.to(() => LocationPickerModal(
            initialLat: lat,
            initialLng: lng,
            onConfirm: (newLat, newLng) async {
              AppToast.info('Obteniendo dirección...');
              try {
                final direccion = await ServicioGeocoding().obtenerDireccion(newLat, newLng);
                setState(() {
                  _ubicacion = _UbicacionSeleccionada(
                    lat: newLat,
                    lng: newLng,
                    direccion: direccion.direccionCompleta,
                  );
                });
                AppToast.success('Ubicación: ${direccion.distrito}, ${direccion.departamento}');
              } catch (_) {
                setState(() => _ubicacion = _UbicacionSeleccionada(lat: newLat, lng: newLng));
                AppToast.success('Ubicación seleccionada correctamente');
              }
            },
          ));
    } catch (e) {
      AppToast.error('Error al solicitar permiso de ubicación');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (picked != null) {
        setState(() => _imagenPath = picked.path);
      }
    } catch (_) {
      AppToast.error('No se pudo acceder a la cámara');
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    final auth = Get.find<AuthController>();
    final usuario = auth.usuario.value;
    if (usuario == null) {
      AppToast.error('Debes iniciar sesión para crear un reporte');
      return;
    }
    if (_tipo.isEmpty) {
      AppToast.error('Por favor, selecciona un tipo de problema.');
      return;
    }
    if (_ubicacion == null) {
      AppToast.error('Por favor, obtén tu ubicación.');
      return;
    }
    if (_descripcionCtrl.text.trim().length < 10) {
      AppToast.error('La descripción debe tener al menos 10 caracteres.');
      return;
    }

    setState(() => _loading = true);
    try {
      final tituloMap = {
        'infraestructura': 'Problema de infraestructura urbana',
        'residuos': 'Acumulación de residuos',
        'otros': 'Otro problema',
      };
      final tipoMap = {
        'infraestructura': 'INFRAESTRUCTURA',
        'residuos': 'RESIDUOS',
        'otros': 'OTROS',
      };
      final req = CrearReporteRequest(
        titulo: tituloMap[_tipo] ?? 'Reporte sin especificar',
        descripcion: _descripcionCtrl.text.trim(),
        cuentaId: usuario.id,
        tipoProblema: tipoMap[_tipo],
        ubicacion: CrearUbicacionRequest(
          latitud: _ubicacion!.lat,
          longitud: _ubicacion!.lng,
          direccion: _ubicacion!.direccion,
        ),
      );
      final reporte = await ServicioReportes().crearReporte(req);
      final ctrl = Get.find<ReportesController>();
      await ctrl.agregarReporte(reporte, usuario.id);
      AppToast.success('¡Reporte creado exitosamente!');
      setState(() {
        _tipo = '';
        _descripcionCtrl.clear();
        _ubicacion = null;
        _imagenPath = null;
      });
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.ciudadanoGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Reportar Incidencia',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _Label('Tipo de Problema:'),
                    _tipoSelector(),
                    const SizedBox(height: 14),
                    const _Label('Ubicación en el Mapa:'),
                    _ubicacionBox(),
                    const SizedBox(height: 14),
                    const _Label('Descripción detallada:'),
                    TextField(
                      controller: _descripcionCtrl,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Describa el problema encontrado...',
                        filled: true,
                        fillColor: const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const _Label('Adjuntar fotos:'),
                    _photoBox(),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA27EFF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: Text(
                        _loading ? 'Enviando...' : 'Enviar Reporte',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tipoSelector() {
    Widget btn(String value, String label) {
      final selected = _tipo == value;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _tipo = value),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFA27EFF) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF555555),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                )),
          ),
        ),
      );
    }

    return Row(children: [
      btn('infraestructura', 'Infraestructura'),
      btn('residuos', 'Residuos'),
      btn('otros', 'Otro'),
    ]);
  }

  Widget _ubicacionBox() {
    if (_ubicacion == null) {
      return ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFA27EFF),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: _pickLocation,
        child: const Text('Obtener Ubicación', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      );
    }
    return InkWell(
      onTap: _pickLocation,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F7FF),
          border: Border.all(color: const Color(0xFFA27EFF), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E0FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🗺️📍', style: TextStyle(fontSize: 28)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_ubicacion!.direccion ?? 'Ubicación seleccionada',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
                      const SizedBox(height: 4),
                      Text('${_ubicacion!.lat.toStringAsFixed(5)}, ${_ubicacion!.lng.toStringAsFixed(5)}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF666666), fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Toca para cambiar ubicación',
                style: TextStyle(fontSize: 12, color: Color(0xFFA27EFF), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _photoBox() {
    if (_imagenPath != null) {
      return InkWell(
        onTap: _takePhoto,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(File(_imagenPath!), height: 160, fit: BoxFit.cover),
        ),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        backgroundColor: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: const Icon(Icons.camera_alt, color: Color(0xFF555555)),
      label: const Text('Adjuntar Fotos', style: TextStyle(color: Color(0xFF555555))),
      onPressed: _takePhoto,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
      );
}
