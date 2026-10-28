import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/product_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  Widget _qtyButton(IconData icon, VoidCallback onTap) => IconButton(
        icon: Icon(icon, size: 22),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        onPressed: onTap,
      );

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final items = appState.cart;
        return Scaffold(
          appBar: AppBar(title: const Text('My cart')),
          body: items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shopping_bag_outlined,
                          size: 72, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Your cart is empty'),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: items.length,
                            itemBuilder: (_, i) {
                              final it = items[i];
                              final p = it.product;
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: ProductImage(product: p, padding: 4),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(p.name,
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                '${it.size} · \$${p.price.toStringAsFixed(2)}',
                                                maxLines: 1,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors
                                                        .grey.shade600)),
                                          ],
                                        ),
                                      ),
                                      _qtyButton(Icons.remove_circle_outline,
                                          () => appState.changeQty(it, -1)),
                                      Text('${it.qty}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      _qtyButton(Icons.add_circle_outline,
                                          () => appState.changeQty(it, 1)),
                                      _qtyButton(Icons.delete_outline,
                                          () => appState.removeFromCart(it)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Material(
                          elevation: 12,
                          color: Colors.white,
                          child: SafeArea(
                            top: false,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Text(
                                      '\$${appState.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                          minimumSize:
                                              const Size.fromHeight(52)),
                                      onPressed: () {
                                        appState.clearCart();
                                        showDialog<void>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            icon: const Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: 48),
                                            title:
                                                const Text('Order placed!'),
                                            content: const Text(
                                                'Thank you for shopping at THREADLY.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                      child: const Text('Checkout'),
                                    ),
                                  ),
                                ],
                              ),
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
