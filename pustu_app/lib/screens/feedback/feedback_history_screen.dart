import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/feedback_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/utility_widgets.dart';

class FeedbackHistoryScreen extends StatefulWidget {
  const FeedbackHistoryScreen({super.key});

  @override
  State<FeedbackHistoryScreen> createState() => _FeedbackHistoryScreenState();
}

class _FeedbackHistoryScreenState extends State<FeedbackHistoryScreen> {
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
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    await feedbackProvider.loadUserFeedbacks(refresh: true);
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      await feedbackProvider.loadUserFeedbacks();
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

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.star,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Ringkasan Penilaian',
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
                label: 'Total Penilaian',
                value: '12',
                icon: Icons.assessment,
              ),
              _buildStatItem(
                label: 'Rata-rata',
                value: '4.5',
                icon: Icons.star,
              ),
              _buildStatItem(
                label: 'Bulan Ini',
                value: '3',
                icon: Icons.calendar_today,
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
        Icon(
          icon,
          color: AppColors.primary,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Riwayat Penilaian',
      ),
      body: Consumer<FeedbackProvider>(
        builder: (context, feedbackProvider, child) {
          if (feedbackProvider.loading && feedbackProvider.userFeedbacks.isEmpty) {
            return const LoadingIndicator();
          }

          if (!feedbackProvider.loading && feedbackProvider.userFeedbacks.isEmpty) {
            return const EmptyStateView(
              message: 'Belum ada riwayat penilaian',
              icon: Icons.feedback_outlined,
            );
          }

          return Column(
            children: [
              _buildStatistics(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _loadInitialData(),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    itemCount: feedbackProvider.userFeedbacks.length + 1,
                    itemBuilder: (context, index) {
                      if (index == feedbackProvider.userFeedbacks.length) {
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

                      final feedback = feedbackProvider.userFeedbacks[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FeedbackCard(
                          feedback: feedback,
                          onTap: () {
                            NavigationService().navigateTo(
                              NavigationService.feedbackDetails,
                              arguments: {
                                'feedback_id': feedback.id.toString(),
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
