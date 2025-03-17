import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/utility_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _queueUpdatesEnabled = true;
  bool _feedbackResponsesEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // TODO: Load saved settings from SharedPreferences
  }

  Widget _buildThemeSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tampilan',
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _SettingsCard(
          child: Column(
            children: [
              _SettingsItem(
                icon: Icons.brightness_6,
                title: 'Tema',
                trailing: DropdownButton<ThemeMode>(
                  value: themeProvider.themeMode,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text('Sistem'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text('Terang'),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text('Gelap'),
                    ),
                  ],
                  onChanged: (ThemeMode? mode) {
                    if (mode != null) {
                      themeProvider.setThemeMode(mode);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifikasi',
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _SettingsCard(
          child: Column(
            children: [
              _SettingsItem(
                icon: Icons.notifications,
                title: 'Notifikasi',
                subtitle: 'Aktifkan atau nonaktifkan semua notifikasi',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
              ),
              if (_notificationsEnabled) ...[
                const Divider(),
                _SettingsItem(
                  icon: Icons.queue,
                  title: 'Update Antrian',
                  subtitle: 'Notifikasi saat status antrian berubah',
                  trailing: Switch(
                    value: _queueUpdatesEnabled,
                    onChanged: (value) {
                      setState(() {
                        _queueUpdatesEnabled = value;
                      });
                    },
                  ),
                ),
                const Divider(),
                _SettingsItem(
                  icon: Icons.feedback,
                  title: 'Respon Feedback',
                  subtitle: 'Notifikasi saat admin merespon feedback',
                  trailing: Switch(
                    value: _feedbackResponsesEnabled,
                    onChanged: (value) {
                      setState(() {
                        _feedbackResponsesEnabled = value;
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tentang',
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _SettingsCard(
          child: Column(
            children: [
              _SettingsItem(
                icon: Icons.info_outline,
                title: 'Versi Aplikasi',
                trailing: Text(
                  AppConstants.appVersion,
                  style: AppTextStyles.body2,
                ),
              ),
              const Divider(),
              _SettingsItem(
                icon: Icons.description_outlined,
                title: 'Kebijakan Privasi',
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
              const Divider(),
              _SettingsItem(
                icon: Icons.help_outline,
                title: 'Bantuan',
                onTap: () {
                  // TODO: Open help/FAQ
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Pengaturan',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            _buildThemeSection(),
            const SizedBox(height: 24),
            _buildNotificationSection(),
            const SizedBox(height: 24),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.body1,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
