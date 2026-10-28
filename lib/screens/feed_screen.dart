import 'package:flutter/material.dart';

import '../data/products_data.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'outfit_builder_screen.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  ProductCategory? _filter; // null = All
  bool _onlyFavorites = false;

  List<Product> get _filtered => kProducts.where((p) {
        if (_filter != null && p.category != _filter) return false;
        if (_onlyFavorites && !appState.isFavorite(p.id)) return false;
        return true;
      }).toList();

  void _open(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  Widget _hero() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1E2F), Color(0xFF6C5CE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('NEW FEATURE',
                    style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.5)),
                const SizedBox(height: 6),
                const Text('Build your perfect look',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                const Text(
                  'Mix tops, bottoms & shoes on a live mannequin and get an '
                  'instant style score.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: () => _open(const OutfitBuilderScreen()),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E1E2F),
                  ),
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Try Outfit Builder'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.checkroom, size: 72, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _filters() {
    final options = <ProductCategory?>[null, ...ProductCategory.values];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = options[i];
          return ChoiceChip(
            label: Text(c?.label ?? 'All'),
            selected: c == _filter,
            onSelected: (_) => setState(() => _filter = c),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final products = _filtered;
        return Scaffold(
          appBar: AppBar(
            title: const Text('THREADLY',
                style: TextStyle(
                    fontWeight: FontWeight.w900, letterSpacing: 2)),
            actions: [
              IconButton(
                tooltip: 'Favorites only',
                icon: Icon(
                  _onlyFavorites ? Icons.favorite : Icons.favorite_border,
                  color: _onlyFavorites ? Colors.red : null,
                ),
                onPressed: () =>
                    setState(() => _onlyFavorites = !_onlyFavorites),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      tooltip: 'Cart',
                      icon: const Icon(Icons.shopping_bag_outlined),
                      onPressed: () => _open(const CartScreen()),
                    ),
                    if (appState.cartCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text('${appState.cartCount}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 10)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _hero()),
                  SliverToBoxAdapter(child: _filters()),
                  if (products.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text('Nothing here yet. Tap a heart to add favorites!',
                              textAlign: TextAlign.center),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.all(16),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 240,
                          mainAxisExtent: 290,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final p = products[i];
                            return ProductCard(
                              product: p,
                              isFavorite: appState.isFavorite(p.id),
                              // Navigator.push with arguments (named route)
                              onTap: () => Navigator.of(context)
                                  .pushNamed('/detail', arguments: p),
                              onFavoriteTap: () =>
                                  appState.toggleFavorite(p.id),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
