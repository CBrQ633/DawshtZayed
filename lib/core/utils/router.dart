import 'package:go_router/go_router.dart';
import 'package:dawsha_app/features/auth/presentation/pages/splash_screen.dart';
import 'package:dawsha_app/features/auth/presentation/pages/onboarding_screen.dart';
import 'package:dawsha_app/features/auth/presentation/pages/login_screen.dart';
import 'package:dawsha_app/features/auth/presentation/pages/signup_screen.dart';
import 'package:dawsha_app/features/home/presentation/pages/home_page.dart';
import 'package:dawsha_app/features/activities/presentation/pages/run_tracking_screen.dart';
import 'package:dawsha_app/features/activities/presentation/pages/activity_summary_screen.dart';
import 'package:dawsha_app/features/activities/presentation/pages/explore_map_screen.dart';
import 'package:dawsha_app/features/community/presentation/pages/community_screen.dart';
import 'package:dawsha_app/features/store/presentation/pages/store_screen.dart';
import 'package:dawsha_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:dawsha_app/features/profile/presentation/pages/settings_screen.dart';
import 'package:dawsha_app/data/models/activity_model.dart';
import 'package:dawsha_app/core/presentation/pages/main_layout.dart';
import 'package:dawsha_app/features/community/presentation/pages/create_post_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainLayout(navigationShell: navigationShell);
      },
      branches: [
        // Tab 0: Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        // Tab 1: Community
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              builder: (context, state) => const CommunityScreen(),
            ),
          ],
        ),
        // Tab 2: Map
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              builder: (context, state) => const ExploreMapScreen(),
            ),
          ],
        ),
        // Tab 3: Store
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/store',
              builder: (context, state) => const StoreScreen(),
            ),
          ],
        ),
        // Tab 4: Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/tracking',
      builder: (context, state) => const RunTrackingScreen(),
    ),
    GoRoute(
      path: '/summary',
      builder: (context, state) {
        final activity = state.extra as ActivityModel;
        return ActivitySummaryScreen(activity: activity);
      },
    ),
    GoRoute(
      path: '/create_post',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
