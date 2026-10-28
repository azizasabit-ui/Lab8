import 'package:flutter/material.dart';

import '../models/product.dart';
import 'garment_painter.dart';

/// Virtual try-on: a neutral mannequin wearing the selected garments.
/// Each garment is the same illustration used on the product page,
/// placed on the body; changes fade in/out.
class Mannequin extends StatelessWidget {
  final Product? top;
  final Product? bottom;
  final Product? shoes;
  final Product? accessory;

  const Mannequin({
    super.key,
    this.top,
    this.bottom,
    this.shoes,
    this.accessory,
  });

  Widget _garment(
    Product? p,
    String slot, {
    required double x,
    required double y,
    required double w,
    required double h,
    bool mirror = false,
  }) {
    Widget child;
    if (p == null) {
      child = SizedBox.shrink(key: ValueKey('empty-$slot'));
    } else {
      final paint = CustomPaint(
        size: Size(w, h),
        painter: GarmentPainter(p.garment, p.color),
      );
      child = mirror
          ? Transform.flip(
              key: ValueKey('$slot-${p.id}'), flipX: true, child: paint)
          : KeyedSubtree(key: ValueKey('$slot-${p.id}'), child: paint);
    }
    return Positioned(
      left: x,
      top: y,
      width: w,
      height: h,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (c, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
              scale: Tween(begin: 0.92, end: 1.0).animate(anim), child: c),
        ),
        child: child,
      ),
    );
  }

  Widget _shoe(double x, bool mirror) {
    final p = shoes;
    final aspect = p?.garment.aspect ?? 2.2;
    const w = 58.0;
    final h = w / aspect;
    return _garment(p, mirror ? 'shoeL' : 'shoeR',
        x: x, y: 346 - h, w: w, h: h, mirror: mirror);
  }

  @override
  Widget build(BuildContext context) {
    final bag = accessory?.garment == GarmentType.backpack ? accessory : null;
    final watch = accessory?.garment == GarmentType.watch ? accessory : null;

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 200,
        height: 360,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // floor shadow
            Positioned(
              left: 28,
              top: 340,
              child: Container(
                width: 144,
                height: 14,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            // backpack sits behind the body
            _garment(bag, 'bag', x: 38, y: 46, w: 124, h: 146),
            // body
            Positioned.fill(
              child: CustomPaint(painter: _BodyPainter()),
            ),
            // clothes (bottom first, then shoes, then top over the waist)
            _garment(bottom, 'bottom', x: 57, y: 172, w: 86, h: 160),
            _shoe(42, true),
            _shoe(100, false),
            _garment(top, 'top', x: 24, y: 52, w: 152, h: 142),
            // backpack straps over the shoulders
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: bag == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: CustomPaint(
                  painter: _StrapsPainter(bag?.color ?? Colors.transparent),
                ),
              ),
            ),
            // watch on the left wrist
            _garment(watch, 'watch', x: 33, y: 146, w: 24, h: 40),
          ],
        ),
      ),
    );
  }
}

class _BodyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = const Color(0xFFE9E5DF);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = const Color(0xFFCBC5BB);
    void shape(Path p) {
      canvas.drawPath(p, fill);
      canvas.drawPath(p, edge);
    }

    const r13 = Radius.circular(13);
    // legs
    shape(Path()..addRRect(RRect.fromLTRBR(68, 178, 98, 336, r13)));
    shape(Path()..addRRect(RRect.fromLTRBR(102, 178, 132, 336, r13)));
    // feet
    shape(Path()..addOval(const Rect.fromLTRB(58, 326, 104, 344)));
    shape(Path()..addOval(const Rect.fromLTRB(96, 326, 142, 344)));
    // arms + hands
    shape(Path()..addRRect(RRect.fromLTRBR(36, 62, 60, 164, const Radius.circular(12))));
    shape(Path()..addRRect(RRect.fromLTRBR(140, 62, 164, 164, const Radius.circular(12))));
    shape(Path()..addOval(const Rect.fromLTRB(36, 158, 58, 184)));
    shape(Path()..addOval(const Rect.fromLTRB(142, 158, 164, 184)));
    // neck + head
    shape(Path()..addRRect(RRect.fromLTRBR(91, 44, 109, 64, const Radius.circular(6))));
    shape(Path()..addOval(const Rect.fromLTRB(80, 0, 120, 48)));
    // torso
    shape(
      Path()
        ..moveTo(62, 62)
        ..quadraticBezierTo(100, 50, 138, 62)
        ..lineTo(131, 120)
        ..quadraticBezierTo(126, 150, 133, 184)
        ..lineTo(67, 184)
        ..quadraticBezierTo(74, 150, 69, 120)
        ..close(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StrapsPainter extends CustomPainter {
  final Color color;
  const _StrapsPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = shade(color, -0.28);
    for (final x in [66.0, 124.0]) {
      canvas.drawRRect(
          RRect.fromLTRBR(x, 54, x + 10, 150, const Radius.circular(5)), p);
    }
  }

  @override
  bool shouldRepaint(covariant _StrapsPainter old) => old.color != color;
}
