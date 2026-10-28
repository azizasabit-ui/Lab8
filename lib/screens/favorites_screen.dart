import 'package:flutter/material.dart';

import '../data/product_generator.dart';
import '../state/app_state.dart';
import '../widgets/product_image.dart';

/// LAB 7 - Tab 2: saved items.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final favs =
            allKnownProducts.where((p) => appState.isFavorite(p.id)).toList();
        return Scaffold(
          appBar: AppBar(title: Text('Favorites (${favs.length})')),
          body: favs.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 72, color: Colors.grey),
                        SizedBox(height: 12),
                        Text(
                          'No favorites yet.\nTap the heart on any item in the Feed.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: favs.length,
                      itemBuilder: (_, i) {
                        final p = favs[i];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            // pass the whole Product object as argument
                            onTap: () => Navigator.of(context)
                                .pushNamed('/detail', arguments: p),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: ProductImage(product: p, padding: 6),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.brand,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey.shade600)),
                                        Text(p.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Flexible(
                                              child: Text(
                                                '\$${p.price.toStringAsFixed(2)}',
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.w800,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(Icons.star_rounded,
                                                size: 16,
                                                color: Colors.amber),
                                            Text(p.rating.toStringAsFixed(1),
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Remove from favorites',
                                    icon: const Icon(Icons.favorite,
                                        color: Colors.red),
                                    onPressed: () =>
                                        appState.toggleFavorite(p.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
        );
      },
    );
  }
}
