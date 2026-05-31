import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/tecnico_reportes_controller.dart';
import '../models/enums.dart';
import '../models/tecnico.dart';
import '../services/servicio_tecnicos.dart';
import '../widgets/app_colors.dart';
import '../widgets/custom_toast.dart';

class CompletarReporteScreen extends StatefulWidget {
  const CompletarReporteScreen({super.key});

  @override
  State<CompletarReporteScreen> createState() => _CompletarReporteScreenState();
}

class _CompletarReporteScreenState extends State<CompletarReporteScreen> {
  final _comentarioCtrl = TextEditingController();
  String? _imagenPath;
  bool _loading = false;

  int get _reporteId => Get.arguments as int;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final source = await _pickImageSource();
    if (source == null) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: source, imageQuality: 80);
      if (picked != null) {
        setState(() => _imagenPath = picked.path);
      }
    } catch (_) {
      AppToast.error('No se pudo obtener la imagen');
    }
  }

  Future<ImageSource?> _pickImageSource() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
              title: const Text('Tomar foto'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
              title: const Text('Elegir de galería'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_loading) return;
    final usuario = Get.find<AuthController>().usuario.value;
    if (usuario == null) {
      AppToast.error('Debes iniciar sesión.');
      return;
    }
    if (_comentarioCtrl.text.trim().length < 10) {
      AppToast.error('El comentario debe tener al menos 10 caracteres.');
      return;
    }
    setState(() => _loading = true);
    try {
      final fotos = <FotoRequest>[];
      if (_imagenPath != null) {
        final bytes = await File(_imagenPath!).readAsBytes();
        fotos.add(FotoRequest(
          tipo: TipoFoto.FINAL,
          descripcion: 'Foto de resolución',
          archivoBase64: base64Encode(bytes),
        ));
      }
      final req = CompletarReporteRequest(
        comentarioResolucion: _comentarioCtrl.text.trim(),
        fotos: fotos,
      );
      await ServicioTecnicos().completarReporte(usuario.id, _reporteId, req);
      if (Get.isRegistered<TecnicoReportesController>()) {
        await Get.find<TecnicoReportesController>().cargarReportes();
      }
      AppToast.success('Reporte marcado como resuelto');
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.back();
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: AppColors.tecnicoGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
                    const Expanded(
                      child: Text('Completar Reporte',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Label('Comentario de resolución:'),
                      TextField(
                        controller: _comentarioCtrl,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Describe cómo se resolvió el problema...',
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border:
                              OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _Label('Foto de la resolución (opcional):'),
                      _photoBox(),
                      const SizedBox(height: 6),
                      const Text('Opcional — útil como evidencia visual.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _loading ? null : _submit,
                        child: Text(
                          _loading ? 'Enviando...' : 'Marcar como Resuelto',
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
      label: const Text('Adjuntar foto', style: TextStyle(color: Color(0xFF555555))),
      onPressed: _takePhoto,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
        ),
      );
}
