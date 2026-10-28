import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threadly/data/products_data.dart';
import 'package:threadly/main.dart';
import 'package:threadly/models/product.dart';
import 'package:threadly/screens/catalog_screen.dart';
import 'package:threadly/utils/style_scorer.dart';
import 'package:threadly/widgets/mannequin.dart';
import 'package:threadly/widgets/product_image.dart';

Product _p(String id) => kProducts.firstWhere((p) => p.id == id);

void main() {
  testWidgets('Root screen shows feed and bottom navigation', (tester) async {
    await tester.pumpWidget(const ThreadlyApp());
    expect(find.text('THREADLY'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites (0)'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Guest Shopper'), findsOneWidget);
  });


  testWidgets('catalog: toggle list/grid, swipe to delete and UNDO',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogScreen()));
    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Smart Catalog (24)'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();
    expect(find.byType(GridView), findsOneWidget);

    await tester.tap(find.byIcon(Icons.view_list));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Dismissible).first, const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('Smart Catalog (23)'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(find.text('Smart Catalog (24)'), findsOneWidget);
    expect(find.text('Oversize Black Hoodie'), findsOneWidget);
  });

  testWidgets('catalog: pull-to-refresh prepends a new item', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CatalogScreen()));
    await tester.fling(find.byType(ListView), const Offset(0, 400), 1000);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Smart Catalog (25)'), findsOneWidget);
  });

  testWidgets('every garment illustration paints without errors',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Wrap(
          children: [
            for (final p in kProducts)
              SizedBox(width: 60, height: 60, child: ProductImage(product: p)),
          ],
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
  });

  testWidgets('mannequin renders a full outfit', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 200,
          height: 360,
          child: Mannequin(
            top: _p('t1'),
            bottom: _p('b1'),
            shoes: _p('s2'),
            accessory: _p('a2'),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  test('empty outfit scores zero', () {
    final r = StyleScorer.evaluate({for (final c in ProductCategory.values) c: null});
    expect(r.score, 0);
  });

  test('neutral outfit scores higher than clashing outfit', () {
    final neutral = StyleScorer.evaluate({
      ProductCategory.top: _p('t1'),
      ProductCategory.bottom: _p('b2'),
      ProductCategory.shoes: _p('s1'),
      ProductCategory.accessory: null,
    });
    final clash = StyleScorer.evaluate({
      ProductCategory.top: _p('t4'),
      ProductCategory.bottom: _p('b3'),
      ProductCategory.shoes: _p('s3'),
      ProductCategory.accessory: null,
    });
    expect(neutral.score, greaterThan(clash.score));
  });
}
