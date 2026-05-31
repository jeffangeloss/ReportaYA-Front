import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/reportes_controller.dart';
import '../models/enums.dart';
import '../widgets/app_colors.dart';
import '../widgets/report_card.dart';
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
  final RxString _filtro = ''.obs; // '' = Todos
  final RxString _busqueda = ''.obs;

  static const _chips = <String>[
    '', EstadoReporte.PENDIENTE, EstadoReporte.REVISION,
    EstadoReporte.FINALIZADO, EstadoReporte.RECHAZADO,
  ];

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
          Container(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 14),
            width: double.infinity,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: AppColors.ciudadanoGradient)),
            child: const Text('Mis Reportes',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
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
          SizedBox(
            height: 46,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: _chips.map((c) {
                    final on = _filtro.value == c;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(c.isEmpty ? 'Todos' : AppColors.textoEstado(c)),
                        selected: on,
                        onSelected: (_) => _filtro.value = c,
                        selectedColor: c.isEmpty ? AppColors.primary : AppColors.forEstado(c),
                        labelStyle: TextStyle(color: on ? Colors.white : const Color(0xFF5B5F6B), fontWeight: FontWeight.w600),
                        backgroundColor: Colors.white,
                      ),
                    );
                  }).toList(),
                )),
          ),
          Expanded(
            child: Obx(() {
              if (_reportes.loading.value) {
                return const Center(child: CircularProgressIndicator());
              }
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
                  ...list.map((r) => ReportCard(
                        reporte: r,
                        onTap: () => Get.to(() => DetalleScreen(reporte: r)),
                      )),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
