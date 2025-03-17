import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Register a new user
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final deviceToken = await _fcm.getToken();
    
    final response = await _api.post(
      '/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'device_token': deviceToken,
      },
      requiresAuth: false,
    );

    final user = User.fromJson(response['user']);
    await _api.saveToken(response['token']);
    return user;
  }

  // Login user
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final deviceToken = await _fcm.getToken();
    
    final response = await _api.post(
      '/login',
      body: {
        'email': email,
        'password': password,
        'device_token': deviceToken,
      },
      requiresAuth: false,
    );

    final user = User.fromJson(response['user']);
    await _api.saveToken(response['token']);
    return user;
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } finally {
      await _api.removeToken();
    }
  }

  // Get current user profile
  Future<User> getCurrentUser() async {
    final response = await _api.get('/user');
    return User.fromJson(response['user']);
  }

  // Update user profile
  Future<User> updateProfile({
    String? name,
    String? email,
  }) async {
    final response = await _api.put(
      '/user/profile',
      body: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      },
    );

    return User.fromJson(response['user']);
  }

  // Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _api.put(
      '/user/password',
      body: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );
  }

  // Update FCM token
  Future<void> updateFcmToken() async {
    final deviceToken = await _fcm.getToken();
    if (deviceToken != null) {
      await _api.put(
        '/user/device-token',
        body: {'device_token': deviceToken},
      );
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    return token != null;
  }

  // Request password reset
  Future<void> requestPasswordReset(String email) async {
    await _api.post(
      '/forgot-password',
      body: {'email': email},
      requiresAuth: false,
    );
  }

  // Reset password
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _api.post(
      '/reset-password',
      body: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
      requiresAuth: false,
    );
  }
}
