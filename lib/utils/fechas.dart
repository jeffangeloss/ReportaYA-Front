import 'package:intl/intl.dart';

String fmtFecha(String iso) {
  try {
    final d = DateTime.parse(iso);
    return DateFormat('dd MMM yyyy', 'es').format(d);
  } catch (_) {
    return iso;
  }
}

String fmtFechaHora(String iso) {
  try {
    final d = DateTime.parse(iso);
    return DateFormat('dd MMM · HH:mm', 'es').format(d);
  } catch (_) {
    return iso;
  }
}
