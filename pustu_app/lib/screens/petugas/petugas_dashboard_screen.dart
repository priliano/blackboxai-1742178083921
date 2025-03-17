import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_constants.dart';
import '../../providers/queue_provider.dart';
import '../../services/navigation_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_cards.dart';
import '../../widgets/utility_widgets.dart';

class PetugasDashboardScreen extends StatefulWidget {
  const PetugasDashboardScreen({super.key});

  @override
  State<PetugasDashboardScreen> createState() => _PetugasDashboardScreenState();
}

class _PetugasDashboardScreenState extends State<PetugasDashboardScreen> {
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
      const Duration(seconds: 30),
      (_) => _loadData(),
    );
  }

  Future<void> _loadData() async {
    final queueProvider = Provider.of<QueueProvider>(context, listen: false);
    await queueProvider.loadActiveQueues();
  }

  Widget _buildCurrentQueueCard() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final currentQueue = queueProvider.activeQueues.firstWhere(
      (q) => q.status == 'called',
      orElse: () => null,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Antrian Saat Ini',
                style: AppTextStyles.subtitle1.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'AKTIF',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (currentQueue != null) ...[
            Text(
              'NOMOR',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              currentQueue.queueNumber.toString().padLeft(3, '0'),
              style: AppTextStyles.heading1.copyWith(
                color: Colors.white,
                fontSize: 48,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Dipanggil: ${currentQueue.formattedCalledTime}',
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ] else
            Center(
              child: Text(
                'Tidak ada antrian aktif',
                style: AppTextStyles.subtitle1.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQueueActions() {
    final queueProvider = Provider.of<QueueProvider>(context);
    return Row(
      children: [
        Expanded(
          child: PrimaryButton(
            text: 'Panggil Berikutnya',
            onPressed: () async {
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
            icon: Icons.call,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: SecondaryButton(
            text: 'Lewati',
            onPressed: () async {
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
            icon: Icons.skip_next,
            color: AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueList() {
    final queueProvider = Provider.of<QueueProvider>(context);
    final waitingQueues = queueProvider.activeQueues
        .where((q) => q.status == 'waiting')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Antrian Menunggu',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 16),
        if (waitingQueues.isEmpty)
          const EmptyStateView(
            message: 'Tidak ada antrian yang menunggu',
            icon: Icons.queue,
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: waitingQueues.length,
            itemBuilder: (context, index) {
              final queue = waitingQueues[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: QueueCard(
                  queue: queue,
                  onTap: () {
                    NavigationService().navigateTo(
                      NavigationService.queueDetails,
                      arguments: {'queue_id': queue.id.toString()},
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard Petugas',
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
              _buildCurrentQueueCard(),
              const SizedBox(height: 24),
              _buildQueueActions(),
              const SizedBox(height: 32),
              _buildQueueList(),
            ],
          ),
        ),
      ),
    );
  }
}
