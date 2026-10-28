import 'package:flutter/material.dart';

import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/bottom_action_bar.dart';
import '../widgets/category_badge.dart';
import '../widgets/product_image.dart';
import '../widgets/rating_stars.dart';
import 'outfit_builder_screen.dart';

/// LAB 5: Adaptive item detail screen.
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late bool _isBookmarked = appState.isFavorite(widget.product.id);
  late String _selectedSize = widget.product.defaultSize;
  int _quantity = 1;

  static const _badgeColors = [
    Color(0xFF6C5CE7),
    Color(0xFF00B894),
    Color(0xFFE17055),
    Color(0xFF0984E3),
  ];

  void _toggleBookmark() {
    setState(() => _isBookmarked = !_isBookmarked);
    appState.toggleFavorite(widget.product.id);
  }

  void _addToCart() {
    appState.addToCart(widget.product, _selectedSize, qty: _quantity);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(
            'Added $_quantity x ${widget.product.name} ($_selectedSize)'),
      ));
  }

  Widget _buildCover(Product p) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(32)),
            child: ProductImage(product: p, padding: 28),
          ),
          // Bookmark badge
          Positioned(
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: _toggleBookmark,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.15), blurRadius: 8),
                  ],
                ),
                child: Icon(
                  _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: _isBookmarked
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          // Brand label overlay
          Positioned(
            left: 16,
            bottom: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                p.brand.toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final primary = Theme.of(context).colorScheme.primary;
    final badges = [p.category.label, ...p.tags];

    return Scaffold(
      appBar: AppBar(
        // 1) AppBar back icon -> Navigator.pop
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCover(p),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(p.name,
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Text('\$${p.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RatingStars(rating: p.rating, reviews: p.reviews),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (int i = 0; i < badges.length; i++)
                            CategoryBadge(
                              label: badges[i],
                              color: _badgeColors[i % _badgeColors.length],
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: p.color,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Color: ${p.colorName}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(p.description,
                          style: TextStyle(
                              height: 1.5, color: Colors.grey.shade800)),
                      const SizedBox(height: 20),
                      const Text('Size',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final s in p.sizes)
                            ChoiceChip(
                              label: Text(s),
                              selected: s == _selectedSize,
                              onSelected: (_) =>
                                  setState(() => _selectedSize = s),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Quantity',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                          ),
                          IconButton.outlined(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : null,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('$_quantity',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          ),
                          IconButton.outlined(
                            icon: const Icon(Icons.add),
                            onPressed: _quantity < 10
                                ? () => setState(() => _quantity++)
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OutfitBuilderScreen(initial: p),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48)),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Try it on the mannequin'),
                      ),
                      const SizedBox(height: 8),
                      // 2) In-body back button -> Navigator.pop
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(48)),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 16),
                        label: const Text('Back to shopping'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        total: p.price * _quantity,
        onAddToCart: _addToCart,
      ),
    );
  }
}
