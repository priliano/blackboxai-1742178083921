import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/queue_provider.dart';
import '../../utils/app_utils.dart';

class QueueDisplayScreen extends StatefulWidget {
  const QueueDisplayScreen({super.key});

  @override
  State<QueueDisplayScreen> createState() => _QueueDisplayScreenState();
}

class _QueueDisplayScreenState extends State<QueueDisplayScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _startPeriodicRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadData(),
    );
  }

  Future<void> _loadData() async {
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    await queueProvider.loadActiveQueues();
    await queueProvider.refreshQueueStatus();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.primary,
      child: Row(
        children: [
          const Icon(
            Icons.local_hospital,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PUSTU ANTRIAN',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                Text(
                  'Sistem Antrian Pusat Kesehatan Masyarakat Pembantu',
                  style: AppTextStyles.subtitle1.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateTime.now().formattedDate,
                style: AppTextStyles.heading3.copyWith(
                  color: Colors.white,
                ),
              ),
              StreamBuilder(
                stream: Stream.periodic(const Duration(seconds: 1)),
                builder: (context, snapshot) {
                  return Text(
                    TimeOfDay.now().format(context),
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentNumber() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final currentQueue = queueProvider.activeQueues.firstWhere(
      (q) => q.status == 'called',
      orElse: () => null,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'NOMOR ANTRIAN SAAT INI',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            currentQueue != null
                ? currentQueue.queueNumber.toString().padLeft(3, '0')
                : '---',
            style: AppTextStyles.heading1.copyWith(
              fontSize: 96,
              color: AppColors.primary,
            ),
          ),
          if (currentQueue != null) ...[
            const SizedBox(height: 16),
            Text(
              'Silakan menuju ke loket',
              style: AppTextStyles.subtitle1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaitingList() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final waitingQueues = queueProvider.activeQueues
        .where((q) => q.status == 'waiting')
        .take(5)
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ANTRIAN BERIKUTNYA',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(5, (index) {
              final queue = index < waitingQueues.length ? waitingQueues[index] : null;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: queue != null ? AppColors.primary : AppColors.divider,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        queue != null
                            ? queue.queueNumber.toString().padLeft(3, '0')
                            : '---',
                        style: AppTextStyles.heading2.copyWith(
                          color: queue != null ? AppColors.primary : AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Menunggu',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final currentStatus = queueProvider.currentStatus;

    return Container(
      padding: const EdgeInsets.all(24),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem(
            'Total Hari Ini',
            '${currentStatus?['total_today'] ?? 0}',
            Icons.people,
          ),
          _buildStatusItem(
            'Selesai',
            '${currentStatus?['completed_today'] ?? 0}',
            Icons.check_circle,
          ),
          _buildStatusItem(
            'Menunggu',
            '${currentStatus?['waiting_count'] ?? 0}',
            Icons.access_time,
          ),
          _buildStatusItem(
            'Rata-rata Tunggu',
            '${currentStatus?['average_wait_time'] ?? 0} menit',
            Icons.timer,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildCurrentNumber(),
          _buildWaitingList(),
          const Spacer(),
          _buildFooter(),
        ],
      ),
    );
  }
}
