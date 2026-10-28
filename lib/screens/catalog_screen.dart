import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/product_generator.dart';
import '../data/products_data.dart';
import '../models/product.dart';
import '../state/app_state.dart';
import '../widgets/dismiss_background.dart';
import '../widgets/empty_catalog.dart';
import '../widgets/product_card.dart';
import '../widgets/product_list_tile.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late List<Product> _items = List.of(kProducts);
  bool _isGrid = false;

  void _showSnack(String text, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(text),
        action: action,
      ));
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    final item = generateProduct();
    setState(() => _items.insert(0, item));
    _showSnack('New arrival: ${item.name}');
  }

  void _remove(int index) {
    final removed = _items[index];
    setState(() => _items.removeAt(index));
    _showSnack(
      '${removed.name} removed',
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () {
          if (!mounted) return;
          setState(() {
            _items.insert(math.min(index, _items.length), removed);
          });
        },
      ),
    );
  }

  void _reset() {
    setState(() => _items = List.of(kProducts));
    _showSnack('Catalog restored');
  }

  void _openDetail(Product p) =>
      Navigator.of(context).pushNamed('/detail', arguments: p);

  Widget _buildList() {
    return ListView.separated(
      key: const ValueKey('list-view'),
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.6),
      itemBuilder: (context, index) {
        final p = _items[index];
        return Dismissible(
          key: ValueKey(p.id),
          direction: DismissDirection.endToStart,
          background: const DismissBackground(),
          secondaryBackground: const DismissBackground(),
          onDismissed: (_) => _remove(index),
          child: ProductListTile(product: p, onTap: () => _openDetail(p)),
        );
      },
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      key: const ValueKey('grid-view'),
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final p = _items[index];
        return Dismissible(
          key: ValueKey(p.id),
          direction: DismissDirection.endToStart,
          background: const DismissBackground(radius: 18, showLabel: false),
          secondaryBackground:
              const DismissBackground(radius: 18, showLabel: false),
          onDismissed: (_) => _remove(index),
          child: ProductCard(
            product: p,
            isFavorite: appState.isFavorite(p.id),
            onTap: () => _openDetail(p),
            onFavoriteTap: () => appState.toggleFavorite(p.id),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return LayoutBuilder(
      builder: (context, constraints) => ListView(
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: constraints.maxHeight,
            child: EmptyCatalog(onReset: _reset),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text('Smart Catalog (${_items.length})'),
          actions: [
            IconButton(
              tooltip: 'Reset catalog',
              icon: const Icon(Icons.restore),
              onPressed: _reset,
            ),
            IconButton(
              tooltip: _isGrid ? 'Show list' : 'Show grid',
              icon: Icon(_isGrid ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => _isGrid = !_isGrid),
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Icon(Icons.swipe_left, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Swipe left to delete · Pull down to refresh',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: _items.isEmpty
                        ? _buildEmpty()
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isGrid ? _buildGrid() : _buildList(),
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
