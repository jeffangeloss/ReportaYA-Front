import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/operador_reportes_controller.dart';
import '../models/auditoria.dart';
import '../services/servicio_auditoria.dart';
import '../widgets/app_colors.dart';
import '../widgets/custom_toast.dart';

class AuditarReporteScreen extends StatefulWidget {
  const AuditarReporteScreen({super.key});

  @override
  State<AuditarReporteScreen> createState() => _AuditarReporteScreenState();
}

class _AuditarReporteScreenState extends State<AuditarReporteScreen> {
  late final int reporteId;
  ReporteAuditoria? _reporte;
  bool _loading = true;
  String? _error;
  bool _aceptando = false;
  bool _rechazando = false;

  @override
  void initState() {
    super.initState();
    reporteId = Get.arguments as int;
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _reporte = await ServicioAuditoria().obtenerReporteParaAuditoria(reporteId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<String?> _promptComment(String title, String hint) {
    final ctrl = TextEditingController();
    return Get.dialog<String>(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: hint,
                  filled: true,
                  fillColor: const Color(0xFFF9F9F9),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Get.back(result: null), child: const Text('Cancelar'))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA27EFF)),
                    onPressed: () {
                      final v = ctrl.text.trim();
                      if (v.isNotEmpty) Get.back(result: v);
                    },
                    child: const Text('Confirmar', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _aceptar() async {
    final coment = await _promptComment('Comentario de Cierre', 'Escribe el comentario de cierre...');
    if (coment == null) return;
    setState(() => _aceptando = true);
    try {
      await ServicioAuditoria().aceptarAuditoria(reporteId, coment);
      try {
        Get.find<OperadorReportesController>().actualizarEstadoReporte(reporteId, 'CERRADA');
      } catch (_) {}
      AppToast.success('Reporte cerrado exitosamente');
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _aceptando = false);
    }
  }

  Future<void> _rechazar() async {
    final coment = await _promptComment('Comentario de Rechazo', 'Escribe el comentario de rechazo...');
    if (coment == null) return;
    setState(() => _rechazando = true);
    try {
      await ServicioAuditoria().rechazarAuditoria(reporteId, coment);
      try {
        Get.find<OperadorReportesController>().actualizarEstadoReporte(reporteId, 'RECHAZADO_AUDITO');
      } catch (_) {}
      AppToast.success('Reporte rechazado, vuelve a PROCESO');
      await Future.delayed(const Duration(seconds: 1));
      Get.back();
    } catch (e) {
      AppToast.error(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _rechazando = false);
    }
  }

  Color _colorFoto(String tipo) {
    switch (tipo) {
      case 'INICIAL':
        return const Color(0xFFFF6B6B);
      case 'PROCESO':
        return const Color(0xFFFFA500);
      case 'FINAL':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
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
        gradient: LinearGradient(colors: AppColors.ciudadanoGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Auditar Reporte',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('Reporte #$reporteId', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                ),
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildBody() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: Color(0xFFA27EFF)));
    if (_error != null) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(_error!, style: const TextStyle(color: Color(0xFFFF6B6B))),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA27EFF)),
            onPressed: _cargar,
            child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
          ),
        ]),
      );
    }
    final r = _reporte;
    if (r == null) return const Center(child: Text('No se encontró el reporte'));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('📋 Información del Reporte', Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info('Título:', r.titulo),
              _info('Ubicación:', r.ubicacion.direccion ?? 'No especificada'),
              _info('Prioridad:', r.prioridad),
              _info('Técnico Asignado:', r.tecnicoNombre),
              Row(children: [
                const SizedBox(width: 130, child: Text('Rechazos de Auditoría:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF666666)))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: r.contadorRechazos >= 3
                        ? const Color(0xFFFF6B6B)
                        : r.contadorRechazos > 0
                            ? const Color(0xFFFFA500)
                            : const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${r.contadorRechazos}/3',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ]),
            ],
          )),
          _section('💬 Comentario de Resolución', Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F5F5), borderRadius: BorderRadius.circular(8)),
            child: Text(r.comentarioResolucion.isEmpty ? 'Sin comentario' : r.comentarioResolucion),
          )),
          _section('📸 Fotos Adjuntadas', r.fotos.isEmpty
              ? const Text('No hay fotos adjuntadas', style: TextStyle(color: Color(0xFF999999)))
              : Wrap(spacing: 10, runSpacing: 10, children: r.fotos.take(3).map((f) => _fotoCard(f)).toList())),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: (_aceptando || _rechazando) ? null : _aceptar,
                icon: _aceptando
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text('Aceptar y Cerrar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF44336), padding: const EdgeInsets.symmetric(vertical: 14)),
                onPressed: (_aceptando || _rechazando) ? null : _rechazar,
                icon: _rechazando
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.cancel_outlined, color: Colors.white),
                label: const Text('Rechazar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, Widget body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
          ),
          body,
        ],
      ),
    );
  }

  Widget _info(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF666666)))),
          Expanded(child: Text(value)),
        ]),
      );

  Widget _fotoCard(FotoAuditoria foto) {
    return GestureDetector(
      onTap: () => _showFoto(foto),
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: _colorFoto(foto.tipo), width: 4)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              alignment: Alignment.centerLeft,
              child: Icon(Icons.image_outlined, color: _colorFoto(foto.tipo)),
            ),
            if (foto.archivoBase64 != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.memory(
                  base64Decode(foto.archivoBase64!),
                  height: 80,
                  width: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 80,
                    color: const Color(0xFFEEEEEE),
                    child: const Icon(Icons.broken_image, color: Color(0xFF999999)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showFoto(FotoAuditoria foto) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black87,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (foto.archivoBase64 != null)
                Image.memory(base64Decode(foto.archivoBase64!), fit: BoxFit.contain),
              const SizedBox(height: 12),
              Text(foto.descripcion, style: const TextStyle(color: Colors.white)),
              TextButton(onPressed: () => Get.back(), child: const Text('Cerrar', style: TextStyle(color: Colors.white))),
            ],
          ),
        ),
      ),
    );
  }
}
