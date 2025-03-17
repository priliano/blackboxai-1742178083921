import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/queue_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/utility_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);

    await Future.wait([
      queueProvider.loadActiveQueues(),
      feedbackProvider.loadFeedbackStatistics(),
    ]);
  }

  Widget _buildStatisticsCards() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final stats = queueProvider.statistics;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Hari Ini',
          value: '${stats?['total_today'] ?? 0}',
          icon: Icons.people,
          color: AppColors.primary,
        ),
        _StatCard(
          title: 'Selesai',
          value: '${stats?['completed_today'] ?? 0}',
          icon: Icons.check_circle,
          color: AppColors.success,
        ),
        _StatCard(
          title: 'Menunggu',
          value: '${stats?['waiting_count'] ?? 0}',
          icon: Icons.access_time,
          color: AppColors.warning,
        ),
        _StatCard(
          title: 'Rata-rata Tunggu',
          value: '${stats?['average_wait_time'] ?? 0} menit',
          icon: Icons.timer,
          color: AppColors.info,
        ),
      ],
    );
  }

  Widget _buildQueueManagement() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final activeQueues = queueProvider.activeQueues;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Antrian Aktif',
              style: AppTextStyles.heading3,
            ),
            TextButton.icon(
              onPressed: () {
                NavigationService().navigateTo(NavigationService.queueManagement);
              },
              icon: const Icon(Icons.queue),
              label: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (activeQueues.isEmpty)
          const EmptyStateView(
            message: 'Tidak ada antrian aktif',
            icon: Icons.queue,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activeQueues.take(3).length,
            itemBuilder: (context, index) {
              final queue = activeQueues[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QueueCard(
                  queue: queue,
                  showActions: true,
                  onTap: () {
                    NavigationService().navigateTo(
                      NavigationService.queueDetails,
                      arguments: {'queue_id': queue.id.toString()},
                    );
                  },
                  onCallNext: () async {
                    try {
                      await queueProvider.callNextQueue();
                      if (mounted) {
                        CustomSnackBar.show(
                          context: context,
                          message: 'Berhasil memanggil antrian berikutnya',
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
                  },
                  onSkip: () async {
                    try {
                      await queueProvider.skipCurrentQueue();
                      if (mounted) {
                        CustomSnackBar.show(
                          context: context,
                          message: 'Berhasil melewati antrian',
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
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildFeedbackSection() {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);
    final stats = feedbackProvider.statistics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Feedback',
              style: AppTextStyles.heading3,
            ),
            TextButton.icon(
              onPressed: () {
                NavigationService().navigateTo(NavigationService.feedbackManagement);
              },
              icon: const Icon(Icons.feedback),
              label: const Text('Kelola Feedback'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _FeedbackStatRow(
                label: 'Rating Keseluruhan',
                value: '${stats?['overall_rating'] ?? 0}',
                icon: Icons.star,
              ),
              const Divider(height: 24),
              _FeedbackStatRow(
                label: 'Total Feedback',
                value: '${stats?['this_month']?['total_feedbacks'] ?? 0}',
                icon: Icons.assessment,
              ),
              const SizedBox(height: 8),
              _FeedbackStatRow(
                label: 'Rating Bulan Ini',
                value: '${stats?['this_month']?['average_rating'] ?? 0}',
                icon: Icons.trending_up,
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
      appBar: CustomAppBar(
        title: 'Dashboard Admin',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              NavigationService().navigateTo(NavigationService.settings);
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
              _buildStatisticsCards(),
              const SizedBox(height: 32),
              _buildQueueManagement(),
              const SizedBox(height: 32),
              _buildFeedbackSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  color: color,
                ),
              ),
              Text(
                title,
                style: AppTextStyles.caption.copyWith(
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackStatRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _FeedbackStatRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.body2,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.subtitle1.copyWith(
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}
