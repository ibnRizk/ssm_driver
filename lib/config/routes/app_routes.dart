import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/slider_photo.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/orders/presentation/screens/delivery_to_customer_screen.dart';
import '../../features/orders/presentation/screens/incoming_order_screen.dart';
import '../../features/orders/presentation/screens/navigate_to_store_screen.dart';
import '../../features/orders/presentation/screens/order_trip_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/pickup_confirmation_screen.dart';
import '../../features/orders/presentation/screens/proof_of_delivery_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/parcels/presentation/screens/parcel_details_screen.dart';
import '../../features/parcels/presentation/screens/parcels_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../injection_container.dart';

import 'main_scaffold.dart';
import 'navigator_observer.dart';

abstract class AppRoutes {
  // --- Paths (for context.go / context.push) ---
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String parcels = '/parcels';
  static const String earnings = '/earnings';
  static const String profile = '/profile';
  static const String photoViewer = '/photo-viewer';
  static const String incomingOrder = '/incoming-order';
  static const String orderTrip = '/order-trip';
  static const String navigateToStore =
      '/navigate-to-store';
  static const String pickupConfirmation =
      '/pickup-confirmation';
  static const String deliveryToCustomer =
      '/delivery-to-customer';
  static const String proofOfDelivery =
      '/proof-of-delivery';
  static const String parcelDetails = '/parcel-details';

  // --- Names (for context.goNamed / context.pushNamed) ---
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String homeName = 'home';
  static const String ordersName = 'orders';
  static const String parcelsName = 'parcels';
  static const String earningsName = 'earnings';
  static const String profileName = 'profile';
  static const String photoViewerName = 'photoViewer';
  static const String incomingOrderName = 'incomingOrder';
  static const String orderTripName = 'orderTrip';
  static const String navigateToStoreName =
      'navigateToStore';
  static const String pickupConfirmationName =
      'pickupConfirmation';
  static const String deliveryToCustomerName =
      'deliveryToCustomer';
  static const String proofOfDeliveryName =
      'proofOfDelivery';
  static const String parcelDetailsName = 'parcelDetails';

  static final GoRouter router = GoRouter(
    initialLocation: login,
    observers: <NavigatorObserver>[AppNavigatorObserver()],
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: login,
        name: loginName,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: register,
        name: registerName,
        builder: (_, __) => const RegisterScreen(),
      ),

      // Bottom-nav shell — each branch below keeps its own navigation stack
      // (see MainScaffold). Push further screens *inside* a tab (e.g. order
      // details) as children of that branch's GoRoute; routes outside the
      // shell — auth, full-screen flows — belong at the top level, like
      // `photoViewer` below.
      //
      // Every tab currently renders `ShellTabPlaceholder` — swap each one for
      // its real feature screen as that feature is built; the route wiring
      // and MainScaffold don't need to change.
      StatefulShellRoute.indexedStack(
        builder: (_, __, StatefulNavigationShell shell) =>
            MainScaffold(navigationShell: shell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: home,
                name: homeName,
                builder: (_, __) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: orders,
                name: ordersName,
                builder: (_, __) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: parcels,
                name: parcelsName,
                builder: (_, __) => const ParcelsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: earnings,
                name: earningsName,
                builder: (_, __) => const EarningsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: profile,
                name: profileName,
                builder: (_, __) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: photoViewer,
        name: photoViewerName,
        builder: (_, GoRouterState state) {
          final Map<String, dynamic> args =
              (state.extra as Map<String, dynamic>?) ??
              <String, dynamic>{};
          return SliderPhotoScreen(
            imagesFiles: args['imagesFiles'],
            images: args['images'],
            path: args['path'],
            imageIndex: args['imageIndex'] ?? 0,
          );
        },
      ),

      // Outside the shell on purpose: a one-off dispatch prompt, not a tab —
      // pushed on top of whatever screen is active when an order arrives.
      GoRoute(
        path: incomingOrder,
        name: incomingOrderName,
        builder: (_, __) => const IncomingOrderScreen(),
      ),

      // Outside the shell for the same reason as `incomingOrder` above: a
      // linear post-accept flow, not a tab.
      GoRoute(
        path: orderTrip,
        name: orderTripName,
        builder: (_, __) => const OrderTripScreen(),
      ),

      // Outside the shell for the same reason as `orderTrip` above.
      GoRoute(
        path: navigateToStore,
        name: navigateToStoreName,
        builder: (_, __) => const NavigateToStoreScreen(),
      ),

      // Outside the shell for the same reason as `navigateToStore` above.
      GoRoute(
        path: pickupConfirmation,
        name: pickupConfirmationName,
        builder: (_, __) =>
            const PickupConfirmationScreen(),
      ),

      // Outside the shell for the same reason as `pickupConfirmation` above.
      GoRoute(
        path: deliveryToCustomer,
        name: deliveryToCustomerName,
        builder: (_, __) =>
            const DeliveryToCustomerScreen(),
      ),

      GoRoute(
        path: proofOfDelivery,
        name: proofOfDeliveryName,
        builder: (_, __) => const ProofOfDeliveryScreen(),
      ),

      GoRoute(
        path: parcelDetails,
        name: parcelDetailsName,
        builder: (_, __) => const ParcelDetailsScreen(),
      ),
    ],
    errorBuilder: (_, GoRouterState state) => Scaffold(
      body: Center(
        child: Text('No route found for ${state.uri}'),
      ),
    ),
  );

  static String get currentRoute =>
      routesStack.isEmpty ? login : routesStack.last;

  static void pushRouteToRoutesStack(String route) =>
      routesStack.add(route);

  static void popRouteFromRoutesStack() {
    if (routesStack.isNotEmpty) routesStack.removeLast();
  }
}
