import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/auth_provider.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/transaction/presentation/cart_screen.dart';
import '../../features/transaction/presentation/payment_screen.dart';
import '../../features/transaction/presentation/transaction_success_screen.dart';
import '../../features/transaction/data/transaction_service.dart';
import '../../features/printer/presentation/printer_config_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/history/presentation/transaction_detail_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoggingIn) return '/login';
      if (isAuthenticated && isLoggingIn) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(path: '/payment', builder: (context, state) => const PaymentScreen()),
      GoRoute(
        path: '/transaction-success',
        builder: (context, state) => TransactionSuccessScreen(result: state.extra as TransactionResult),
      ),
      GoRoute(path: '/printer-settings', builder: (context, state) => const PrinterConfigScreen()),
      GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
      GoRoute(
        path: '/history/:id',
        builder: (context, state) => TransactionDetailScreen(
          transactionId: int.parse(state.pathParameters['id']!),
        ),
      ),
    ],
  );
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(Ref ref) {
    ref.listen(authProvider, (_, __) => notifyListeners());
  }
}