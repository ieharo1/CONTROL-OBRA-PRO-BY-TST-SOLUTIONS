import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/clients/clients_screen.dart';
import '../screens/clients/client_form_screen.dart';
import '../screens/clients/client_detail_screen.dart';
import '../screens/debts/debts_screen.dart';
import '../screens/debts/debt_form_screen.dart';
import '../screens/debts/debt_detail_screen.dart';
import '../screens/debts/payment_form_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about/about_screen.dart';
import '../widgets/main_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DashboardScreen(),
          ),
        ),
        GoRoute(
          path: '/clients',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ClientsScreen(),
          ),
        ),
        GoRoute(
          path: '/debts',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DebtsScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/client/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ClientFormScreen(),
    ),
    GoRoute(
      path: '/client/:uuid',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final uuid = state.pathParameters['uuid']!;
        return ClientDetailScreen(clientUuid: uuid);
      },
    ),
    GoRoute(
      path: '/client/:uuid/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final uuid = state.pathParameters['uuid']!;
        return ClientFormScreen(clientUuid: uuid);
      },
    ),
    GoRoute(
      path: '/debt/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final clientUuid = state.uri.queryParameters['clientUuid'];
        return DebtFormScreen(preselectedClientUuid: clientUuid);
      },
    ),
    GoRoute(
      path: '/debt/:uuid',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final uuid = state.pathParameters['uuid']!;
        return DebtDetailScreen(debtUuid: uuid);
      },
    ),
    GoRoute(
      path: '/debt/:uuid/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final uuid = state.pathParameters['uuid']!;
        return DebtFormScreen(debtUuid: uuid);
      },
    ),
    GoRoute(
      path: '/debt/:uuid/payment',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final uuid = state.pathParameters['uuid']!;
        return PaymentFormScreen(debtUuid: uuid);
      },
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const AboutScreen(),
    ),
  ],
);
