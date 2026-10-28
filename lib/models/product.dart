import 'package:flutter/material.dart';

enum ProductCategory { top, bottom, shoes, accessory }

extension ProductCategoryX on ProductCategory {
  String get label => switch (this) {
        ProductCategory.top => 'Tops',
        ProductCategory.bottom => 'Bottoms',
        ProductCategory.shoes => 'Shoes',
        ProductCategory.accessory => 'Accessories',
      };

  IconData get icon => switch (this) {
        ProductCategory.top => Icons.checkroom,
        ProductCategory.bottom => Icons.dry_cleaning,
        ProductCategory.shoes => Icons.hiking,
        ProductCategory.accessory => Icons.watch,
      };
}

enum GarmentType {
  tee,
  hoodie,
  sweater,
  jacket,
  jeans,
  chinos,
  cargo,
  sneaker,
  runner,
  boot,
  watch,
  backpack,
}

extension GarmentTypeX on GarmentType {
  double get aspect => switch (this) {
        GarmentType.tee ||
        GarmentType.hoodie ||
        GarmentType.sweater ||
        GarmentType.jacket =>
          1.07,
        GarmentType.jeans || GarmentType.chinos || GarmentType.cargo => 0.55,
        GarmentType.sneaker || GarmentType.runner => 2.2,
        GarmentType.boot => 1.55,
        GarmentType.watch => 0.6,
        GarmentType.backpack => 0.85,
      };
}

class Product {
  final String id;
  final String name;
  final String brand;
  final String description;
  final double price;
  final double rating;
  final int reviews;
  final ProductCategory category;
  final GarmentType garment;
  final List<String> tags;
  final List<String> sizes;
  final Color color;
  final String colorName;

  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.description,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.category,
    required this.garment,
    required this.tags,
    required this.sizes,
    required this.color,
    required this.colorName,
    this.imageUrl,
  });

  String get defaultSize => sizes[(sizes.length - 1) ~/ 2];
}
