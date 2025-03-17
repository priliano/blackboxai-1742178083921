import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/feedback_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/custom_inputs.dart';
import '../../widgets/utility_widgets.dart';
import '../../utils/app_utils.dart';

class FeedbackManagementScreen extends StatefulWidget {
  const FeedbackManagementScreen({super.key});

  @override
  State<FeedbackManagementScreen> createState() => _FeedbackManagementScreenState();
}

class _FeedbackManagementScreenState extends State<FeedbackManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  Timer? _searchDebounce;
  String _selectedFilter = 'all';
  int _selectedRating = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _responseController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    await feedbackProvider.loadRecentFeedbacks(refresh: true);
    await feedbackProvider.loadFeedbackStatistics();
  }

  void _onSearchChanged(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      // TODO: Implement search functionality
    });
  }

  Future<void> _handleRespond(int feedbackId) async {
    _responseController.clear();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _ResponseDialog(
        controller: _responseController,
      ),
    );

    if (result == true && mounted) {
      try {
        final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
        await feedbackProvider.respondToFeedback(
          feedbackId: feedbackId,
          response: _responseController.text.trim(),
        );

        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Berhasil mengirim respon',
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

  Widget _buildStatistics() {
    final feedbackProvider = Provider.of<FeedbackProvider>(context);
    final stats = feedbackProvider.statistics;

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
                'Statistik Feedback',
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
                label: 'Rating',
                value: (stats?['overall_rating'] ?? 0).toStringAsFixed(1),
                icon: Icons.star_outline,
              ),
              _buildStatItem(
                label: 'Total',
                value: stats?['this_month']?['total_feedbacks']?.toString() ?? '0',
                icon: Icons.feedback_outlined,
              ),
              _buildStatItem(
                label: 'Belum Direspon',
                value: '0', // TODO: Add pending feedback count
                icon: Icons.pending_outlined,
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
            label: 'Belum Direspon',
            isSelected: _selectedFilter == 'pending',
            onTap: () => setState(() => _selectedFilter = 'pending'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Sudah Direspon',
            isSelected: _selectedFilter == 'responded',
            onTap: () => setState(() => _selectedFilter = 'responded'),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(5, (index) {
          final rating = index + 1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: _selectedRating == rating
                        ? Colors.white
                        : AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Text(rating.toString()),
                ],
              ),
              selected: _selectedRating == rating,
              onSelected: (selected) {
                setState(() {
                  _selectedRating = selected ? rating : 0;
                });
              },
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Manajemen Feedback',
      ),
      body: Consumer<FeedbackProvider>(
        builder: (context, feedbackProvider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  children: [
                    _buildStatistics(),
                    const SizedBox(height: 16),
                    CustomSearchField(
                      controller: _searchController,
                      hint: 'Cari feedback...',
                      onChanged: _onSearchChanged,
                    ),
                    const SizedBox(height: 16),
                    _buildFilterChips(),
                    const SizedBox(height: 8),
                    _buildRatingFilter(),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: feedbackProvider.loading && feedbackProvider.recentFeedbacks.isEmpty
                      ? const LoadingIndicator()
                      : feedbackProvider.recentFeedbacks.isEmpty
                          ? const EmptyStateView(
                              message: 'Belum ada feedback',
                              icon: Icons.feedback_outlined,
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppConstants.defaultPadding),
                              itemCount: feedbackProvider.recentFeedbacks.length,
                              itemBuilder: (context, index) {
                                final feedback = feedbackProvider.recentFeedbacks[index];
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
                                    onRespond: feedback.adminResponse == null
                                        ? () => _handleRespond(feedback.id)
                                        : null,
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

class _ResponseDialog extends StatelessWidget {
  final TextEditingController controller;

  const _ResponseDialog({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Respon Feedback',
        style: AppTextStyles.heading3,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            label: 'Respon',
            hint: 'Tulis respon Anda...',
            controller: controller,
            maxLines: 4,
            maxLength: 500,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Kirim'),
        ),
      ],
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
