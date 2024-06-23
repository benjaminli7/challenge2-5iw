import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/web/views/login_page.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/web/views/home_page.dart';
import 'package:frontend/web/widgets/footer.dart';
import 'package:frontend/web/views/admin_page.dart';
import 'package:frontend/web/views/users_page.dart';
import 'package:frontend/web/views/params_page.dart';
import 'package:frontend/web/views/groups_page.dart';
import 'package:frontend/web/views/hikes_page.dart';
void main() {
  runApp(MyWebApp());
}
final GoRouter _router = GoRouter(
  redirect: (context, state) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.user != null;
    print(state.uri.path);
    print(isLoggedIn);
    // If the user is not logged in and trying to access a protected route, redirect to the login page
    if (!isLoggedIn &&
        state.uri.path != '/login') {
      print(1);
      return '/login';
    }
    // If the user is logged in and trying to access the login/signup page, redirect to the home page
    if (isLoggedIn &&
        (state.uri.path == '/login')) {
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
            path: '/params',
            builder: (context, state) => const ParamsPage()
        ),
        GoRoute(
            path: '/users',
            builder: (context, state) => const UserListPage()
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
    // Default route, redirects to login or home based on user state
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web Home'),
      ),
      body: Center(
        child: Text('Welcome to the Web Dashboard!'),
      ),
    );
  }
}
