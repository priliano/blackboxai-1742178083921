import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../services/navigation_service.dart';
import '../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Initialize notifications
      final notificationService = NotificationService();
      await notificationService.initialize();

      // Check authentication status
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.checkAuthStatus();

      // Add a small delay to show the splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Navigate based on auth status
      if (authProvider.isAuthenticated) {
        if (authProvider.isAdmin) {
          NavigationService().navigateToAndClearStack(NavigationService.adminDashboard);
        } else if (authProvider.isPetugas) {
          NavigationService().navigateToAndClearStack(NavigationService.petugasDashboard);
        } else {
          NavigationService().navigateToAndClearStack(NavigationService.home);
        }
      } else {
        NavigationService().navigateToAndClearStack(NavigationService.login);
      }
    } catch (e) {
      // If there's an error, navigate to login screen
      NavigationService().navigateToAndClearStack(NavigationService.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_hospital,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // App Name
            Text(
              AppConstants.appName,
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 8),
            
            // App Description
            Text(
              'Sistem Antrian Pusat Kesehatan Masyarakat Pembantu',
              style: AppTextStyles.subtitle1.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            
            // Loading Indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 24),
            
            // Loading Text
            Text(
              'Memuat...',
              style: AppTextStyles.body1.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
