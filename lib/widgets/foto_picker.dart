// lib/widgets/foto_picker.dart
// Selector de fotos para la evidencia de un reporte. Permite tomar una foto
// con la camara, elegir de la galeria (image_picker) o usar una de las
// imagenes de demo incluidas en assets. Cada foto seleccionada se guarda como
// bytes y se convierte a base64 al enviarla al backend (que la sube a Firebase).

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image_picker/image_picker.dart';

/// Una foto elegida localmente, aun no subida. Guarda los bytes para la
/// vista previa y el envio; [assetPath] solo se conserva para las de demo.
class FotoLocal {
  final Uint8List bytes;
  final String? assetPath;

  const FotoLocal(this.bytes, {this.assetPath});

  String toBase64() => base64Encode(bytes);
}

/// Campo reutilizable de seleccion de fotos. Gestiona su propia lista y avisa
/// al padre con [onChanged]. El padre solo convierte a base64 al enviar.
class FotoPickerField extends StatefulWidget {
  const FotoPickerField({
    super.key,
    required this.onChanged,
    required this.accent,
    this.max = 5,
    this.demoAssets = const [],
    this.thumbColor = const Color(0xFFEDEDF2),
  });

  /// Se llama con la lista actualizada cada vez que se agrega o quita una foto.
  final ValueChanged<List<FotoLocal>> onChanged;

  /// Color de acento (varia por rol: violeta ciudadano, verde tecnico).
  final Color accent;

  /// Maximo de fotos permitidas.
  final int max;

  /// Rutas de assets ofrecidas como "fotos de demo" en el selector.
  final List<String> demoAssets;

  final Color thumbColor;

  @override
  State<FotoPickerField> createState() => _FotoPickerFieldState();
}

class _FotoPickerFieldState extends State<FotoPickerField> {
  final ImagePicker _picker = ImagePicker();
  final List<FotoLocal> _fotos = [];

  void _emitChange() => widget.onChanged(List.unmodifiable(_fotos));

  Future<void> _agregarDesde(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1280,
        imageQuality: 60,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() => _fotos.add(FotoLocal(bytes)));
      _emitChange();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo obtener la imagen: $e')),
      );
    }
  }

  Future<void> _agregarDemo(String assetPath) async {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    setState(() => _fotos.add(FotoLocal(bytes, assetPath: assetPath)));
    _emitChange();
  }

  void _quitar(int index) {
    setState(() => _fotos.removeAt(index));
    _emitChange();
  }

  void _abrirMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_camera_outlined, color: widget.accent),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(ctx);
                _agregarDesde(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: widget.accent),
              title: const Text('Elegir de la galeria'),
              onTap: () {
                Navigator.pop(ctx);
                _agregarDesde(ImageSource.gallery);
              },
            ),
            if (widget.demoAssets.isNotEmpty)
              ListTile(
                leading: Icon(Icons.collections_outlined, color: widget.accent),
                title: const Text('Usar foto de demo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _abrirGaleriaDemo();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _abrirGaleriaDemo() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Fotos de demo',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: widget.demoAssets.map((path) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _agregarDemo(path);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(path,
                          width: 84, height: 84, fit: BoxFit.cover),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(_fotos.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.memory(_fotos[i].bytes,
                      width: 56, height: 56, fit: BoxFit.cover),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: GestureDetector(
                    onTap: () => _quitar(i),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(Icons.close, size: 14, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        if (_fotos.length < widget.max)
          GestureDetector(
            onTap: _abrirMenu,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: widget.thumbColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF9AA0AB)),
            ),
          ),
      ],
    );
  }
}
