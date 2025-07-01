import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:tetris/Features/Chat/ui/chat.dart';
import 'package:tetris/Features/Auth/Email/ui/email.dart';
import 'package:tetris/Features/Home/ui/home.dart';
import 'package:tetris/Features/Loading/ui/loading.dart';
import 'package:tetris/Features/Auth/Login/ui/login.dart';
import 'package:tetris/Features/Profile/ui/profile.dart';
import 'package:tetris/Features/Auth/Profile_Setup/ui/profile_setup.dart';
import 'package:tetris/Features/Auth/Register/ui/register.dart';
import 'package:tetris/Features/Search/ui/search.dart';

GoRouter router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => LoadingPage()),
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(
      path: '/register',
      pageBuilder:
          (context, state) =>
              customTransition(state, const RegisterPage(), 1.0),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) {
        return ProfilePage();
      },
    ),
    GoRoute(
      path: '/search',
      pageBuilder:
          (context, state) => customTransition(state, const SearchPage(), 1.0),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) {
        return HomePage();
      },
    ),
    GoRoute(
      path: '/chat',
      pageBuilder:
          (context, state) => customTransition(
            state,
            ChatPage(
              username: state.uri.queryParameters['username'],
              userImage: state.uri.queryParameters['userImage'],
              displayName: state.uri.queryParameters['displayName'],
            ),
            1.0,
          ),
    ),
    GoRoute(
      path: '/email',
      pageBuilder:
          (context, state) => customTransition(state, EmailPage(), 1.0),
    ),
    GoRoute(
      path: '/profileBioPage',
      pageBuilder:
          (context, state) => customTransition(state, ProfileBioPage(), 1.0),
    ),
  ],
);

CustomTransitionPage customTransition(
  GoRouterState state,
  Widget child,
  double direction,
) {
  return CustomTransitionPage(
    key: state.pageKey,

    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final begin = Offset(direction, 0);
      final end = Offset.zero;

      final tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
    transitionDuration: Duration(milliseconds: 500),
  );
}
