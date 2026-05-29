import 'package:flutter/material.dart';

class PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool loading;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Color textColor;

  const PaginationFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.loading,
    required this.onPrev,
    required this.onNext,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 0) return const SizedBox.shrink();
    final canPrev = currentPage > 0 && !loading;
    final canNext = currentPage < totalPages - 1 && !loading;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _btn(Icons.chevron_left, 'Anterior', canPrev, onPrev),
          Text('Página ${currentPage + 1} de ${totalPages == 0 ? 1 : totalPages}',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          _btn(Icons.chevron_right, 'Siguiente', canNext, onNext, iconAtEnd: true),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, String label, bool enabled, VoidCallback onTap, {bool iconAtEnd = false}) {
    final color = enabled ? textColor : Colors.white.withOpacity(0.4);
    final children = iconAtEnd
        ? [Text(label, style: TextStyle(color: color)), Icon(icon, color: color, size: 20)]
        : [Icon(icon, color: color, size: 20), Text(label, style: TextStyle(color: color))];
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(children: children),
      ),
    );
  }
}
