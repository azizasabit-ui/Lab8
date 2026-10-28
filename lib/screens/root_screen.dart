import 'package:flutter/material.dart';

import '../state/app_state.dart';
import 'catalog_screen.dart';
import 'favorites_screen.dart';
import 'feed_screen.dart';
import 'profile_screen.dart';

/// LAB 7: root screen with BottomNavigationBar (Feed / Favorites / Profile).
/// IndexedStack keeps every tab alive, so switching tabs or coming back from
/// the detail screen never resets scroll position or state.
class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _index = 0;

  static const _pages = <Widget>[
    FeedScreen(),
    CatalogScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: ListenableBuilder(
        listenable: appState,
        builder: (context, _) => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          selectedItemColor: Theme.of(context).colorScheme.primary,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Feed',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.view_list_outlined),
              activeIcon: Icon(Icons.view_list),
              label: 'Catalog',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: appState.favoritesCount > 0,
                label: Text('${appState.favoritesCount}'),
                child: const Icon(Icons.favorite_border),
              ),
              activeIcon: Badge(
                isLabelVisible: appState.favoritesCount > 0,
                label: Text('${appState.favoritesCount}'),
                child: const Icon(Icons.favorite),
              ),
              label: 'Favorites',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
