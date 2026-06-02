import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/reportes_controller.dart';
import '../../widgets/report_card.dart';
import '../../widgets/common/gradient_header.dart';
import '../../widgets/common/estado_chips.dart';
import 'detalle_screen.dart';

/// Vista 03 Mis reportes (CU-05). Filtros por estado y busqueda por titulo.
class MisReportesScreen extends StatefulWidget {
  const MisReportesScreen({super.key});
  @override
  State<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends State<MisReportesScreen> {
  final _auth = Get.find<AuthController>();
  final _reportes = Get.find<ReportesController>();
  final RxString _filtro = ''.obs;
  final RxString _busqueda = ''.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_reportes.reportes.isEmpty) _reportes.cargarReportes(_auth.cuentaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F8),
      body: Column(
        children: [
          const GradientHeader(title: 'Mis Reportes', compact: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              onChanged: (v) => _busqueda.value = v,
              decoration: InputDecoration(
                hintText: 'Buscar por titulo',
                prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Obx(() => EstadoFilterChips(selected: _filtro.value, onSelected: (c) => _filtro.value = c)),
          Expanded(
            child: Obx(() {
              if (_reportes.loading.value) return const Center(child: CircularProgressIndicator());
              final list = _reportes.filtrar(
                estado: _filtro.value.isEmpty ? null : _filtro.value,
                busqueda: _busqueda.value,
              );
              if (list.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('No tienes reportes en este estado.', style: TextStyle(color: Color(0xFF9AA0AB))),
                  ),
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text('${list.length} reporte(s)', style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280))),
                  ),
                  ...list.map((r) => ReportCard(reporte: r, onTap: () => Get.to(() => DetalleScreen(reporte: r)))),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
