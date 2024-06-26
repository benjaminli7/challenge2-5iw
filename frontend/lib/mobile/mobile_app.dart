import 'package:flutter/material.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/mobile/views/auth/login_page.dart';
import 'package:frontend/mobile/views/auth/signup_page.dart';
import 'package:frontend/mobile/views/home_page.dart';
import 'package:frontend/mobile/views/back/users_page.dart';
import 'package:frontend/mobile/views/back/admin_page.dart';
import 'package:frontend/mobile/views/profile/profile_page.dart';
import 'package:frontend/mobile/views/explore/explore_page.dart';
import 'package:frontend/mobile/views/groups/groups_page.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/mobile/widgets/footer.dart';

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
          path: '/home',
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
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
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/explore',
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          path: '/groups',
          builder: (context, state) => const GroupsPage(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminPage(),
          routes: [
            GoRoute(
              path: 'users',
              builder: (context, state) => const UserListPage(),
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
