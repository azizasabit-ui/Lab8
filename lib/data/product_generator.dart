import 'dart:math';

import 'package:flutter/material.dart';

import '../models/product.dart';
import 'products_data.dart';

class _Template {
  final GarmentType garment;
  final ProductCategory category;
  final String label;
  final List<String> sizes;
  const _Template(this.garment, this.category, this.label, this.sizes);
}

class _Swatch {
  final Color color;
  final String name;
  const _Swatch(this.color, this.name);
}

const _cloth = ['S', 'M', 'L', 'XL'];
const _pants = ['28', '30', '32', '34', '36'];
const _shoe = ['39', '40', '41', '42', '43', '44', '45'];
const _one = ['One size'];

const _templates = <_Template>[
  _Template(GarmentType.tee, ProductCategory.top, 'T-Shirt', _cloth),
  _Template(GarmentType.hoodie, ProductCategory.top, 'Hoodie', _cloth),
  _Template(GarmentType.sweater, ProductCategory.top, 'Sweater', _cloth),
  _Template(GarmentType.jacket, ProductCategory.top, 'Bomber', _cloth),
  _Template(GarmentType.jeans, ProductCategory.bottom, 'Jeans', _pants),
  _Template(GarmentType.chinos, ProductCategory.bottom, 'Chinos', _pants),
  _Template(GarmentType.cargo, ProductCategory.bottom, 'Cargo Pants', _pants),
  _Template(GarmentType.sneaker, ProductCategory.shoes, 'Sneakers', _shoe),
  _Template(GarmentType.runner, ProductCategory.shoes, 'Runners', _shoe),
  _Template(GarmentType.boot, ProductCategory.shoes, 'Boots', _shoe),
  _Template(GarmentType.watch, ProductCategory.accessory, 'Watch', _one),
  _Template(GarmentType.backpack, ProductCategory.accessory, 'Backpack', _one),
];

const _swatches = <_Swatch>[
  _Swatch(Color(0xFF00897B), 'Teal'),
  _Swatch(Color(0xFF8E24AA), 'Purple'),
  _Swatch(Color(0xFFEF6C00), 'Orange'),
  _Swatch(Color(0xFF1E88E5), 'Blue'),
  _Swatch(Color(0xFFD81B60), 'Pink'),
  _Swatch(Color(0xFF455A64), 'Slate'),
  _Swatch(Color(0xFF2E7D32), 'Green'),
  _Swatch(Color(0xFF212121), 'Black'),
  _Swatch(Color(0xFFF2EFE6), 'Ivory'),
];

final Random _random = Random();
int _counter = 0;

/// Items created by pull-to-refresh (kept so Favorites can still find them).
final List<Product> generatedProducts = [];

List<Product> get allKnownProducts => [...generatedProducts, ...kProducts];

/// Simulates "new item arrived from the server".
Product generateProduct() {
  _counter++;
  final t = _templates[_random.nextInt(_templates.length)];
  final s = _swatches[_random.nextInt(_swatches.length)];
  final product = Product(
    id: 'gen_$_counter',
    name: '${s.name} ${t.label}',
    brand: 'Threadly Drop',
    description:
        'Fresh from the latest drop. Limited stock, premium fabric and a '
        'modern fit.',
    price: (19 + _random.nextInt(140)) + 0.99,
    rating: 3.5 + _random.nextInt(16) / 10,
    reviews: 5 + _random.nextInt(300),
    category: t.category,
    garment: t.garment,
    tags: const ['New', 'Limited'],
    sizes: t.sizes,
    color: s.color,
    colorName: s.name,
  );
  generatedProducts.add(product);
  return product;
}
