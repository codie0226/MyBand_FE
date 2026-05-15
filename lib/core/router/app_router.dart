import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'scaffold_with_nav_bar.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/onboarding/views/onboarding_screen.dart';
import '../../features/profile/providers/user_provider.dart';
import '../../features/my_band/views/my_band_screen.dart';
import '../../features/my_band/views/add_event_screen.dart';
import '../../features/my_band/views/create_band_screen.dart';
import '../../features/my_band/views/join_band_screen.dart';
import '../../features/my_band/views/manage_band_members_screen.dart';
import '../../features/my_band/models/band_models.dart';
import '../../features/chat/views/chat_screen.dart';
import '../../features/chat/views/chat_room_list_screen.dart';
import '../../features/calendar/views/calendar_screen.dart';
import '../../features/profile/views/profile_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _sectionANavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'sectionANav',
);
final _sectionBNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'sectionBNav',
);
final _sectionCNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'sectionCNav',
);
final _sectionDNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'sectionDNav',
);

/// authProvider 상태 변화를 GoRouter에 전달하는 ChangeNotifier
class _RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  _RouterNotifier(this._ref) {
    _ref.listen<bool>(authProvider, (_, next) {
      if (next) {
        _ref.invalidate(userProfileProvider);
        _ref.read(userProfileProvider.future).ignore();
      }
      notifyListeners();
    });
    _ref.listen(userProfileProvider, (_, _) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final isLoggedIn = _ref.read(authProvider);
    final isOnLogin = state.matchedLocation == '/login';
    final isOnOnboarding = state.matchedLocation == '/onboarding';

    if (!isLoggedIn && !isOnLogin) return '/login';
    if (!isLoggedIn) return null;

    final profile = _ref.read(userProfileProvider).value;
    if (profile?.onboardingCompleted == false && !isOnOnboarding) {
      return '/onboarding';
    }
    if (profile?.onboardingCompleted == true && isOnOnboarding) {
      return '/my_band';
    }
    if (isOnLogin) {
      return profile?.onboardingCompleted == false ? '/onboarding' : '/my_band';
    }
    return null;
  }
}

final _routerNotifierProvider = Provider<_RouterNotifier>((ref) {
  return _RouterNotifier(ref);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/my_band',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/add_event',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final dateParam = state.uri.queryParameters['date'];
          final preselectedDate = dateParam != null
              ? DateTime.tryParse(dateParam)
              : null;
          return AddEventScreen(preselectedDate: preselectedDate);
        },
      ),
      GoRoute(
        path: '/create_band',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateBandScreen(),
      ),
      GoRoute(
        path: '/edit_band',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => CreateBandScreen(
          band: state.extra is Band ? state.extra as Band : null,
        ),
      ),
      GoRoute(
        path: '/join_band',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const JoinBandScreen(),
      ),
      GoRoute(
        path: '/manage_band_members',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ManageBandMembersScreen(
          band: state.extra is Band ? state.extra as Band : null,
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _sectionANavigatorKey,
            routes: [
              GoRoute(
                path: '/my_band',
                builder: (context, state) => const MyBandScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionBNavigatorKey,
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatRoomListScreen(),
                routes: [
                  GoRoute(
                    path: ':bandId',
                    builder: (context, state) {
                      final bandId = state.pathParameters['bandId']!;
                      final band = state.extra is Band
                          ? state.extra as Band
                          : null;

                      return ChatScreen(
                        bandId: bandId,
                        bandName: band?.name ?? '채팅방',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionCNavigatorKey,
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _sectionDNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
