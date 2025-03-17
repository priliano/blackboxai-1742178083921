import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../models/queue.dart';
import '../../providers/queue_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/utility_widgets.dart';
import '../../utils/app_utils.dart';

class QueueDetailsScreen extends StatefulWidget {
  final String queueId;

  const QueueDetailsScreen({
    super.key,
    required this.queueId,
  });

  @override
  State<QueueDetailsScreen> createState() => _QueueDetailsScreenState();
}

class _QueueDetailsScreenState extends State<QueueDetailsScreen> {
  Queue? _queue;
  Map<String, dynamic>? _position;
  bool _loading = true;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadQueueDetails();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _loadQueueDetails(),
    );
  }

  Future<void> _loadQueueDetails() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final queueProvider = Provider.of<QueueProvider>(context, listen: false);
      final queue = await queueProvider.getQueueDetails(int.parse(widget.queueId));
      final position = await queueProvider.getQueuePosition(int.parse(widget.queueId));

      setState(() {
        _queue = queue;
        _position = position;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _buildStatusTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Antrian',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        _TimelineItem(
          title: 'Terdaftar',
          time: _queue?.formattedArrivalTime ?? '-',
          isCompleted: true,
          isFirst: true,
        ),
        _TimelineItem(
          title: 'Menunggu',
          time: _queue?.status == 'waiting' ? 'Sedang berlangsung' : '-',
          isCompleted: _queue?.status != 'waiting',
        ),
        _TimelineItem(
          title: 'Dipanggil',
          time: _queue?.formattedCalledTime ?? '-',
          isCompleted: _queue?.status == 'called' || _queue?.status == 'completed',
        ),
        _TimelineItem(
          title: 'Selesai',
          time: _queue?.status == 'completed' ? 'Selesai' : '-',
          isCompleted: _queue?.status == 'completed',
          isLast: true,
        ),
      ],
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomor Antrian',
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    AppUtils.formatQueueNumber(_queue?.queueNumber ?? 0),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppUtils.getQueueStatusColor(_queue?.status ?? '')
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  AppUtils.getQueueStatusText(_queue?.status ?? ''),
                  style: AppTextStyles.caption.copyWith(
                    color: AppUtils.getQueueStatusColor(_queue?.status ?? ''),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          if (_position != null && _queue?.status == 'waiting') ...[
            _InfoRow(
              icon: Icons.people_outline,
              label: 'Antrian di Depan',
              value: '${_position!['queues_ahead']} orang',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.timer_outlined,
              label: 'Estimasi Waktu Tunggu',
              value: '${_position!['estimated_wait_time']} menit',
            ),
          ],
          _InfoRow(
            icon: Icons.access_time,
            label: 'Waktu Kedatangan',
            value: _queue?.formattedArrivalTime ?? '-',
          ),
          if (_queue?.calledAt != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.call,
              label: 'Waktu Dipanggil',
              value: _queue?.formattedCalledTime ?? '-',
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Detail Antrian',
      ),
      body: _loading
          ? const LoadingIndicator()
          : _error != null
              ? ErrorView(
                  message: _error!,
                  onRetry: _loadQueueDetails,
                )
              : RefreshIndicator(
                  onRefresh: _loadQueueDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildQueueInfo(),
                        const SizedBox(height: 24),
                        _buildStatusTimeline(),
                        const SizedBox(height: 24),
                        if (_queue?.status == 'completed')
                          PrimaryButton(
                            text: 'Berikan Penilaian',
                            onPressed: () {
                              NavigationService().navigateTo(
                                NavigationService.feedbackForm,
                                arguments: {
                                  'queue_id': widget.queueId,
                                },
                              );
                            },
                            icon: Icons.star_outline,
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String title;
  final String time;
  final bool isCompleted;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({
    required this.title,
    required this.time,
    required this.isCompleted,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : AppColors.divider,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.divider,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.subtitle1,
                  ),
                  Text(
                    time,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: AppTextStyles.body2.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
