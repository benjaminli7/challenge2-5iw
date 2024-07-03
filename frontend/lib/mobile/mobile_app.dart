import 'package:flutter/material.dart';
import 'package:frontend/mobile/views/auth/login_page.dart';
import 'package:frontend/mobile/views/auth/signup_page.dart';
import 'package:frontend/mobile/views/back/admin_page.dart';
import 'package:frontend/mobile/views/back/users_page.dart';
import 'package:frontend/mobile/views/back/hikes_page.dart';
import 'package:frontend/mobile/views/create-hike/create_hike_page.dart';
import 'package:frontend/mobile/views/explore/explore_page.dart';
import 'package:frontend/mobile/views/explore/hike_details_page.dart'
    as hikeDetailsExp;
import 'package:frontend/mobile/views/groups/groups_page.dart';
import 'package:frontend/shared/providers/group_provider.dart';
import 'package:frontend/mobile/views/home_page.dart';
import 'package:frontend/mobile/views/profile/profile_page.dart';
import 'package:frontend/mobile/widgets/footer.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyMobileApp());
}

final GoRouter _router = GoRouter(
  redirect: (context, state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.user != null;
    print(state.uri.path);
    print(isLoggedIn);
    // If the user is not logged in and trying to access a protected route, redirect to the login page
    if (!isLoggedIn &&
        state.uri.path != '/login' &&
        state.uri.path != '/signup') {
      print(1);
      return '/login';
    }
    // If the user is logged in and trying to access the login/signup page, redirect to the home page
    if (isLoggedIn &&
        (state.uri.path == '/login' || state.uri.path == '/signup')) {
      print(2);
      return '/home';
    }
    return null;
  },
  routes: <RouteBase>[
    // Routes without a footer
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    // ShellRoute with a footer
    ShellRoute(
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: const Footer(),
        );
      },
      routes: [
        GoRoute(
          name: "home",
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: "root",
          path: '/',
          builder: (context, state) {
            final userProvider = Provider.of<UserProvider>(context);
            if (userProvider.user == null) {
              return const LoginPage();
            } else {
              return const HomePage();
            }
          },
        ),
        GoRoute(
          name: "profile",
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          name: "explore",
          path: '/explore',
          builder: (context, state) => const ExplorePage(),
          // routes: [
          //   GoRoute(
          //     name: "hike details",
          //     path: 'hikes/:id',
          //     builder: (context, state) {
          //       final hikeId = state.pathParameters['id'];
          //       final hikeProvider =
          //           Provider.of<HikeProvider>(context, listen: false);

          //       print('hikeId: $hikeId');
          //       final hike =
          //           hikeProvider.hikes.firstWhere((hike) => hike.id == hikeId);
          //       return HikeDetailsPage(hike: hike);
          //     },
          //   ),
          // ],
        ),
        GoRoute(
          name: "create-hike",
          path: '/create-hike',
          builder: (context, state) => const CreateHikePage(),
        ),
        GoRoute(
          name: "groups",
          path: '/groups',
          builder: (context, state) => const GroupsPage(),
        ),
        GoRoute(
          name: "admin",
          path: '/admin',
          builder: (context, state) => const AdminPage(),
          routes: [
            GoRoute(
              name: "users",
              path: 'users',
              builder: (context, state) => const UserListPage(),
            ),
            GoRoute(
              name: "hikes",
              path: 'hikes',
              builder: (context, state) => const HikeListPage(),
            ),
          ],
        ),
      ],
    ),
    // Default route, redirects to login or home based on user state
  ],
);

class MyMobileApp extends StatelessWidget {
  const MyMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => HikeProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
      ],
      child: MaterialApp.router(
        routerConfig: _router,
        theme: ThemeData(
          // Dark theme
          brightness: Brightness.dark,
        ),
      ),
    );
  }
}
