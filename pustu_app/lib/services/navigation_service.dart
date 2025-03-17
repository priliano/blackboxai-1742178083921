import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateToAndReplace(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<dynamic> navigateToAndClearStack(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  void goBack([dynamic result]) {
    return navigatorKey.currentState!.pop(result);
  }

  bool canGoBack() {
    return navigatorKey.currentState!.canPop();
  }

  // Handle notification navigation
  void handleNotificationNavigation(String? payload) {
    if (payload == null) return;

    final parts = payload.split(':');
    if (parts.length != 2) return;

    final type = parts[0];
    final id = parts[1];

    switch (type) {
      case 'queue_called':
        navigateTo('/queue-details', arguments: {'queue_id': id});
        break;
      case 'queue_registered':
        navigateTo('/queue-details', arguments: {'queue_id': id});
        break;
      case 'queue_reminder':
        navigateTo('/queue-details', arguments: {'queue_id': id});
        break;
      case 'queue_skipped':
        navigateTo('/queue-details', arguments: {'queue_id': id});
        break;
      case 'feedback_request':
        navigateTo('/feedback-form', arguments: {'queue_id': id});
        break;
      case 'feedback_submitted':
        navigateTo('/feedback-details', arguments: {'feedback_id': id});
        break;
    }
  }

  // Route names as constants
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String queueRegistration = '/queue-registration';
  static const String queueDetails = '/queue-details';
  static const String queueHistory = '/queue-history';
  static const String queueManagement = '/queue-management';
  static const String feedbackForm = '/feedback-form';
  static const String feedbackHistory = '/feedback-history';
  static const String feedbackDetails = '/feedback-details';
  static const String feedbackManagement = '/feedback-management';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String adminDashboard = '/admin-dashboard';
  static const String petugasDashboard = '/petugas-dashboard';
  static const String statistics = '/statistics';
}

// Extension for easier navigation from widgets
extension NavigationExtension on BuildContext {
  NavigationService get navigator => NavigationService();
}
