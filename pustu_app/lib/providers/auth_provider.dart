import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final NotificationService _notificationService = NotificationService();
  
  User? _user;
  bool _loading = false;
  String? _error;

  User? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isPetugas => _user?.isPetugas ?? false;
  bool get isPatient => _user?.isPatient ?? false;

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _notificationService.initialize();
      
      _user = await _authService.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );

      // Subscribe to appropriate FCM topics based on user role
      if (_user!.isAdmin || _user!.isPetugas) {
        await _notificationService.subscribeToTopic('admin_notifications');
      }
      await _notificationService.subscribeToTopic('queue_updates');

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _notificationService.initialize();
      
      _user = await _authService.login(
        email: email,
        password: password,
      );

      // Subscribe to appropriate FCM topics based on user role
      if (_user!.isAdmin || _user!.isPetugas) {
        await _notificationService.subscribeToTopic('admin_notifications');
      }
      await _notificationService.subscribeToTopic('queue_updates');

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _loading = true;
      notifyListeners();

      // Unsubscribe from FCM topics
      await _notificationService.unsubscribeFromTopic('queue_updates');
      if (_user!.isAdmin || _user!.isPetugas) {
        await _notificationService.unsubscribeFromTopic('admin_notifications');
      }

      await _authService.logout();
      
      _user = null;
      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkAuthStatus() async {
    try {
      _loading = true;
      notifyListeners();

      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        _user = await _authService.getCurrentUser();
        await _notificationService.initialize();
        
        // Resubscribe to topics in case token was refreshed
        if (_user!.isAdmin || _user!.isPetugas) {
          await _notificationService.subscribeToTopic('admin_notifications');
        }
        await _notificationService.subscribeToTopic('queue_updates');
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      _user = await _authService.updateProfile(
        name: name,
        email: email,
      );

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
