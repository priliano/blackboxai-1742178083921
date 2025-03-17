import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/queue_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/utility_widgets.dart';

class QueueHistoryScreen extends StatefulWidget {
  const QueueHistoryScreen({super.key});

  @override
  State<QueueHistoryScreen> createState() => _QueueHistoryScreenState();
}

class _QueueHistoryScreenState extends State<QueueHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    await queueProvider.loadQueueHistory(refresh: true);
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final queueProvider = Provider.of<QueueProvider>(context, listen: false);
      await queueProvider.loadQueueHistory();
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        children: [
          _FilterChip(
            label: 'Semua',
            isSelected: true,
            onTap: () {
              // TODO: Implement filter
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Menunggu',
            isSelected: false,
            onTap: () {
              // TODO: Implement filter
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Selesai',
            isSelected: false,
            onTap: () {
              // TODO: Implement filter
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Dibatalkan',
            isSelected: false,
            onTap: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Riwayat Antrian',
      ),
      body: Consumer<QueueProvider>(
        builder: (context, queueProvider, child) {
          if (queueProvider.loading && queueProvider.queueHistory.isEmpty) {
            return const LoadingIndicator();
          }

          if (!queueProvider.loading && queueProvider.queueHistory.isEmpty) {
            return const EmptyStateView(
              message: 'Belum ada riwayat antrian',
              icon: Icons.history,
            );
          }

          return Column(
            children: [
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadInitialData(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: queueProvider.queueHistory.length + 1,
                    itemBuilder: (context, index) {
                      if (index == queueProvider.queueHistory.length) {
                        if (_isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      final queue = queueProvider.queueHistory[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: QueueCard(
                          queue: queue,
                          onTap: () {
                            NavigationService().navigateTo(
                              NavigationService.queueDetails,
                              arguments: {
                                'queue_id': queue.id.toString(),
                              },
                            );
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
          color: isSelected
              ? AppColors.primary
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: isSelected
                ? Colors.white
                : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
