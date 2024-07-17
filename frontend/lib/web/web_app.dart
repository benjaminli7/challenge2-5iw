import 'package:flutter/material.dart';
import 'package:frontend/web/views/validation_page.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/web/views/login_page.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/providers/settings_provider.dart';
import 'package:frontend/web/views/home_page.dart';
import 'package:frontend/web/widgets/footer.dart';
import 'package:frontend/web/views/users_page.dart';
import 'package:frontend/web/views/params_page.dart';
import 'package:frontend/web/views/groups_page.dart';
import 'package:frontend/web/views/hikes_page.dart';
import 'package:frontend/web/views/hike_details_page.dart';
import 'package:frontend/shared/models/hike.dart';
import 'package:frontend/web/views/group_details_page.dart';
import 'package:frontend/web/views/user_details_page.dart';

void main() {
  runApp(const MyWebApp());
}

bool _isValidateTokenPath(String path) {
  final validateTokenPattern = RegExp(r'^/validate/[^/]+$');
  return validateTokenPattern.hasMatch(path);
}

final GoRouter _router = GoRouter(
  redirect: (context, state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.user != null;
    print(state.uri.path);
    print(isLoggedIn);

    if (!isLoggedIn && state.uri.path != '/login' && !_isValidateTokenPath(state.uri.path)) {
      print(1);
      return '/login';
    }

    // If the user is logged in and trying to access the login/signup page, redirect to the home page
    else if (isLoggedIn && (state.uri.path == '/login') && state.uri.path !='/validate/:token'){
      print(2);
      return '/home';
    }

    return null;
  },
  routes: <RouteBase>[
    // Routes without a footer

    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),


      GoRoute(
        path: '/validate/:token',
        builder: (context, state) {
          final token = state.pathParameters['token']!;
          return ValidatePage(token: token);
        }


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
          path: '/groups',
          builder: (context, state) => const GroupsPage(),
        ),
        GoRoute(
          path: '/hikes',
          builder: (context, state) => const HikesPage(),
        ),
        GoRoute(
            path: '/params', builder: (context, state) => const ParamsPage()),
        GoRoute(
            path: '/users', builder: (context, state) => const UserListPage()),
        GoRoute(
          name: "hikeDetails",
          path: '/hike/:id',
          builder: (context, state) {
            final hikeId = int.parse(state.pathParameters['id']!);
            final hike = Provider.of<HikeProvider>(context, listen: false)
                .hikes
                .firstWhere((hike) => hike.id == hikeId);
            return HikeDetailsPage(hike: hike);
          },
        ),
        GoRoute(
          name: "userDetails",
          path: '/user/:id',
          builder: (context, state) {
            final userId = int.parse(state.pathParameters['id']!);
            final user = Provider.of<AdminProvider>(context, listen: false)
                .users
                .firstWhere((user) => user.id == userId);
            return UsersDetailsPage(user: user);
          },
        ),
        GoRoute(
          name: "groupDetails",
          path: '/group/:id',
          builder: (context, state) {
            final groupId = int.parse(state.pathParameters['id']!);
            final group = Provider.of<AdminProvider>(context, listen: false)
                .groups
                .firstWhere((group) => group.id == groupId);
            return GroupDetailsPage(group: group);

          },
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
      ],
    ),

  ],
);

class MyWebApp extends StatelessWidget {
  const MyWebApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => HikeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
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

class WebHomePage extends StatelessWidget {
  const WebHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Home'),
      ),
      body: const Center(
        child: Text('Welcome to the Web Dashboard!'),
      ),
    );
  }
}
