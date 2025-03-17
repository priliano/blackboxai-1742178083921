import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppConstants {
  // App Information
  static const String appName = 'Pustu Queue';
  static const String appVersion = '1.0.0';
  
  // API Constants
  static const String apiBaseUrl = 'http://localhost:8000/api';
  static const int apiTimeout = 30; // seconds
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String fcmTokenKey = 'fcm_token';

  // Navigation Routes
  static const String initialRoute = '/';
  static const Duration navigationTransitionDuration = Duration(milliseconds: 300);

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Sizes
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  static const double defaultIconSize = 24.0;
  static const double defaultElevation = 2.0;
}

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Secondary Colors
  static const Color secondary = Color(0xFF03A9F4);
  static const Color secondaryLight = Color(0xFF4FC3F7);
  static const Color secondaryDark = Color(0xFF0288D1);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFA000);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Queue Status Colors
  static const Color waiting = Color(0xFFFFA000);
  static const Color called = Color(0xFF4CAF50);
  static const Color completed = Color(0xFF2196F3);
  static const Color skipped = Color(0xFFF44336);

  // Rating Colors
  static const Color rating1 = Color(0xFFF44336);
  static const Color rating2 = Color(0xFFFF9800);
  static const Color rating3 = Color(0xFFFFC107);
  static const Color rating4 = Color(0xFF8BC34A);
  static const Color rating5 = Color(0xFF4CAF50);

  // Neutral Colors
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color divider = Color(0xFFE0E0E0);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
}

class AppTextStyles {
  static TextStyle heading1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static TextStyle heading3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle1 = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static TextStyle subtitle2 = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle body1 = GoogleFonts.poppins(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static TextStyle body2 = GoogleFonts.poppins(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppDecorations {
  static BoxDecoration card = BoxDecoration(
    color: AppColors.background,
    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration roundedBox = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
  );

  static InputDecoration inputDecoration = InputDecoration(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: const BorderSide(
        color: AppColors.primary,
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      borderSide: const BorderSide(
        color: AppColors.error,
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppConstants.defaultPadding,
      vertical: AppConstants.defaultPadding * 0.75,
    ),
  );
}

class AppValidators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'Field ini wajib diisi';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email wajib diisi';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password wajib diisi';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon wajib diisi';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }
}
