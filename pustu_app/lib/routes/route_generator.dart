import 'package:flutter/material.dart';
import '../services/navigation_service.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/queue/queue_registration_screen.dart';
import '../screens/queue/queue_details_screen.dart';
import '../screens/queue/queue_history_screen.dart';
import '../screens/queue/queue_management_screen.dart';
import '../screens/feedback/feedback_form_screen.dart';
import '../screens/feedback/feedback_history_screen.dart';
import '../screens/feedback/feedback_details_screen.dart';
import '../screens/feedback/feedback_management_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/statistics_screen.dart';
import '../screens/petugas/petugas_dashboard_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case NavigationService.splash:
        return _buildRoute(const SplashScreen());

      case NavigationService.login:
        return _buildRoute(const LoginScreen());

      case NavigationService.register:
        return _buildRoute(const RegisterScreen());

      case NavigationService.home:
        return _buildRoute(const HomeScreen());

      case NavigationService.queueRegistration:
        return _buildRoute(const QueueRegistrationScreen());

      case NavigationService.queueDetails:
        final queueId = args?['queue_id'] as String?;
        if (queueId == null) return _buildErrorRoute();
        return _buildRoute(QueueDetailsScreen(queueId: queueId));

      case NavigationService.queueHistory:
        return _buildRoute(const QueueHistoryScreen());

      case NavigationService.queueManagement:
        return _buildRoute(const QueueManagementScreen());

      case NavigationService.feedbackForm:
        final queueId = args?['queue_id'] as String?;
        if (queueId == null) return _buildErrorRoute();
        return _buildRoute(FeedbackFormScreen(queueId: queueId));

      case NavigationService.feedbackHistory:
        return _buildRoute(const FeedbackHistoryScreen());

      case NavigationService.feedbackDetails:
        final feedbackId = args?['feedback_id'] as String?;
        if (feedbackId == null) return _buildErrorRoute();
        return _buildRoute(FeedbackDetailsScreen(feedbackId: feedbackId));

      case NavigationService.feedbackManagement:
        return _buildRoute(const FeedbackManagementScreen());

      case NavigationService.profile:
        return _buildRoute(const ProfileScreen());

      case NavigationService.settings:
        return _buildRoute(const SettingsScreen());

      case NavigationService.adminDashboard:
        return _buildRoute(const AdminDashboardScreen());

      case NavigationService.petugasDashboard:
        return _buildRoute(const PetugasDashboardScreen());

      case NavigationService.statistics:
        return _buildRoute(const StatisticsScreen());

      default:
        return _buildErrorRoute();
    }
  }

  static PageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(
      builder: (_) => screen,
    );
  }

  static Route<dynamic> _buildErrorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text(
            'Halaman tidak ditemukan',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  // Custom page transitions
  static Widget _buildPageTransition({
    required BuildContext context,
    required Widget child,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
  }) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }

  // Custom route transitions
  static PageRouteBuilder _buildTransitionRoute(Widget screen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildPageTransition(
          context: context,
          child: child,
          animation: animation,
          secondaryAnimation: secondaryAnimation,
        );
      },
    );
  }
}
