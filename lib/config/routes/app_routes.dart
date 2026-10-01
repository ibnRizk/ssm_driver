import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/slider_photo.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_status_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/orders/presentation/screens/delivery_to_customer_screen.dart';
import '../../features/orders/presentation/screens/navigate_to_store_screen.dart';
import '../../features/orders/presentation/screens/order_trip_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/orders/presentation/screens/pickup_confirmation_screen.dart';
import '../../features/orders/presentation/screens/proof_of_delivery_screen.dart';
import '../../features/earnings/presentation/screens/earnings_screen.dart';
import '../../features/parcels/domain/entities/parcel.dart';
import '../../features/parcels/presentation/screens/parcel_details_screen.dart';
import '../../features/parcels/presentation/screens/parcel_proof_screen.dart';
import '../../features/parcels/presentation/screens/parcels_screen.dart';
import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/my_data_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/support/presentation/screens/support_screen.dart';
import '../../injection_container.dart';

import 'main_scaffold.dart';
import 'navigator_observer.dart';

abstract class AppRoutes {
  // --- Paths (for context.go / context.push) ---
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String onboardingStatus = '/onboarding-status';
  static const String home = '/home';
  static const String orders = '/orders';
  static const String parcels = '/parcels';
  static const String earnings = '/earnings';
  static const String profile = '/profile';
  static const String photoViewer = '/photo-viewer';
  static const String orderTrip = '/order-trip';
  static const String navigateToStore =
      '/navigate-to-store';
  static const String pickupConfirmation =
      '/pickup-confirmation';
  static const String deliveryToCustomer =
      '/delivery-to-customer';
  static const String proofOfDelivery =
      '/proof-of-delivery';
  static const String parcelDetails = '/parcel-details/:id';
  static const String parcelProof = '/parcel-proof';
  static const String myData = '/my-data';
  static const String editProfile = '/edit-profile';
  static const String support = '/support';

  // --- Names (for context.goNamed / context.pushNamed) ---
  static const String splashName = 'splash';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String onboardingStatusName = 'onboardingStatus';
  static const String homeName = 'home';
  static const String ordersName = 'orders';
  static const String parcelsName = 'parcels';
  static const String earningsName = 'earnings';
  static const String profileName = 'profile';
  static const String photoViewerName = 'photoViewer';
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
  static const String parcelProofName = 'parcelProof';
  static const String myDataName = 'myData';
  static const String editProfileName = 'editProfile';
  static const String supportName = 'support';

  /// The top-level navigator, for UI shown over any screen from outside the
  /// route tree (the incoming-offer sheet).
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: splash,
    observers: <NavigatorObserver>[AppNavigatorObserver()],
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: splash,
        name: splashName,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: onboardingStatus,
        name: onboardingStatusName,
        builder: (_, __) => const OnboardingStatusScreen(),
      ),
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

      // Outside the shell on purpose: a linear post-accept flow, not a tab.
      // Reads the app-wide CurrentWorkCubit. (Incoming offers aren't a
      // route: IncomingOrderPresenter shows them as a sheet.)
      GoRoute(
        path: orderTrip,
        name: orderTripName,
        builder: (_, __) => const OrderTripScreen(),
      ),

      // The delivery steps below sit outside the shell for the same reason
      // as `orderTrip`. They all read the app-wide CurrentWorkCubit, so every
      // step (and the Orders tab) shares one server-confirmed order state.
      GoRoute(
        path: navigateToStore,
        name: navigateToStoreName,
        builder: (_, __) => const NavigateToStoreScreen(),
      ),

      GoRoute(
        path: pickupConfirmation,
        name: pickupConfirmationName,
        builder: (_, __) => const PickupConfirmationScreen(),
      ),

      GoRoute(
        path: deliveryToCustomer,
        name: deliveryToCustomerName,
        builder: (_, __) => const DeliveryToCustomerScreen(),
      ),

      GoRoute(
        path: proofOfDelivery,
        name: proofOfDeliveryName,
        builder: (_, __) => const ProofOfDeliveryScreen(),
      ),

      // Outside the shell like the order flow. `:id` is the parcel id;
      // `extra` is the list's copy, shown while the server copy loads.
      GoRoute(
        path: parcelDetails,
        name: parcelDetailsName,
        builder: (_, GoRouterState state) => ParcelDetailsScreen(
          parcelId: int.tryParse(state.pathParameters['id'] ?? ''),
          initial: state.extra as Parcel?,
        ),
      ),

      // `extra` is the parcel to complete; pops with the delivered parcel.
      GoRoute(
        path: parcelProof,
        name: parcelProofName,
        builder: (_, GoRouterState state) =>
            ParcelProofScreen(parcel: state.extra as Parcel?),
      ),

      // `extra` is the Profile tab's ProfileCubit, so the already-loaded
      // profile is reused instead of fetched again.
      GoRoute(
        path: myData,
        name: myDataName,
        builder: (_, GoRouterState state) =>
            MyDataScreen(cubit: state.extra as ProfileCubit?),
      ),

      // `extra` is the Profile tab's ProfileCubit: pre-fills the form and is
      // refreshed after a successful save.
      GoRoute(
        path: editProfile,
        name: editProfileName,
        builder: (_, GoRouterState state) =>
            EditProfileScreen(cubit: state.extra as ProfileCubit?),
      ),

      GoRoute(
        path: support,
        name: supportName,
        builder: (_, _) => const SupportScreen(),
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
