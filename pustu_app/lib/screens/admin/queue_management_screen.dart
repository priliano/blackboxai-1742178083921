import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/queue_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/custom_inputs.dart';
import '../../widgets/utility_widgets.dart';
import '../../utils/app_utils.dart';

class QueueManagementScreen extends StatefulWidget {
  const QueueManagementScreen({super.key});

  @override
  State<QueueManagementScreen> createState() => _QueueManagementScreenState();
}

class _QueueManagementScreenState extends State<QueueManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    await queueProvider.loadActiveQueues();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      // TODO: Implement search functionality
    });
  }

  Widget _buildQueueStatistics() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final stats = queueProvider.statistics;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Statistik Antrian Hari Ini',
                style: AppTextStyles.subtitle1.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: 'Total',
                value: stats?['total_today']?.toString() ?? '0',
                icon: Icons.people_outline,
              ),
              _buildStatItem(
                label: 'Selesai',
                value: stats?['completed_today']?.toString() ?? '0',
                icon: Icons.check_circle_outline,
              ),
              _buildStatItem(
                label: 'Menunggu',
                value: stats?['waiting_count']?.toString() ?? '0',
                icon: Icons.access_time,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'Semua',
            isSelected: _selectedFilter == 'all',
            onTap: () => setState(() => _selectedFilter = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Menunggu',
            isSelected: _selectedFilter == 'waiting',
            onTap: () => setState(() => _selectedFilter = 'waiting'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Dipanggil',
            isSelected: _selectedFilter == 'called',
            onTap: () => setState(() => _selectedFilter = 'called'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Selesai',
            isSelected: _selectedFilter == 'completed',
            onTap: () => setState(() => _selectedFilter = 'completed'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manajemen Antrian',
      ),
      body: Consumer<QueueProvider>(
        builder: (context, queueProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    _buildQueueStatistics(),
                    const SizedBox(height: 16),
                    CustomSearchField(
                      controller: _searchController,
                      hint: 'Cari nomor antrian...',
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: queueProvider.loading && queueProvider.activeQueues.isEmpty
                      ? const LoadingIndicator()
                      : queueProvider.activeQueues.isEmpty
                          ? const EmptyStateView(
                              message: 'Tidak ada antrian aktif',
                              icon: Icons.queue,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppConstants.defaultPadding),
                              itemCount: queueProvider.activeQueues.length,
                              itemBuilder: (context, index) {
                                final queue = queueProvider.activeQueues[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: QueueCard(
                                    queue: queue,
                                    showActions: true,
                                    onTap: () {
                                      NavigationService().navigateTo(
                                        NavigationService.queueDetails,
                                        arguments: {
                                          'queue_id': queue.id.toString(),
                                        },
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
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
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
