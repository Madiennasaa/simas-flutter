import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Satu keluarga biru dari gelap ke terang, biar tema kelihatan
  // menyatu, simpel, dan elegan (bukan campuran biru+hijau lagi).
  static const Color primaryDark = Color(0xFF0A2540); // navy, dipakai di splash/header
  static const Color primary = Color(0xFF1565C0); // biru utama, dipakai di tombol/aksen
  static const Color primaryLight = Color(0xFF3B82F6); // biru terang, dipakai di gradient
  static const Color accent = Color(0xFF60A5FA); // biru muda buat highlight/shimmer

  static const Color background = Color(0xFFF4F7FB); // abu-biru sangat lembut
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF10233F);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const Color error = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);

  // Dipertahankan sebagai alias biar file lain yang masih referensi
  // AppColors.secondary tidak error — sekarang ikut palet biru, bukan hijau.
  static const Color secondary = primaryLight;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  // --- Palet neomorphism (soft UI) ---
  // Base tetap biru (sesuai tema utama). FFFFFF & F7F7F7 di sini KHUSUS
  // dipakai buat pasangan inner shadow (offset 2,2 dan -2,2), bukan buat
  // warna dasar/background.
  static const Color neuSurface = Color(0xFFFFFFFF); // elemen "timbul" (logo, tombol)
  static const Color neuFieldFill = primaryDark; // elemen "ke-tekan" (input) — lebih gelap dari bg biar kerasa recessed
  static const Color neuShadowDark = Color(0xFFF7F7F7); // sisi shadow di offset (2, 2)
  static const Color neuShadowLight = Color(0xFFFFFFFF); // sisi shadow di offset (-2, 2)
}
