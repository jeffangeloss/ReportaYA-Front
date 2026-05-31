import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/reportes_controller.dart';
import '../routes/app_routes.dart';
import '../widgets/app_colors.dart';
import '../widgets/confirmation_modal.dart';
import '../widgets/pagination_footer.dart';
import '../widgets/report_card.dart';
import '../widgets/report_detail_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthController auth = Get.find();
  final ReportesController reportes = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final u = auth.usuario.value;
      if (u != null) reportes.cargarReportes(u.id);
    });
  }

  Future<void> _logout() async {
    final ok = await ConfirmationModal.show(
      title: 'Cerrar Sesión',
      message: '¿Estás seguro de que quieres cerrar sesión?',
      confirmText: 'Cerrar Sesión',
      danger: true,
    );
    if (ok == true) {
      await auth.logout();
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: AppColors.ciudadanoGradient, begin: Alignment.topCenter, end: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      final u = auth.usuario.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mis Reportes',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          if (u != null)
                            Text('Hola, ${u.nombre} (${u.tipoCuenta})',
                                style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      );
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: _logout,
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
                child: Obx(() {
                  if (reportes.loading.value && reportes.reportes.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFA27EFF)));
                  }
                  if (reportes.error.value != null && reportes.reportes.isEmpty) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(reportes.error.value!, style: const TextStyle(color: Color(0xFFFF6B6B))),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            final u = auth.usuario.value;
                            if (u != null) reportes.cargarReportes(u.id);
                          },
                          child: const Text('Toca para reintentar', style: TextStyle(color: Color(0xFFA27EFF))),
                        ),
                      ]),
                    );
                  }
                  if (reportes.reportes.isEmpty) {
                    return const Center(child: Text('No tienes reportes aún', style: TextStyle(color: Color(0xFF999999))));
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xFFA27EFF),
                          onRefresh: () async {
                            final u = auth.usuario.value;
                            if (u != null) await reportes.reloadCurrentPage(u.id);
                          },
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: reportes.reportes.length,
                            itemBuilder: (_, i) {
                              final r = reportes.reportes[i];
                              final ubic = r.ubicacion.direccion ??
                                  '${r.ubicacion.latitud.toStringAsFixed(6)}, ${r.ubicacion.longitud.toStringAsFixed(6)}';
                              final fecha = _formatFecha(r.fechaCreacion);
                              return ReportCard(
                                titulo: r.titulo,
                                tipo: r.prioridad,
                                estado: r.estado,
                                fecha: fecha,
                                ubicacion: ubic,
                                onPress: () => ReportDetailModal.show(r),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        color: const Color(0xFFA27EFF),
                        child: PaginationFooter(
                          currentPage: reportes.currentPage.value,
                          totalPages: reportes.totalPages.value,
                          loading: reportes.loading.value,
                          onPrev: () {
                            final u = auth.usuario.value;
                            if (u != null) reportes.prevPage(u.id);
                          },
                          onNext: () {
                            final u = auth.usuario.value;
                            if (u != null) reportes.nextPage(u.id);
                          },
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatFecha(String iso) {
    try {
      return DateFormat('dd MMM yyyy', 'es').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}
