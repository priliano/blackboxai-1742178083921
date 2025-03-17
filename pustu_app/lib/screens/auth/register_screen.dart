import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_inputs.dart';
import '../../widgets/utility_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password wajib diisi';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
      );

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Registrasi berhasil! Silakan masuk.',
        );
        NavigationService().navigateToAndReplace(NavigationService.login);
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: e.toString(),
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Buat Akun',
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Daftar untuk menggunakan layanan kami',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Name Field
                CustomTextField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap Anda',
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person_outline),
                  validator: AppValidators.required,
                ),
                const SizedBox(height: 16),

                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Masukkan email Anda',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  label: 'Password',
                  hint: 'Masukkan password Anda',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: AppValidators.password,
                ),
                const SizedBox(height: 16),

                // Confirm Password Field
                CustomTextField(
                  label: 'Konfirmasi Password',
                  hint: 'Masukkan ulang password Anda',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: _validateConfirmPassword,
                ),
                const SizedBox(height: 32),

                // Register Button
                PrimaryButton(
                  text: 'Daftar',
                  onPressed: _handleRegister,
                  isLoading: authProvider.loading,
                ),
                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: AppTextStyles.body1,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Masuk',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
