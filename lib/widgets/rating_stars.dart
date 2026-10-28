import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final int? reviews;
  final double size;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviews,
    this.size = 18,
  });

  IconData _iconFor(int index) {
    if (rating >= index + 1) return Icons.star_rounded;
    if (rating >= index + 0.5) return Icons.star_half_rounded;
    return Icons.star_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(_iconFor(i), size: size, color: Colors.amber),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            reviews == null
                ? rating.toStringAsFixed(1)
                : '${rating.toStringAsFixed(1)} ($reviews)',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: size * 0.75,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
