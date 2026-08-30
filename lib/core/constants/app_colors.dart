import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Palet flat/illustration style (sesuai referensi UI) ---
  // Background terang, aksen hijau untuk role aktif, abu untuk nonaktif.
  static const Color background = Color(0xFFF6F7F9); // panel/canvas utama
  static const Color backgroundAlt =
      Color(0xFFEDEFF2); // panel sekunder (kalau ada split view)
  static const Color surface = Color(0xFFFFFFFF);

  static const Color accentGreen =
      Color(0xFF4CD08A); // aksen role aktif: tombol, link, fokus field
  static const Color accentGreenDark = Color(0xFF34B975);
  static const Color inactiveGrey = Color(0xFFB9C0C9); // tombol/role nonaktif

  static const Color textPrimary = Color(0xFF1F2A3C);
  static const Color textSecondary = Color(0xFF6B7684);
  static const Color textMuted = Color(0xFF9AA3AF);
  static const Color fieldLine =
      Color(0xFFDCE0E5); // garis underline field, idle
  static const Color fieldLineFocused = accentGreen;

  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);

  // Dipertahankan sebagai alias biar file lain yang masih referensi warna lama tidak error.
  static const Color primary = accentGreen;
  static const Color primaryDark = Color(0xFF0A2540);
  static const Color primaryLight = accentGreenDark;
  static const Color accent = accentGreen;
  static const Color secondary = accentGreenDark;
  static const Color border = fieldLine;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, background],
  );

  // --- Palet neomorphism lama (dipertahankan biar tidak error di file lain
  // yang masih pakai NeuBox/NeuPressedBox, mis. widget di luar login/splash) ---
  static const Color neuSurface = Color(0xFFFFFFFF);
  static const Color neuFieldFill = Color(0xFFF0F2F5);
  static const Color neuShadowDark = Color(0xFFE1E5EA);
  static const Color neuShadowLight = Color(0xFFFFFFFF);
}
