import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Tombol pill flat ala referensi (Student Login = hijau aktif,
/// Teacher Login = abu nonaktif). Warna bisa dioverride lewat [color]
/// kalau nanti dipakai beda konteks/role.
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppColors.accentGreen;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: isLoading ? null : onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: bg.withOpacity(0.35),
                offset: const Offset(0, 6),
                blurRadius: 14,
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.2),
                  )
                : Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
