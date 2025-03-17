import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/feedback.dart' as feedback_model;
import '../../providers/feedback_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/utility_widgets.dart';
import '../../utils/app_utils.dart';

class FeedbackDetailsScreen extends StatefulWidget {
  final String feedbackId;

  const FeedbackDetailsScreen({
    super.key,
    required this.feedbackId,
  });

  @override
  State<FeedbackDetailsScreen> createState() => _FeedbackDetailsScreenState();
}

class _FeedbackDetailsScreenState extends State<FeedbackDetailsScreen> {
  feedback_model.Feedback? _feedback;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeedbackDetails();
  }

  Future<void> _loadFeedbackDetails() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
      final feedback = await feedbackProvider.getFeedbackDetails(
        int.parse(widget.feedbackId),
      );

      setState(() {
        _feedback = feedback;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  _feedback?.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _feedback?.user?.name ?? 'Pengguna',
                      style: AppTextStyles.subtitle1,
                    ),
                    Text(
                      _feedback?.formattedCreatedAt ?? '-',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                RatingBar.builder(
                  initialRating: _feedback?.rating.toDouble() ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 36,
                  ignoreGestures: true,
                  unratedColor: AppColors.divider,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: AppColors.warning,
                  ),
                  onRatingUpdate: (_) {},
                ),
                const SizedBox(height: 8),
                Text(
                  AppUtils.getRatingText(_feedback?.rating ?? 0),
                  style: AppTextStyles.subtitle1.copyWith(
                    color: AppUtils.getRatingColor(_feedback?.rating ?? 0),
                  ),
                ),
              ],
            ),
          ),
          if (_feedback?.comment != null && _feedback!.comment!.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Komentar',
              style: AppTextStyles.subtitle1,
            ),
            const SizedBox(height: 8),
            Text(
              _feedback!.comment!,
              style: AppTextStyles.body1,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQueueInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Antrian',
            style: AppTextStyles.subtitle1,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Nomor Antrian',
            AppUtils.formatQueueNumber(_feedback?.queue?.queueNumber ?? 0),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Tanggal',
            _feedback?.queue?.formattedArrivalTime ?? '-',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Status',
            AppUtils.getQueueStatusText(_feedback?.queue?.status ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Detail Penilaian',
      ),
      body: _loading
          ? const LoadingIndicator()
          : _error != null
              ? ErrorView(
                  message: _error!,
                  onRetry: _loadFeedbackDetails,
                )
              : RefreshIndicator(
                  onRefresh: _loadFeedbackDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      children: [
                        _buildFeedbackCard(),
                        const SizedBox(height: 24),
                        _buildQueueInfo(),
                        if (_feedback?.adminResponse != null) ...[
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Respon Admin',
                                  style: AppTextStyles.subtitle1,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _feedback!.adminResponse!,
                                  style: AppTextStyles.body1,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Direspon pada: ${_feedback!.formattedRespondedAt}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
    );
  }
}
