import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum StartReportStatus { pendiente, revision, proceso, finalizado }

class StartReport {
  final int id;
  final String title;
  final String address;
  final IconData icon;
  final StartReportStatus status;
  final String date;

  const StartReport({
    required this.id,
    required this.title,
    required this.address,
    required this.icon,
    required this.status,
    required this.date,
  });
}

class StartController extends GetxController {
  final String citizenName = 'Ana Quispe';

  final List<StartReport> recentReports = const [
    StartReport(
      id: 1042,
      title: 'Hueco profundo en la pista',
      address: 'Av. Arequipa 1234, Lince',
      icon: Icons.edit_outlined,
      status: StartReportStatus.proceso,
      date: '27 abr 2026',
    ),
    StartReport(
      id: 1041,
      title: 'Poste sin alumbrado',
      address: 'Jr. Las Begonias 245, San Isidro',
      icon: Icons.lightbulb_outline,
      status: StartReportStatus.revision,
      date: '26 abr 2026',
    ),
    StartReport(
      id: 1040,
      title: 'Acumulación de basura',
      address: 'Av. Brasil 800, Pueblo Libre',
      icon: Icons.delete_outline,
      status: StartReportStatus.pendiente,
      date: '26 abr 2026',
    ),
  ];

  String statusLabel(StartReportStatus status) {
    switch (status) {
      case StartReportStatus.pendiente:
        return 'Pendiente';
      case StartReportStatus.revision:
        return 'En Revisión';
      case StartReportStatus.proceso:
        return 'En Proceso';
      case StartReportStatus.finalizado:
        return 'Finalizado';
    }
  }

  Color statusColor(StartReportStatus status) {
    switch (status) {
      case StartReportStatus.pendiente:
        return const Color(0xFFFF6B6B);
      case StartReportStatus.revision:
        return const Color(0xFFFFA500);
      case StartReportStatus.proceso:
        return const Color(0xFF2196F3);
      case StartReportStatus.finalizado:
        return const Color(0xFF4CAF50);
    }
  }

  void goToReport(BuildContext context) {
    _showPendingRoute(context, 'Reportar incidencia');
  }

  void goToMyReports(BuildContext context) {
    _showPendingRoute(context, 'Mis reportes');
  }

  void goToMap(BuildContext context) {
    _showPendingRoute(context, 'Mapa');
  }

  void openReport(BuildContext context, StartReport report) {
    _showPendingRoute(context, 'Reporte #${report.id}');
  }

  void logOut(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/log-in');
  }

  void _showPendingRoute(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title estará disponible próximamente')),
    );
  }
}
