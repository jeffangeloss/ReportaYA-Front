import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/models.dart';

/// Almacen en memoria sembrado desde los JSON de assets/data.
/// Simula la base de datos local mientras no exista backend (entrega 2).
/// En la entrega 3/4 solo cambian los Servicios (JSON -> API), no esto.
class LocalStore {
  LocalStore._();
  static final LocalStore instance = LocalStore._();

  final List<CuentaResponse> cuentas = [];
  final List<TecnicoResponse> tecnicos = [];
  final List<ReporteResponse> reportes = [];
  final List<HistorialEstado> historial = [];
  final List<Foto> fotos = [];

  bool _seeded = false;
  int _reporteSeq = 1000;
  int _historialSeq = 1;
  int _fotoSeq = 1;

  Future<void> seed() async {
    if (_seeded) return;
    cuentas.addAll(await _load('assets/data/cuentas.json', CuentaResponse.fromJson));
    tecnicos.addAll(await _load('assets/data/tecnicos.json', TecnicoResponse.fromJson));
    reportes.addAll(await _load('assets/data/reportes.json', ReporteResponse.fromJson));
    historial.addAll(await _load('assets/data/historial.json', HistorialEstado.fromJson));
    fotos.addAll(await _load('assets/data/fotos.json', Foto.fromJson));

    _reporteSeq = _maxId(reportes.map((r) => r.id)) + 1;
    _historialSeq = _maxId(historial.map((h) => h.id)) + 1;
    _fotoSeq = _maxId(fotos.map((f) => f.id)) + 1;
    _seeded = true;
  }

  Future<List<T>> _load<T>(
    String path,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await rootBundle.loadString(path);
    final list = jsonDecode(raw) as List<dynamic>;
    return list.map((e) => fromJson(e as Map<String, dynamic>)).toList();
  }

  int _maxId(Iterable<int> ids) => ids.isEmpty ? 0 : ids.reduce(max);

  // Generadores de id (simulan el autoincrement de la BD).
  int nextReporteId() => _reporteSeq++;
  int nextHistorialId() => _historialSeq++;
  int nextFotoId() => _fotoSeq++;

  // Helpers de consulta reutilizados por los servicios.
  int indexReporte(int id) => reportes.indexWhere((r) => r.id == id);
  List<Foto> fotosDe(int reporteId, {String? tipo}) => fotos
      .where((f) => f.reporteId == reporteId && (tipo == null || f.tipo == tipo))
      .toList();
  List<HistorialEstado> historialDe(int reporteId) =>
      historial.where((h) => h.reporteId == reporteId).toList()
        ..sort((a, b) => a.fechaCambio.compareTo(b.fechaCambio));

  void registrarCambioEstado(int reporteId, String? anterior, String nuevo) {
    historial.add(HistorialEstado(
      id: nextHistorialId(),
      reporteId: reporteId,
      estadoAnterior: anterior,
      estadoNuevo: nuevo,
      fechaCambio: DateTime.now().toIso8601String(),
    ));
  }
}
