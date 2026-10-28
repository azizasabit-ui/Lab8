import 'package:flutter/material.dart';

/// Red "delete" background revealed when swiping right-to-left.
class DismissBackground extends StatelessWidget {
  final double radius;
  final bool showLabel;

  const DismissBackground({
    super.key,
    this.radius = 0,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 24),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabel)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text('Delete',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          const Icon(Icons.delete, color: Colors.white),
        ],
      ),
    );
  }
}
