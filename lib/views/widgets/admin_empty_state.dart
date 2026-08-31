import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Empty state dengan icon besar pastel + teks + tombol aksi opsional,
/// pengganti teks abu-abu polos di tengah layar.
class AdminEmptyState extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const AdminEmptyState({
    super.key,
    required this.icon,
    required this.color,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.10), shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: color),
            ),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            if (ctaLabel != null && onCta != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onCta,
                icon: Icon(Icons.add, color: color, size: 18),
                label: Text(ctaLabel!,
                    style:
                        TextStyle(color: color, fontWeight: FontWeight.w600)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
