import 'package:flutter/material.dart';

/// Placeholder shown when every item has been dismissed.
class EmptyCatalog extends StatelessWidget {
  final VoidCallback onReset;
  const EmptyCatalog({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 88, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Catalog is Empty',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('You removed every item.\nRestore the catalog to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restore),
              label: const Text('Reset Catalog'),
            ),
          ],
        ),
      ),
    );
  }
}
