# THREADLY 👗 — Clothing Store with a Virtual Try-On Mannequin
(Flutter capstone, Milestone 1)

**Problem:** online clothes shopping is guesswork — you buy single items and
hope they match. **User:** students and young people who want to see an outfit
before they buy it.

## ⭐ Unique feature: Virtual Try-On (Outfit Builder)
- A mannequin **wears the real products**: hoodie, tee, sweater, bomber, jeans,
  chinos, cargo pants, sneakers, boots, runners, watch and backpack. Each item is
  drawn with its own shape and details (pockets, zippers, laces, stitching).
- Pick a top, bottom, shoes and accessory — garments fade in on the body.
- **Style Score (0-100)** from color theory (`lib/utils/style_scorer.dart`) + text tip.
- **Shuffle** 🎲, **Save look** / **My looks**, **Add whole look to cart**.
- "Try it on the mannequin" button on every product page.

## Catalog
24 products in 4 categories (Tops, Bottoms, Shoes, Accessories) with filters,
favorites, ratings, sizes, quantity and cart.

### Using real photos
Every product accepts an optional `imageUrl` (see `lib/models/product.dart`):
```dart
Product(..., imageUrl: 'https://your-site.com/photos/hoodie.jpg')
```
If the URL is missing or fails to load, the vector illustration is shown.
(For local files, replace `Image.network` with `Image.asset` in `widgets/product_image.dart`.)

## LAB 7 - Navigation & Tabs
- `RootScreen` with **BottomNavigationBar**: Feed / Favorites (badge) / Profile; `IndexedStack` keeps state.
- **Navigator.push with arguments:** `pushNamed('/detail', arguments: product)` → `onGenerateRoute` builds `ProductDetailScreen` with the full `Product`.
- **Navigator.pop:** AppBar back icon + in-body "Back to shopping" button.

## LW8 - Dynamic Lists, Grids & Touch Interactions (Catalog tab)
`lib/screens/catalog_screen.dart` (+ `widgets/product_list_tile.dart`, `dismiss_background.dart`, `empty_catalog.dart`, `data/product_generator.dart`)
- **List Feed:** `ListView.separated` with thin `Divider` separators; row = avatar, title, category tag, rating, price.
- **Grid Catalog:** `GridView.builder`, 2 columns, `childAspectRatio: 0.72` (no overflow).
- **Toggle:** AppBar button switches List <-> Grid (same data list, fade transition).
- **Pull-to-refresh:** `RefreshIndicator` -> `await Future.delayed(1500 ms)` -> new product inserted at index 0 -> `setState`.
- **Swipe-to-delete:** `Dismissible(key: ValueKey(product.id))`, right-to-left, red background with `Icons.delete`.
- **UNDO:** floating `SnackBar` + `SnackBarAction('UNDO')` re-inserts the item at its original index.
- **Empty state:** icon + "Catalog is Empty" + **Reset Catalog** button restores seed data.

### Defense cheat-sheet (likely questions)
- *Why ListView.builder/separated instead of Column?* Column builds ALL children at once (eager); with thousands of items it wastes RAM and freezes the UI. The builder creates only visible rows (lazy) and recycles them.
- *What does childAspectRatio 0.72 mean?* width / height of each cell, so the cell is taller than wide (height = width / 0.72). The card content must fit that box, otherwise RenderFlex overflow.
- *Why ValueKey in Dismissible?* Flutter must know WHICH widget was removed; a stable unique key (the product id) ties the widget to its data. Without it, Dismissible throws "still part of the tree" errors or removes the wrong row.
- *Why remove the item inside onDismissed?* The dismissed widget is already gone from the screen; the data list must be updated in the same frame, otherwise the tree and data disagree.
- *Why must onRefresh return a Future?* RefreshIndicator shows the spinner until that Future completes.
- *How does UNDO restore the position?* We save `index` and the removed object, then `insert(index, removed)` inside `setState`.

## LAB 5 / LAB 6
- Detail screen: `Stack` cover + bookmark badge, `Row`/`Wrap`, sticky bottom bar, full-width **Add to Cart** (`Expanded`), no RenderFlex overflow.
- Registration: `Form`, `GlobalKey<FormState>`, validators, Terms checkbox, role dropdown, SnackBar + AlertDialog.

## Folder structure
```
lib/
├── main.dart
├── models/product.dart
├── data/products_data.dart
├── state/app_state.dart
├── utils/style_scorer.dart
├── screens/  root / feed / catalog / favorites / profile / product_detail / cart / outfit_builder / register
└── widgets/  product_card / product_image / garment_painter / mannequin / category_badge / rating_stars / bottom_action_bar
```

## Run
```bash
flutter create .
flutter pub get
flutter run              # phone / emulator
flutter run -d chrome    # as a website
flutter test
```

## Roadmap
REST API (catalog) → Database (saved looks) → BLoC (replace `AppState`).
