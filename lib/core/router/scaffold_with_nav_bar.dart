import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active.
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        destinations: const [
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.guitar),
            label: '나의 밴드',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.message),
            label: '채팅',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.calendar),
            label: '캘린더',
          ),
          NavigationDestination(
            icon: FaIcon(FontAwesomeIcons.user),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}
