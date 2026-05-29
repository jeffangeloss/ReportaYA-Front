import 'package:get/get.dart';
import '../models/tecnico.dart';
import '../services/servicio_tecnicos.dart';

class TecnicosController extends GetxController {
  final ServicioTecnicos _service = ServicioTecnicos();

  final RxList<TecnicoResponse> tecnicos = <TecnicoResponse>[].obs;
  final RxBool loading = false.obs;
  final RxnString error = RxnString();
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 0.obs;
  final Map<int, List<TecnicoResponse>> _cache = {};

  Future<void> cargarTecnicos({int page = 0}) async {
    if (_cache.containsKey(page)) {
      tecnicos.assignAll(_cache[page]!);
      currentPage.value = page;
      return;
    }
    try {
      loading.value = true;
      error.value = null;
      final pageData = await _service.obtenerTodosTecnicos(page: page);
      _cache[page] = pageData.content;
      tecnicos.assignAll(pageData.content);
      currentPage.value = page;
      totalPages.value = pageData.totalPages;
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }

  Future<void> nextPage() async {
    if (currentPage.value < totalPages.value - 1 && !loading.value) {
      await cargarTecnicos(page: currentPage.value + 1);
    }
  }

  Future<void> prevPage() async {
    if (currentPage.value > 0 && !loading.value) {
      await cargarTecnicos(page: currentPage.value - 1);
    }
  }

  void limpiarTecnicos() {
    tecnicos.clear();
    currentPage.value = 0;
    totalPages.value = 0;
    _cache.clear();
    error.value = null;
  }
}
