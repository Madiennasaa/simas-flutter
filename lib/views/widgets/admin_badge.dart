import 'package:flutter/material.dart';

/// Chip kecil buat nandain kategori (tipe mapel, tipe guru, status, dll)
/// biar sekali lihat langsung ke-tag tanpa baca subtitle penuh.
class AdminBadge extends StatelessWidget {
  final String label;
  final Color color;

  const AdminBadge({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10.5, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
