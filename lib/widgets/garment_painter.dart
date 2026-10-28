import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/product.dart';

/// Lighten (+) or darken (-) a color.
Color shade(Color c, double amount) {
  final hsl = HSLColor.fromColor(c);
  return hsl
      .withLightness((hsl.lightness + amount).clamp(0.0, 1.0).toDouble())
      .toColor();
}

Paint _stroke(Color c, double width) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = StrokeJoin.round
  ..color = c;

/// Draws a clothing item (tee, hoodie, jeans, sneakers...) as a detailed
/// vector illustration. Works at any size, on product cards and on the
/// try-on mannequin.
class GarmentPainter extends CustomPainter {
  final GarmentType type;
  final Color color;
  const GarmentPainter(this.type, this.color);

  @override
  bool shouldRepaint(covariant GarmentPainter old) =>
      old.type != type || old.color != color;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    switch (type) {
      case GarmentType.tee:
      case GarmentType.hoodie:
      case GarmentType.sweater:
      case GarmentType.jacket:
        _top(canvas, size);
        break;
      case GarmentType.jeans:
      case GarmentType.chinos:
      case GarmentType.cargo:
        _pants(canvas, size);
        break;
      case GarmentType.sneaker:
      case GarmentType.runner:
        _sneaker(canvas, size);
        break;
      case GarmentType.boot:
        _boot(canvas, size);
        break;
      case GarmentType.watch:
        _watch(canvas, size);
        break;
      case GarmentType.backpack:
        _backpack(canvas, size);
        break;
    }
  }

  // ------------------------------------------------------------------
  // helpers
  // ------------------------------------------------------------------
  void _fill(Canvas canvas, Size size, Path path, Color base,
      {bool shadow = true}) {
    if (shadow) {
      canvas.drawPath(
        path.shift(Offset(0, size.height * 0.012)),
        Paint()
          ..color = Colors.black.withOpacity(0.12)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    canvas.drawPath(path, Paint()..color = base);
    // soft fabric shading
    canvas.save();
    canvas.clipPath(path);
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.black.withOpacity(0.14),
            Colors.transparent,
            Colors.white.withOpacity(0.10),
            Colors.transparent,
            Colors.black.withOpacity(0.14),
          ],
          stops: const [0, 0.25, 0.5, 0.75, 1],
        ).createShader(rect),
    );
    canvas.restore();
    canvas.drawPath(path, _stroke(shade(base, -0.22), 1.4));
  }

  // ------------------------------------------------------------------
  // TOPS: tee / hoodie / sweater / bomber jacket
  // ------------------------------------------------------------------
  void _top(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final long = type != GarmentType.tee;
    final neckDepth = switch (type) {
      GarmentType.tee => 0.20,
      GarmentType.sweater => 0.17,
      GarmentType.hoodie => 0.15,
      _ => 0.10,
    };
    final outerX = long ? 0.04 : 0.02;
    final outerY = long ? 0.90 : 0.34;
    final innerX = long ? 0.17 : 0.16;
    final innerY = long ? 0.92 : 0.44;
    final armY = long ? 0.42 : 0.36;
    final dark = shade(color, -0.22);
    final band = shade(color, -0.10);
    double fx(double x, bool right) => right ? w * (1 - x) : w * x;

    if (type == GarmentType.hoodie) {
      final hood = Path()
        ..addOval(Rect.fromLTRB(w * .30, 0, w * .70, h * .24));
      _fill(canvas, size, hood, shade(color, -0.10));
    }

    final path = Path()
      ..moveTo(w * .38, h * .05)
      ..lineTo(w * .18, h * .12)
      ..lineTo(w * outerX, h * outerY)
      ..lineTo(w * innerX, h * innerY)
      ..lineTo(w * .25, h * armY)
      ..lineTo(w * .25, h * .97)
      ..lineTo(w * .75, h * .97)
      ..lineTo(w * .75, h * armY)
      ..lineTo(w * (1 - innerX), h * innerY)
      ..lineTo(w * (1 - outerX), h * outerY)
      ..lineTo(w * .82, h * .12)
      ..lineTo(w * .62, h * .05)
      ..quadraticBezierTo(
          w * .5, h * (neckDepth * 2 - 0.05), w * .38, h * .05)
      ..close();
    _fill(canvas, size, path, color);

    // neckline
    final neck = Path()
      ..moveTo(w * .62, h * .05)
      ..quadraticBezierTo(
          w * .5, h * (neckDepth * 2 - 0.05), w * .38, h * .05);
    if (type == GarmentType.hoodie) {
      canvas.drawPath(
          Path.from(neck)..close(), Paint()..color = shade(color, -0.30));
      canvas.drawPath(neck, _stroke(dark, 1.4));
    } else {
      canvas.drawPath(neck, _stroke(band, h * .03));
      canvas.drawPath(neck, _stroke(dark, 1.0));
    }

    if (long) {
      final hem = Rect.fromLTRB(w * .25, h * .90, w * .75, h * .97);
      canvas.drawRect(hem, Paint()..color = band);
      canvas.drawRect(hem, _stroke(dark, 1.0));
      for (final right in [false, true]) {
        final cuff = Path()
          ..moveTo(fx(.0455, right), h * .85)
          ..lineTo(fx(.1625, right), h * .87)
          ..lineTo(fx(.17, right), h * .92)
          ..lineTo(fx(.04, right), h * .90)
          ..close();
        canvas.drawPath(cuff, Paint()..color = band);
        canvas.drawPath(cuff, _stroke(dark, 1.0));
      }
    } else {
      canvas.drawLine(Offset(w * .25, h * .925), Offset(w * .75, h * .925),
          _stroke(dark, 1.0));
      for (final right in [false, true]) {
        canvas.drawLine(Offset(fx(.03, right), h * .31),
            Offset(fx(.165, right), h * .41), _stroke(dark, 1.0));
      }
    }

    if (type == GarmentType.hoodie) {
      final pocket = Path()
        ..moveTo(w * .33, h * .66)
        ..lineTo(w * .67, h * .66)
        ..lineTo(w * .72, h * .85)
        ..lineTo(w * .28, h * .85)
        ..close();
      canvas.drawPath(pocket, Paint()..color = shade(color, -0.05));
      canvas.drawPath(pocket, _stroke(dark, 1.2));
      final cord = shade(color, 0.32);
      canvas.drawLine(Offset(w * .45, h * .17), Offset(w * .44, h * .40),
          _stroke(cord, 2));
      canvas.drawLine(Offset(w * .55, h * .17), Offset(w * .56, h * .40),
          _stroke(cord, 2));
      canvas.drawCircle(Offset(w * .44, h * .41), 2.2, Paint()..color = cord);
      canvas.drawCircle(Offset(w * .56, h * .41), 2.2, Paint()..color = cord);
    } else if (type == GarmentType.sweater) {
      canvas.save();
      canvas.clipPath(path);
      final rib = _stroke(Colors.black.withOpacity(0.07), 1.2);
      for (var x = 0.27; x < 0.75; x += 0.035) {
        canvas.drawLine(Offset(w * x, h * .20), Offset(w * x, h * .89), rib);
      }
      for (var x = 0.06; x < 0.16; x += 0.035) {
        canvas.drawLine(Offset(w * x, h * .36), Offset(w * x, h * .83), rib);
        canvas.drawLine(
            Offset(w * (1 - x), h * .36), Offset(w * (1 - x), h * .83), rib);
      }
      canvas.restore();
    } else if (type == GarmentType.jacket) {
      canvas.drawLine(Offset(w * .5, h * .12), Offset(w * .5, h * .97),
          _stroke(shade(color, -0.32), 1.6));
      canvas.drawRRect(
        RRect.fromLTRBR(
            w * .485, h * .20, w * .515, h * .27, const Radius.circular(2)),
        Paint()..color = const Color(0xFFD9D9D9),
      );
      for (final right in [false, true]) {
        canvas.drawLine(Offset(fx(.30, right), h * .62),
            Offset(fx(.34, right), h * .80), _stroke(dark, 1.4));
      }
      final patch = Rect.fromLTRB(w * .60, h * .30, w * .70, h * .37);
      canvas.drawRect(patch, Paint()..color = const Color(0xFFFF9F43));
      canvas.drawRect(patch, _stroke(dark, 0.8));
    }
  }

  // ------------------------------------------------------------------
  // BOTTOMS: jeans / chinos / cargo
  // ------------------------------------------------------------------
  void _pants(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = shade(color, -0.22);
    final stitch = type == GarmentType.jeans
        ? const Color(0xFFD9A441)
        : shade(color, -0.16);

    final path = Path()
      ..moveTo(w * .08, h * .02)
      ..lineTo(w * .92, h * .02)
      ..lineTo(w * .88, h * .98)
      ..lineTo(w * .54, h * .98)
      ..lineTo(w * .50, h * .30)
      ..lineTo(w * .46, h * .98)
      ..lineTo(w * .12, h * .98)
      ..close();
    _fill(canvas, size, path, color);

    // waistband + belt loops
    final band = Rect.fromLTRB(w * .08, h * .02, w * .92, h * .085);
    canvas.drawRect(band, Paint()..color = shade(color, -0.07));
    canvas.drawRect(band, _stroke(dark, 1.0));
    for (final x in [0.2, 0.5, 0.8]) {
      final r = Rect.fromLTWH(w * x - w * .012, h * .012, w * .024, h * .085);
      canvas.drawRect(r, Paint()..color = shade(color, -0.14));
    }
    canvas.drawCircle(
        Offset(w * .5, h * .053), w * .018, Paint()..color = shade(color, -0.30));

    // fly
    canvas.drawLine(
        Offset(w * .5, h * .085), Offset(w * .5, h * .30), _stroke(stitch, 1.0));
    canvas.drawPath(
      Path()
        ..moveTo(w * .5, h * .085)
        ..quadraticBezierTo(w * .57, h * .20, w * .53, h * .29),
      _stroke(stitch, 1.0),
    );

    // front pockets
    canvas.drawPath(
      Path()
        ..moveTo(w * .34, h * .085)
        ..quadraticBezierTo(w * .34, h * .26, w * .11, h * .24),
      _stroke(stitch, 1.2),
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * .66, h * .085)
        ..quadraticBezierTo(w * .66, h * .26, w * .89, h * .24),
      _stroke(stitch, 1.2),
    );

    if (type == GarmentType.jeans) {
      final fade = Paint()..color = Colors.white.withOpacity(0.10);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w * .29, h * .58), width: w * .20, height: h * .14),
          fade);
      canvas.drawOval(
          Rect.fromCenter(
              center: Offset(w * .71, h * .58), width: w * .20, height: h * .14),
          fade);
      canvas.drawLine(Offset(w * .13, h * .93), Offset(w * .45, h * .93),
          _stroke(stitch, 1.0));
      canvas.drawLine(Offset(w * .55, h * .93), Offset(w * .87, h * .93),
          _stroke(stitch, 1.0));
    } else if (type == GarmentType.chinos) {
      canvas.drawLine(Offset(w * .29, h * .32), Offset(w * .29, h * .97),
          _stroke(dark.withOpacity(0.5), 1.0));
      canvas.drawLine(Offset(w * .71, h * .32), Offset(w * .71, h * .97),
          _stroke(dark.withOpacity(0.5), 1.0));
    } else if (type == GarmentType.cargo) {
      for (final r in [
        Rect.fromLTRB(w * .13, h * .50, w * .31, h * .70),
        Rect.fromLTRB(w * .69, h * .50, w * .87, h * .70),
      ]) {
        canvas.drawRect(r, Paint()..color = shade(color, -0.06));
        canvas.drawRect(r, _stroke(dark, 1.1));
        canvas.drawLine(Offset(r.left, r.top + r.height * .30),
            Offset(r.right, r.top + r.height * .30), _stroke(dark, 1.1));
        canvas.drawCircle(Offset(r.center.dx, r.top + r.height * .30), 1.8,
            Paint()..color = dark);
      }
      for (final r in [
        Rect.fromLTRB(w * .12, h * .90, w * .46, h * .98),
        Rect.fromLTRB(w * .54, h * .90, w * .88, h * .98),
      ]) {
        canvas.drawRect(r, Paint()..color = shade(color, -0.12));
        canvas.drawRect(r, _stroke(dark, 1.0));
      }
    }
  }

  // ------------------------------------------------------------------
  // SHOES
  // ------------------------------------------------------------------
  void _sneaker(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final runner = type == GarmentType.runner;
    final soleTop = runner ? 0.62 : 0.70;
    final light = HSLColor.fromColor(color).lightness > 0.75;
    final dark = shade(color, -0.22);
    final soleColor =
        light ? const Color(0xFFD8D3C8) : const Color(0xFFF4F1EA);

    canvas.drawOval(Rect.fromLTRB(w * .05, h * .90, w * .98, h * 1.0),
        Paint()..color = Colors.black.withOpacity(0.08));

    final upper = Path()
      ..moveTo(w * .07, h * (soleTop + .04))
      ..lineTo(w * .05, h * .30)
      ..quadraticBezierTo(w * .10, h * .12, w * .27, h * .14)
      ..lineTo(w * .40, h * .20)
      ..lineTo(w * .50, h * .30)
      ..quadraticBezierTo(w * .66, h * .40, w * .84, h * .50)
      ..quadraticBezierTo(w * .985, h * .58, w * .975, h * (soleTop + .04))
      ..close();
    _fill(canvas, size, upper, color);

    // toe cap seam
    canvas.drawPath(
      Path()
        ..moveTo(w * .74, h * .45)
        ..quadraticBezierTo(w * .80, h * .60, w * .77, h * soleTop),
      _stroke(dark, 1.2),
    );
    // side stripes
    final stripe = light ? shade(color, -0.18) : shade(color, 0.28);
    canvas.drawPath(
      Path()
        ..moveTo(w * .30, h * .42)
        ..quadraticBezierTo(w * .48, h * .58, w * .62, h * .45),
      _stroke(stripe, h * .035),
    );
    if (runner) {
      canvas.drawPath(
        Path()
          ..moveTo(w * .26, h * .50)
          ..quadraticBezierTo(w * .46, h * .66, w * .60, h * .53),
        _stroke(stripe, h * .035),
      );
    }
    // tongue
    final tongue = Path()
      ..moveTo(w * .36, h * .10)
      ..lineTo(w * .45, h * .08)
      ..lineTo(w * .53, h * .30)
      ..lineTo(w * .44, h * .31)
      ..close();
    canvas.drawPath(tongue, Paint()..color = shade(color, 0.08));
    canvas.drawPath(tongue, _stroke(dark, 1.0));
    // laces
    final lace = light ? const Color(0xFFB9B4AA) : Colors.white70;
    for (var i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(w * (.43 + .055 * i), h * (.25 + .04 * i)),
        Offset(w * (.51 + .055 * i), h * (.32 + .04 * i)),
        _stroke(lace, 2),
      );
    }
    // heel tab
    canvas.drawRRect(
      RRect.fromLTRBR(
          w * .04, h * .30, w * .11, h * .50, const Radius.circular(3)),
      Paint()..color = shade(color, -0.12),
    );
    // sole
    final sole = RRect.fromLTRBR(
        w * .025, h * soleTop, w * .985, h * .93, Radius.circular(h * .12));
    canvas.drawRRect(sole, Paint()..color = soleColor);
    canvas.drawRRect(sole, _stroke(shade(soleColor, -0.22), 1.2));
    canvas.drawLine(
      Offset(w * .06, h * (soleTop + .12)),
      Offset(w * .95, h * (soleTop + .12)),
      _stroke(shade(soleColor, -0.12), 1.0),
    );
  }

  void _boot(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = shade(color, -0.22);
    final soleColor = shade(color, -0.30);

    canvas.drawOval(Rect.fromLTRB(w * .05, h * .92, w * .98, h * 1.0),
        Paint()..color = Colors.black.withOpacity(0.08));

    final upper = Path()
      ..moveTo(w * .09, h * .80)
      ..lineTo(w * .09, h * .04)
      ..lineTo(w * .50, h * .04)
      ..lineTo(w * .52, h * .42)
      ..quadraticBezierTo(w * .66, h * .52, w * .86, h * .58)
      ..quadraticBezierTo(w * .985, h * .65, w * .975, h * .80)
      ..close();
    _fill(canvas, size, upper, color);

    // top stitching + pull tab
    canvas.drawLine(Offset(w * .09, h * .10), Offset(w * .50, h * .10),
        _stroke(dark, 1.0));
    canvas.drawRRect(
      RRect.fromLTRBR(
          w * .11, -h * .0, w * .18, h * .12, const Radius.circular(3)),
      Paint()..color = shade(color, 0.10),
    );
    // elastic side panel
    final panel = Path()
      ..moveTo(w * .20, h * .16)
      ..lineTo(w * .40, h * .16)
      ..lineTo(w * .43, h * .44)
      ..lineTo(w * .20, h * .48)
      ..close();
    canvas.drawPath(panel, Paint()..color = shade(color, -0.14));
    canvas.drawPath(panel, _stroke(dark, 1.0));
    for (var i = 1; i < 6; i++) {
      final y = .16 + i * .055;
      canvas.drawLine(Offset(w * .21, h * y), Offset(w * .42, h * y),
          _stroke(Colors.white.withOpacity(0.10), 1.0));
    }
    // toe seam
    canvas.drawPath(
      Path()
        ..moveTo(w * .70, h * .55)
        ..quadraticBezierTo(w * .75, h * .68, w * .73, h * .80),
      _stroke(dark, 1.1),
    );
    // sole + heel
    final sole = RRect.fromLTRBR(
        w * .06, h * .80, w * .985, h * .90, Radius.circular(h * .05));
    canvas.drawRRect(sole, Paint()..color = soleColor);
    canvas.drawRRect(sole, _stroke(shade(soleColor, -0.15), 1.0));
    final heel = RRect.fromLTRBR(
        w * .06, h * .88, w * .36, h * .99, Radius.circular(h * .03));
    canvas.drawRRect(heel, Paint()..color = shade(soleColor, -0.05));
    canvas.drawRRect(heel, _stroke(shade(soleColor, -0.2), 1.0));
  }

  // ------------------------------------------------------------------
  // ACCESSORIES
  // ------------------------------------------------------------------
  void _watch(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final strap = shade(color, -0.32);
    final straps = [
      RRect.fromLTRBR(w * .30, 0, w * .70, h * .40, Radius.circular(w * .08)),
      RRect.fromLTRBR(w * .30, h * .60, w * .70, h, Radius.circular(w * .08)),
    ];
    for (final r in straps) {
      canvas.drawRRect(r, Paint()..color = strap);
      canvas.drawRRect(r, _stroke(shade(strap, -0.15), 1.0));
    }
    final mesh = _stroke(Colors.black.withOpacity(0.18), 0.8);
    for (var y = 0.04; y < 0.38; y += 0.05) {
      canvas.drawLine(Offset(w * .31, h * y), Offset(w * .69, h * y), mesh);
    }
    for (var y = 0.64; y < 0.98; y += 0.05) {
      canvas.drawLine(Offset(w * .31, h * y), Offset(w * .69, h * y), mesh);
    }

    final c = Offset(w * .5, h * .5);
    final r = math.min(w * .36, h * .2);
    canvas.drawRRect(
      RRect.fromLTRBR(c.dx + r - 1, c.dy - h * .025, c.dx + r + w * .05,
          c.dy + h * .025, const Radius.circular(2)),
      Paint()..color = shade(color, -0.10),
    );
    canvas.drawCircle(c, r, Paint()..color = color);
    canvas.drawCircle(c, r, _stroke(shade(color, -0.25), 1.4));
    canvas.drawCircle(c, r * .8, Paint()..color = const Color(0xFFF7F4EC));
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * (r * .62),
        c + Offset(math.cos(a), math.sin(a)) * (r * .74),
        _stroke(Colors.black87, 1.0),
      );
    }
    canvas.drawLine(c, c + Offset(0, -r * .5), _stroke(Colors.black87, 1.3));
    canvas.drawLine(c, c + Offset(r * .35, r * .05), _stroke(Colors.black87, 1.1));
    canvas.drawCircle(c, 1.6, Paint()..color = Colors.red.shade700);
  }

  void _backpack(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final dark = shade(color, -0.22);

    // top handle
    canvas.drawPath(
      Path()
        ..moveTo(w * .38, h * .15)
        ..quadraticBezierTo(w * .5, h * -.02, w * .62, h * .15),
      _stroke(shade(color, -0.18), 3.5),
    );
    // main body
    final body =
        RRect.fromLTRBR(w * .12, h * .14, w * .88, h * .99, Radius.circular(w * .22));
    _fill(canvas, size, Path()..addRRect(body), color);
    // side pockets
    for (final r in [
      RRect.fromLTRBR(w * .03, h * .58, w * .16, h * .88, Radius.circular(w * .05)),
      RRect.fromLTRBR(w * .84, h * .58, w * .97, h * .88, Radius.circular(w * .05)),
    ]) {
      canvas.drawRRect(r, Paint()..color = shade(color, -0.12));
      canvas.drawRRect(r, _stroke(dark, 1.1));
    }
    // top flap
    final flap = RRect.fromLTRBR(
        w * .12, h * .14, w * .88, h * .44, Radius.circular(w * .2));
    canvas.drawRRect(flap, Paint()..color = shade(color, 0.05));
    canvas.drawRRect(flap, _stroke(dark, 1.3));
    // front pocket
    final pocket = RRect.fromLTRBR(
        w * .22, h * .56, w * .78, h * .90, Radius.circular(w * .08));
    canvas.drawRRect(pocket, Paint()..color = shade(color, -0.08));
    canvas.drawRRect(pocket, _stroke(dark, 1.2));
    canvas.drawLine(Offset(w * .24, h * .61), Offset(w * .76, h * .61),
        _stroke(dark, 1.1));
    canvas.drawRRect(
      RRect.fromLTRBR(
          w * .46, h * .60, w * .54, h * .68, const Radius.circular(2)),
      Paint()..color = const Color(0xFFD9D9D9),
    );
    // buckle straps
    for (final x in [0.36, 0.64]) {
      canvas.drawLine(Offset(w * x, h * .30), Offset(w * x, h * .52),
          _stroke(shade(color, -0.30), 4));
    }
    canvas.drawRRect(
      RRect.fromLTRBR(
          w * .44, h * .40, w * .56, h * .50, const Radius.circular(2)),
      Paint()..color = const Color(0xFFD9D9D9),
    );
  }
}
