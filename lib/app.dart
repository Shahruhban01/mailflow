import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';          // ← add
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/history/screens/email_detail_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuth = authState is AuthSuccess;
      final onAuth = ['/login', '/register', '/forgot-password']
          .contains(state.matchedLocation);
      if (isAuth && onAuth)  return '/dashboard';
      if (!isAuth && !onAuth) return '/login';
      return null;
    },
    routes: [
      GoRoute(path: '/login',           builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register',        builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/dashboard',       builder: (_, __) => const DashboardScreen()),
      GoRoute(
        path: '/email/:id',
        builder: (_, state) => EmailDetailScreen(
          emailId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
});

class MailFlowApp extends ConsumerWidget {
  const MailFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router    = ref.watch(_routerProvider);
    final themeMode = ref.watch(themeProvider);          // ← watch theme

    return MaterialApp.router(
      title: 'MailFlow',
      debugShowCheckedModeBanner: false,
      theme:      AppTheme.light,
      darkTheme:  AppTheme.dark,
      themeMode:  switch (themeMode) {                   // ← controlled
        AppThemeMode.light  => ThemeMode.light,
        AppThemeMode.dark   => ThemeMode.dark,
        AppThemeMode.system => ThemeMode.system,
      },
      routerConfig: router,
    );
  }
}
