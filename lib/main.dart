import 'package:flutter/material.dart';

import 'models/product.dart';
import 'screens/product_detail_screen.dart';
import 'screens/root_screen.dart';

void main() => runApp(const ThreadlyApp());

class ThreadlyApp extends StatelessWidget {
  const ThreadlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'THREADLY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6C5CE7)),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F7FB),
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const RootScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/detail' && settings.arguments is Product) {
          final product = settings.arguments as Product;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => ProductDetailScreen(product: product),
          );
        }
        return null;
      },
    );
  }
}
