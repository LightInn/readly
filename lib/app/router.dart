import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/groceries/groceries_page.dart';
import '../features/kitchen/kitchen_page.dart';
import '../features/meals/meals_page.dart';
import '../features/reader/reader_page.dart';
import '../features/reader/summary_page.dart';
import '../features/settings/settings_page.dart';
import '../features/track/track_page.dart';
import '../widgets/scanner_page.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/track',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/track',
                builder: (context, state) => const TrackPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/kitchen',
                builder: (context, state) => const KitchenPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/meals',
                builder: (context, state) => const MealsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/groceries',
                builder: (context, state) => const GroceriesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/read',
                builder: (context, state) => const ReaderPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/read/summary',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => SummaryPage(
          url: state.uri.queryParameters['url'] ?? '',
          savedArticleId: int.tryParse(
            state.uri.queryParameters['articleId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/scan',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const ScannerPage(),
      ),
    ],
  );
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.donut_large_outlined),
            selectedIcon: Icon(Icons.donut_large),
            label: 'Track',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Kitchen',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_basket_outlined),
            selectedIcon: Icon(Icons.shopping_basket),
            label: 'Groceries',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories),
            label: 'Read',
          ),
        ],
      ),
    );
  }
}
