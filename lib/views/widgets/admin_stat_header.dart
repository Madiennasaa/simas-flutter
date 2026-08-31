import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Card ringkasan di atas halaman list (mis. "240 Siswa", "12 Kelas").
/// Dipakai biar tiap halaman list punya konteks ringkas sebelum masuk
/// ke detail per item — senada sama welcome card di dashboard admin.
class AdminStatHeader extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const AdminStatHeader({
    super.key,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withOpacity(0.16), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: color),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
