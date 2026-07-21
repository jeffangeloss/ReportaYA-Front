import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/models.dart';

/// Construye la imagen de una foto segun su origen: las fotos reales vienen del
/// backend como URL http(s) de Firebase Storage (Image.network); las de demo o
/// placeholders pueden ser rutas de asset (Image.asset).
Widget _fotoImage(
  String url, {
  double? width,
  double? height,
  required BoxFit fit,
  required Widget error,
}) {
  final esRemota = url.startsWith('http://') || url.startsWith('https://');
  if (esRemota) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => error,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: width,
          height: height,
          color: const Color(0xFFE6E2F0),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }
  return Image.asset(
    url,
    width: width,
    height: height,
    fit: fit,
    errorBuilder: (_, _, _) => error,
  );
}

/// Miniatura de foto (asset o network) con visor a pantalla completa al tocar.
class FotoThumb extends StatelessWidget {
  final Foto foto;
  final double width;
  final double height;
  const FotoThumb({
    super.key,
    required this.foto,
    this.width = 130,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _abrirVisor(foto),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _fotoImage(
          foto.url,
          width: width,
          height: height,
          fit: BoxFit.cover,
          error: Container(
            width: width,
            height: height,
            color: const Color(0xFFE6E2F0),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF9AA0AB),
            ),
          ),
        ),
      ),
    );
  }
}

void _abrirVisor(Foto foto) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: Get.back,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          Flexible(
            child: InteractiveViewer(
              child: _fotoImage(
                foto.url,
                fit: BoxFit.contain,
                error: const Padding(
                  padding: EdgeInsets.all(40),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.white54,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          if (foto.descripcion != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                foto.descripcion!,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Tira horizontal de fotos. Si no hay, muestra un aviso.
class FotosStrip extends StatelessWidget {
  final List<Foto> fotos;
  final double height;
  final String vacioTexto;
  const FotosStrip({
    super.key,
    required this.fotos,
    this.height = 96,
    this.vacioTexto = 'Sin fotos',
  });

  @override
  Widget build(BuildContext context) {
    if (fotos.isEmpty) {
      return Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDF2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          vacioTexto,
          style: const TextStyle(color: Color(0xFF9AA0AB)),
        ),
      );
    }
    return SizedBox(
      height: height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: fotos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => FotoThumb(foto: fotos[i], height: height),
      ),
    );
  }
}
