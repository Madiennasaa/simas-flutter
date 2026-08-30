import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Kotak/lingkaran dengan efek "timbul" (raised) khas neomorphism, pakai
/// BoxShadow biasa (dua arah: gelap di offset 2,2 dan terang di offset -2,2).
/// Ini yang paling reliable di Flutter karena BoxShadow memang didesain
/// buat drop-shadow/outer shadow.
class NeuBox extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  final EdgeInsetsGeometry padding;
  final double blur;
  const NeuBox({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.color = AppColors.neuSurface,
    this.padding = EdgeInsets.zero,
    this.blur = 6,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
              color: AppColors.neuShadowDark,
              offset: const Offset(2, 2),
              blurRadius: blur),
          BoxShadow(
              color: AppColors.neuShadowLight,
              offset: const Offset(-2, 2),
              blurRadius: blur),
        ],
      ),
      child: child,
    );
  }
}

/// Simulasi SATU inner shadow (Flutter tidak punya BoxShadow versi inset).
/// Caranya: gambar layer penuh warna shadow, lalu "lubangi" bagian yang
/// digeser sesuai offset pakai BlendMode.dstOut + blur, sehingga sisa
/// warna shadow cuma keliatan di tepi yang berlawanan arah offset —
/// itulah yang menciptakan ilusi cekung/ke-tekan ke dalam.
class NeuInnerShadow extends StatelessWidget {
  final Color color;
  final Offset offset;
  final double blur;
  final Widget child;
  const NeuInnerShadow({
    super.key,
    required this.color,
    required this.offset,
    required this.child,
    this.blur = 6,
  });
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter:
          _InnerShadowPainter(color: color, offset: offset, blur: blur),
      child: child,
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final Color color;
  final Offset offset;
  final double blur;
  _InnerShadowPainter(
      {required this.color, required this.offset, required this.blur});
  @override
  void paint(Canvas canvas, Size size) {
    final rectOuter = Offset.zero & size;
    final rectInner = Rect.fromLTWH(
      offset.dx,
      offset.dy,
      size.width - offset.dx,
      size.height - offset.dy,
    );
    canvas.saveLayer(rectOuter, Paint());
    canvas.drawRect(rectOuter, Paint()..color = color);
    final eraserPaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);
    canvas.saveLayer(rectOuter, eraserPaint);
    canvas.drawRect(rectInner, Paint()..color = color);
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InnerShadowPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.offset != offset ||
        oldDelegate.blur != blur;
  }
}

/// Gabungan dua NeuInnerShadow (gelap 2,2 + terang -2,2) buat elemen yang
/// perlu kesan "ke-tekan ke dalam" — dipakai buat input field.
class NeuPressedBox extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final Color color;
  const NeuPressedBox({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.color = AppColors.neuFieldFill,
  });
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: NeuInnerShadow(
        color: AppColors.neuShadowDark.withOpacity(0.35),
        offset: const Offset(2, 2),
        child: NeuInnerShadow(
          color: Colors.white.withOpacity(0.08),
          offset: const Offset(-2, 2),
          child: Container(color: color, child: child),
        ),
      ),
    );
  }
}
