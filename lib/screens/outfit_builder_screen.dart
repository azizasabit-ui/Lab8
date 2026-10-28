import 'dart:math';

import 'package:flutter/material.dart';

import '../data/products_data.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../utils/style_scorer.dart';
import '../widgets/mannequin.dart';
import '../widgets/product_image.dart';

/// UNIQUE FEATURE: live Outfit Builder with a color-theory "Style Score".
class OutfitBuilderScreen extends StatefulWidget {
  final Product? initial;
  const OutfitBuilderScreen({super.key, this.initial});

  @override
  State<OutfitBuilderScreen> createState() => _OutfitBuilderScreenState();
}

class _OutfitBuilderScreenState extends State<OutfitBuilderScreen> {
  final Map<ProductCategory, Product?> _outfit = {
    for (final c in ProductCategory.values) c: null,
  };
  ProductCategory _tab = ProductCategory.top;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    final p = widget.initial;
    if (p != null) {
      _outfit[p.category] = p;
      _tab = p.category;
    }
  }

  List<Product> get _selected => _outfit.values.whereType<Product>().toList();
  double get _total => _selected.fold<double>(0, (s, p) => s + p.price);

  void _select(Product p) {
    setState(() {
      _outfit[p.category] = _outfit[p.category]?.id == p.id ? null : p;
    });
  }

  void _shuffle() {
    setState(() {
      for (final c in ProductCategory.values) {
        final list = kProducts.where((p) => p.category == c).toList();
        _outfit[c] = list[_random.nextInt(list.length)];
      }
    });
  }

  void _clear() => setState(() {
        for (final c in ProductCategory.values) {
          _outfit[c] = null;
        }
      });

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  void _addAllToCart() {
    for (final p in _selected) {
      appState.addToCart(p, p.defaultSize);
    }
    _snack('${_selected.length} items added to cart (default sizes)');
  }

  void _saveLook() {
    if (_selected.isEmpty) {
      _snack('Pick at least one piece first');
      return;
    }
    final items = {
      for (final e in _outfit.entries)
        if (e.value != null) e.key: e.value!,
    };
    final score = StyleScorer.evaluate(_outfit).score;
    appState.saveLook(
        SavedLook('Look #${appState.looks.length + 1}', items, score));
    _snack('Look saved!');
  }

  void _showLooks() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ListenableBuilder(
        listenable: appState,
        builder: (context, _) {
          final looks = appState.looks;
          if (looks.isEmpty) {
            return const SizedBox(
              height: 160,
              child: Center(child: Text('No saved looks yet')),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            itemCount: looks.length,
            itemBuilder: (_, i) {
              final look = looks[i];
              return ListTile(
                leading: CircleAvatar(child: Text('${look.score}')),
                title: Text(look.name),
                subtitle: Text(
                  look.items.values.map((p) => p.name).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => appState.deleteLook(look),
                ),
                onTap: () {
                  setState(() {
                    for (final c in ProductCategory.values) {
                      _outfit[c] = look.items[c];
                    }
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          );
        },
      ),
    );
  }

  Color _scoreColor(double v) =>
      v < 0.4 ? Colors.red : (v < 0.6 ? Colors.orange : (v < 0.8 ? Colors.lightGreen : Colors.green));

  Widget _previewPanel(StyleResult r) {
    return LayoutBuilder(
      builder: (context, c) {
        final showScore = c.maxHeight > 260;
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Mannequin(
                  top: _outfit[ProductCategory.top],
                  bottom: _outfit[ProductCategory.bottom],
                  shoes: _outfit[ProductCategory.shoes],
                  accessory: _outfit[ProductCategory.accessory],
                ),
              ),
            ),
            if (showScore)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Style score',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        Text('${r.score}/100'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: r.score / 100),
                      duration: const Duration(milliseconds: 500),
                      builder: (_, v, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 10,
                          color: _scoreColor(v),
                          backgroundColor: Colors.grey.shade300,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(r.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(r.tip,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _tile(Product p) {
    final selected = _outfit[p.category]?.id == p.id;
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
            color: selected ? primary : Colors.transparent, width: 2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _select(p),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: ProductImage(product: p, padding: 4),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold)),
                    Text('\$${p.price.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade700)),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _picker() {
    final items = kProducts.where((p) => p.category == _tab).toList();
    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            scrollDirection: Axis.horizontal,
            itemCount: ProductCategory.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (_, i) {
              final c = ProductCategory.values[i];
              return ChoiceChip(
                avatar: Icon(c.icon, size: 16),
                label: Text(c.label),
                selected: c == _tab,
                onSelected: (_) => setState(() => _tab = c),
              );
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            itemCount: items.length,
            itemBuilder: (_, i) => _tile(items[i]),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = StyleScorer.evaluate(_outfit);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Builder'),
        actions: [
          IconButton(
            tooltip: 'Save look',
            icon: const Icon(Icons.bookmark_add_outlined),
            onPressed: _saveLook,
          ),
          IconButton(
            tooltip: 'My looks',
            icon: const Icon(Icons.collections_bookmark_outlined),
            onPressed: _showLooks,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            children: [
              Expanded(flex: 4, child: _previewPanel(result)),
              Expanded(flex: 5, child: _picker()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Material(
        elevation: 12,
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                IconButton.outlined(
                  tooltip: 'Shuffle (surprise me)',
                  icon: const Icon(Icons.casino_outlined),
                  onPressed: _shuffle,
                ),
                IconButton.outlined(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.refresh),
                  onPressed: _selected.isEmpty ? null : _clear,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48)),
                    onPressed: _selected.isEmpty ? null : _addAllToCart,
                    icon: const Icon(Icons.add_shopping_cart),
                    label: Text(
                      'Add look · \$${_total.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
