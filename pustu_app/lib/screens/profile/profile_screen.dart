import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_inputs.dart';
import '../../widgets/utility_widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name);
    _emailController = TextEditingController(text: user?.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Profil berhasil diperbarui',
        );
        setState(() {
          _isEditing = false;
        });
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

  Future<void> _handleLogout() async {
    final confirmed = await CustomDialog.show(
      context: context,
      title: 'Keluar',
      message: 'Apakah Anda yakin ingin keluar?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.logout();
        if (mounted) {
          NavigationService().navigateToAndClearStack(NavigationService.login);
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
  }

  Widget _buildProfileHeader() {
    final user = Provider.of<AuthProvider>(context).user;
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primary,
          child: Text(
            user?.name.substring(0, 1).toUpperCase() ?? 'U',
            style: AppTextStyles.heading1.copyWith(
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.name ?? 'Pengguna',
          style: AppTextStyles.heading2,
        ),
        Text(
          user?.email ?? '-',
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            user?.role.toUpperCase() ?? 'PATIENT',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            label: 'Nama Lengkap',
            controller: _nameController,
            enabled: _isEditing,
            textCapitalization: TextCapitalization.words,
            prefixIcon: const Icon(Icons.person_outline),
            validator: AppValidators.required,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            controller: _emailController,
            enabled: _isEditing,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: AppValidators.email,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final authProvider = Provider.of<AuthProvider>(context);
    return Column(
      children: [
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: 'Batal',
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _nameController.text = authProvider.user?.name ?? '';
                      _emailController.text = authProvider.user?.email ?? '';
                    });
                  },
                  icon: Icons.close,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  text: 'Simpan',
                  onPressed: _handleUpdateProfile,
                  isLoading: authProvider.loading,
                  icon: Icons.save,
                ),
              ),
            ],
          )
        else
          PrimaryButton(
            text: 'Edit Profil',
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
            icon: Icons.edit,
          ),
        const SizedBox(height: 16),
        SecondaryButton(
          text: 'Ganti Password',
          onPressed: () {
            // TODO: Implement change password
          },
          icon: Icons.lock_outline,
        ),
        const SizedBox(height: 16),
        SecondaryButton(
          text: 'Keluar',
          onPressed: _handleLogout,
          icon: Icons.logout,
          color: AppColors.error,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Profil',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildProfileForm(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }
}
