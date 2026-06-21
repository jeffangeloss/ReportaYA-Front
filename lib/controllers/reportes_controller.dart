import 'package:get/get.dart';
import '../models/models.dart';
import '../services/servicio_reportes.dart';

/// Estado de los reportes del ciudadano (vistas 02 Inicio, 03 Mis reportes, 05 Detalle).
class ReportesController extends GetxController {
  final ServicioReportes _service = ServicioReportes();

  final RxList<ReporteResponse> reportes = <ReporteResponse>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();
  int _cuentaId = 0;

  // --- Estado de la pantalla Detalle (Vista 05) ---
  final RxList<HistorialEstado> historial = <HistorialEstado>[].obs;
  final RxList<Foto> fotosDetalle = <Foto>[].obs;
  final RxBool loadingDetalle = false.obs;

  Future<void> cargarReportes(int cuentaId) async {
    _cuentaId = cuentaId;
    try {
      loading.value = true;
      error.value = null;
      final list = await _service.obtenerReportesPorCuenta(cuentaId);
      reportes.assignAll(list);
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      loading.value = false;
    }
  }

  List<ReporteResponse> get recientes => reportes.take(5).toList();

  List<ReporteResponse> filtrar({String? estado, String? busqueda}) {
    return reportes.where((r) {
      final okEstado = estado == null || estado.isEmpty || r.estado == estado;
      final okBusqueda = busqueda == null ||
          busqueda.isEmpty ||
          r.titulo.toLowerCase().contains(busqueda.toLowerCase());
      return okEstado && okBusqueda;
    }).toList();
  }

  void limpiar() {
    reportes.clear();
    error.value = null;
  }

  // --- CU-04 Crear reporte ---

  Future<void> crearReporte(
    CrearReporteRequest req, {
    String? nombreCiudadano,
    List<String> urlsFotos = const [],
  }) async {
    await _service.crearReporte(
      req,
      nombreCiudadano: nombreCiudadano,
      urlsFotos: urlsFotos,
    );
    if (_cuentaId != 0) await cargarReportes(_cuentaId);
  }

  // --- CU-05 Detalle de reporte ---

  Future<void> cargarDetalle(int reporteId) async {
    loadingDetalle.value = true;
    final h = await _service.obtenerHistorialEstados(reporteId);
    final f = await _service.obtenerFotos(reporteId);
    historial.assignAll(h);
    fotosDetalle.assignAll(f);
    loadingDetalle.value = false;
  }
}
