import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/queue_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/utility_widgets.dart';
import '../../utils/app_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);

    await Future.wait([
      queueProvider.loadQueueStatistics(),
      feedbackProvider.loadFeedbackStatistics(),
    ]);
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PeriodChip(
            label: 'Minggu',
            value: 'week',
            selectedPeriod: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Bulan',
            value: 'month',
            selectedPeriod: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
          ),
          const SizedBox(width: 8),
          _PeriodChip(
            label: 'Tahun',
            value: 'year',
            selectedPeriod: _selectedPeriod,
            onSelected: (value) => setState(() => _selectedPeriod = value),
          ),
        ],
      ),
    );
  }

  Widget _buildQueueStatistics() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final stats = queueProvider.statistics;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          _StatCard(
            title: 'Total Antrian',
            value: stats?['total_today']?.toString() ?? '0',
            icon: Icons.people_outline,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Selesai',
                  value: stats?['completed_today']?.toString() ?? '0',
                  icon: Icons.check_circle_outline,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Dilewati',
                  value: stats?['skipped_today']?.toString() ?? '0',
                  icon: Icons.skip_next,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _StatCard(
            title: 'Rata-rata Waktu Tunggu',
            value: '${stats?['average_wait_time'] ?? 0} menit',
            icon: Icons.timer,
            color: AppColors.info,
          ),
          const SizedBox(height: 24),
          Text(
            'Tren Antrian',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          // TODO: Add queue trend chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Queue Trend Chart'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackStatistics() {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);
    final stats = feedbackProvider.statistics;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          _buildPeriodSelector(),
          const SizedBox(height: 24),
          _StatCard(
            title: 'Rating Keseluruhan',
            value: (stats?['overall_rating'] ?? 0).toStringAsFixed(1),
            icon: Icons.star_outline,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Feedback',
                  value: stats?['this_month']?['total_feedbacks']?.toString() ?? '0',
                  icon: Icons.feedback_outlined,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Belum Direspon',
                  value: '0', // TODO: Add pending feedback count
                  icon: Icons.pending_outlined,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Distribusi Rating',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          // TODO: Add rating distribution chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Rating Distribution Chart'),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tren Feedback',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          // TODO: Add feedback trend chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Feedback Trend Chart'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Statistik',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Antrian'),
            Tab(text: 'Feedback'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildQueueStatistics(),
          _buildFeedbackStatistics(),
        ],
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
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.body2.copyWith(
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedPeriod;
  final ValueChanged<String> onSelected;

  const _PeriodChip({
    required this.label,
    required this.value,
    required this.selectedPeriod,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedPeriod;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
