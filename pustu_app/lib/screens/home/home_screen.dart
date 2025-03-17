import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/queue_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/utility_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    await queueProvider.checkActiveQueue();
    await queueProvider.refreshQueueStatus();
  }

  Future<void> _handleRegisterQueue() async {
    try {
      final queueProvider = Provider.of<QueueProvider>(context, listen: false);
      await queueProvider.registerQueue();
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Berhasil mendaftar antrian',
        );
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

  Future<void> _handleCancelQueue() async {
    final confirmed = await CustomDialog.show(
      context: context,
      title: 'Batalkan Antrian',
      message: 'Apakah Anda yakin ingin membatalkan antrian?',
      confirmText: 'Ya, Batalkan',
      cancelText: 'Tidak',
      isDestructive: true,
    );

    if (confirmed == true) {
      try {
        final queueProvider = Provider.of<QueueProvider>(context, listen: false);
        await queueProvider.cancelQueue();
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Antrian berhasil dibatalkan',
          );
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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final queueProvider = Provider.of<QueueProvider>(context);
    final currentStatus = queueProvider.currentStatus;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Beranda',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              NavigationService().navigateTo(NavigationService.queueHistory);
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              NavigationService().navigateTo(NavigationService.profile);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Message
              Text(
                'Selamat datang,',
                style: AppTextStyles.body1,
              ),
              Text(
                authProvider.user?.name ?? 'Pengguna',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 24),

              // Current Queue Status
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Status Antrian Saat Ini',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nomor Antrian: ${currentStatus?['current_queue'] ?? '-'}',
                      style: AppTextStyles.body1,
                    ),
                    Text(
                      'Jumlah Menunggu: ${currentStatus?['waiting_count'] ?? '0'} orang',
                      style: AppTextStyles.body1,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active Queue
              if (queueProvider.loading)
                const Center(child: CircularProgressIndicator())
              else if (queueProvider.hasActiveQueue)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Antrian Anda',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 16),
                    QueueCard(
                      queue: queueProvider.activeQueue!,
                      onTap: () {
                        NavigationService().navigateTo(
                          NavigationService.queueDetails,
                          arguments: {
                            'queue_id': queueProvider.activeQueue!.id.toString(),
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SecondaryButton(
                      text: 'Batalkan Antrian',
                      onPressed: _handleCancelQueue,
                      icon: Icons.cancel_outlined,
                      color: AppColors.error,
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    const EmptyStateView(
                      message: 'Anda belum memiliki antrian aktif',
                      icon: Icons.queue,
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Daftar Antrian',
                      onPressed: _handleRegisterQueue,
                      icon: Icons.add,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
