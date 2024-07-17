import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:frontend/mobile/views/auth/login_page.dart';
import 'package:frontend/mobile/views/auth/signup_page.dart';
import 'package:frontend/mobile/views/back/admin_page.dart';
import 'package:frontend/mobile/views/back/admin_settings_page.dart';
import 'package:frontend/mobile/views/back/hike_management.dart';
import 'package:frontend/mobile/views/back/hikes_page.dart';
import 'package:frontend/mobile/views/back/user_management.dart';
import 'package:frontend/mobile/views/back/users_page.dart';
import 'package:frontend/mobile/views/create-hike/create_hike_page.dart';
import 'package:frontend/mobile/views/explore/explore_page.dart';
import 'package:frontend/mobile/views/explore/hike_details_page.dart';
import 'package:frontend/mobile/views/explore/hike_reviews_page.dart';
import 'package:frontend/mobile/views/group-chat/group-chat.dart';
import 'package:frontend/mobile/views/group-detail/group_detail_page.dart';
import 'package:frontend/mobile/views/groups/createGroup_page.dart';
import 'package:frontend/mobile/views/groups/groups_page.dart';
import 'package:frontend/mobile/views/profile/profile_details_page.dart';
import 'package:frontend/shared/providers/group_provider.dart';
import 'package:frontend/mobile/views/home_page.dart';
import 'package:frontend/mobile/views/intro_screen.dart';
import 'package:frontend/mobile/views/profile/profile_page.dart';
import 'package:frontend/mobile/views/profile/user_hikes_history.dart';
import 'package:frontend/mobile/widgets/footer.dart';
import 'package:frontend/shared/providers/admin_provider.dart';
import 'package:frontend/shared/providers/group_provider.dart';
import 'package:frontend/shared/providers/hike_provider.dart';
import 'package:frontend/shared/providers/settings_provider.dart';
import 'package:frontend/shared/providers/user_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/shared/widgets/notification_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/shared/services/firebase_service.dart';

Future<void> main() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseService().initNotifications();
  final token = await FirebaseMessaging.instance.getToken();

  prefs.setString('fcmToken', token!);
  if (prefs.containsKey('fcmToken')) {
    print('FCM Token: ${prefs.getString('fcmToken')}');
  }

  // setupFirebaseMessagingHandlers();

  runApp(const MyMobileApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: navigatorKey,
  redirect: (context, state) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isLoggedIn = userProvider.user != null;
    if (!isLoggedIn &&
        state.uri.path != '/login' &&
        state.uri.path != '/signup') {
      //print(1);
      return '/login';
    }
    if (isLoggedIn &&
        (state.uri.path == '/login' || state.uri.path == '/signup')) {
      //print(2);
      return '/home';
    }
    return null;
  },
  routes: <RouteBase>[
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
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
          routes: [
            GoRoute(
              name: "profileDetails",
              path: 'details',
              builder: (context, state) => const ProfileDetailsPage(),
            ),
            GoRoute(
              name: "hike-history",
              path: 'hike-history',
              builder: (context, state) => const UserHikeHistory(),
            )
          ],
        ),
        GoRoute(
          name: "notifications",
          path: '/user-notifications',
          builder: (context, state) => const NotificationPage(),
        ),
        GoRoute(
          name: "explore",
          path: '/explore',
          builder: (context, state) => const ExplorePage(),
        ),
        GoRoute(
          name: "hikeDetails",
          path: '/hike/:id',
          builder: (context, state) {
            final hikeId = int.parse(state.pathParameters['id']!);
            final hikeProvider =
                Provider.of<HikeProvider>(context, listen: false);
            final hike =
                hikeProvider.hikes.firstWhere((hike) => hike.id == hikeId);
            return HikeDetailsExplorePage(hike: hike);
          },
        ),
        GoRoute(
          name: "hikeReviews",
          path: '/hike/:id/reviews',
          builder: (context, state) {
            final hikeId = int.parse(state.pathParameters['id']!);
            return HikeReviewsPage(hikeId: hikeId);
          },
        ),
        GoRoute(
          name: "create-hike",
          path: '/create-hike',
          builder: (context, state) => const CreateHikePage(),
        ),
        GoRoute(
          name: "test",
          path: '/test',
          builder: (context, state) => Scaffold(
            appBar: AppBar(
              title: const Text('Test'),
            ),
            body: const Center(
              child: Text('Test'),
            ),
          ),
        ),
        GoRoute(
          name: "group-detail",
          path: '/group/:id',
          builder: (context, state) {
            final groupId = int.parse(state.pathParameters['id']!);
            return GroupDetailPage(groupId: groupId);
          },
        ),
        GoRoute(
          name: "group-chat",
          path: '/group-chat/:id',
          builder: (context, state) {
            final groupId = int.parse(state.pathParameters['id']!);
            return GroupChatPage(groupId: groupId);
          },
        ),
        GoRoute(
          name: "groups",
          path: '/groups',
          builder: (context, state) => const GroupsPage(),
          routes: [
            GoRoute(
              name: "create-group",
              path: 'create/:hikeId',
              builder: (context, state) {
                final hikeId = int.parse(state.pathParameters['hikeId']!);
                final hikeProvider =
                    Provider.of<HikeProvider>(context, listen: false);
                final hike =
                    hikeProvider.hikes.firstWhere((hike) => hike.id == hikeId);
                return CreateGroupPage(hike: hike);
              },
            ),
          ],
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
            GoRoute(
              name: "admin-settings",
              path: 'settings',
              builder: (context, state) => const AdminSettingsPage(),
            ),
            GoRoute(
              name: "admin-user-management",
              path: 'user/management/:userId',
              builder: (context, state) {
                final userId = int.parse(state.pathParameters['userId']!);
                final adminProvider =
                    Provider.of<AdminProvider>(context, listen: false);
                final user = adminProvider.users.firstWhere((user) {
                  return user.id == userId;
                });
                return UserManagement(user: user);
              },
            ),
            GoRoute(
              name: "admin-hike-management",
              path: 'hike/management/:hikeId',
              builder: (context, state) {
                final hikeId = int.parse(state.pathParameters['hikeId']!);
                final adminProvider =
                    Provider.of<AdminProvider>(context, listen: false);
                final hike = adminProvider.hikes.firstWhere((hike) {
                  return hike.id == hikeId;
                });
                return HikeManagement(hike: hike);
              },
            ),
          ],
        ),
      ],
    ),
  ],
);

class MyMobileApp extends StatelessWidget {
  final RemoteMessage? initialMessage;

  const MyMobileApp({super.key, this.initialMessage});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
        ChangeNotifierProvider(create: (_) => HikeProvider()),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp.router(
            routerConfig: _router,
            theme: ThemeData(
              brightness: Brightness.dark,
            ),
            builder: (context, child) {
              // Navigate based on initial message if exists
              if (initialMessage != null &&
                  initialMessage!.data['route'] != null) {
                Future.microtask(() => Navigator.pushNamed(
                      context,
                      initialMessage!.data['route'],
                    ));
              }
              return child!;
            },
          );
        },
      ),
    );
  }
}
