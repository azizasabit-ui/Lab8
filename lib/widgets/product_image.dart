import 'package:flutter/material.dart';

import '../models/product.dart';
import 'garment_painter.dart';

/// Product "photo": shows `imageUrl` if provided (and loadable),
/// otherwise a studio-style illustration of the garment.
class ProductImage extends StatelessWidget {
  final Product product;
  final double padding;

  const ProductImage({super.key, required this.product, this.padding = 16});

  Widget _illustration() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6F6FA), Color(0xFFE2E2EA)],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Center(
          child: AspectRatio(
            aspectRatio: product.garment.aspect,
            child: CustomPaint(
              painter: GarmentPainter(product.garment, product.color),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    if (url == null) return _illustration();
    return Image.network(
      url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => _illustration(),
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : _illustration(),
    );
  }
}
