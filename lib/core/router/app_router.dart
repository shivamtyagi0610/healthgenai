import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/dashboard/presentation/screens/main_dashboard_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/ai_checker/presentation/screens/ai_symptom_checker_screen.dart';
import '../../features/prescription/presentation/screens/upload_prescription_screen.dart';
import '../../features/medicines/presentation/screens/medicines_screen.dart';
import '../../features/medicines/presentation/screens/medicine_details_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/sign-in',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthPath = state.uri.path == '/sign-in' || state.uri.path == '/sign-up';

      if (!isLoggedIn && !isAuthPath) {
        return '/sign-in';
      }
      if (isLoggedIn && isAuthPath) {
        return '/home';
      }
      return null;
    },
    refreshListenable: _RouterRefreshNotifier(ref),
    routes: [
      GoRoute(
        path: '/sign-in',
        name: 'signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        name: 'signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainDashboardScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home, AI Checker, Upload Rx & Medicines
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'ai-checker',
                    builder: (context, state) => const AiSymptomCheckerScreen(),
                  ),
                  GoRoute(
                    path: 'upload-rx',
                    builder: (context, state) => const UploadPrescriptionScreen(),
                  ),
                  GoRoute(
                    path: 'medicines',
                    builder: (context, state) {
                      final category = state.uri.queryParameters['category'] ?? 'All';
                      return MedicinesScreen(initialCategory: category);
                    },
                    routes: [
                      GoRoute(
                        path: 'details',
                        builder: (context, state) {
                          final medicine = state.extra as Map<String, String>;
                          return MedicineDetailsScreen(medicine: medicine);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Branch 1: Chat
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatScreen(),
              ),
            ],
          ),
          // Branch 2: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cart',
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          // Branch 3: Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          // Branch 4: Profile
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
    ],
  );
});

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen(authStateProvider, (prev, next) => notifyListeners());
  }
}
