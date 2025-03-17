import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/queue.dart';
import '../services/queue_service.dart';
import '../services/notification_service.dart';

class QueueProvider with ChangeNotifier {
  final QueueService _queueService = QueueService();
  final NotificationService _notificationService = NotificationService();

  Queue? _activeQueue;
  List<Queue> _queueHistory = [];
  List<Queue> _activeQueues = [];
  Map<String, dynamic>? _currentStatus;
  Map<String, dynamic>? _statistics;
  bool _loading = false;
  String? _error;
  Timer? _refreshTimer;

  // Getters
  Queue? get activeQueue => _activeQueue;
  List<Queue> get queueHistory => _queueHistory;
  List<Queue> get activeQueues => _activeQueues;
  Map<String, dynamic>? get currentStatus => _currentStatus;
  Map<String, dynamic>? get statistics => _statistics;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasActiveQueue => _activeQueue != null;

  QueueProvider() {
    // Start periodic refresh for queue status
    _startPeriodicRefresh();
  }

  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      refreshQueueStatus();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> registerQueue() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      _activeQueue = await _queueService.registerQueue();
      
      // Show notification for successful registration
      await _notificationService.showNotification(
        title: 'Antrian Terdaftar',
        body: 'Nomor antrian Anda: ${_activeQueue!.queueNumber}',
        payload: 'queue_registered:${_activeQueue!.id}',
      );

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> refreshQueueStatus() async {
    try {
      _currentStatus = await _queueService.getCurrentStatus();
      
      // If user has active queue, check its position
      if (_activeQueue != null) {
        final position = await _queueService.getQueuePosition(_activeQueue!.id);
        
        // Show reminder notification if queue is close to being called
        if (position['queues_ahead'] == 1) {
          await _notificationService.showQueueReminderNotification(
            _activeQueue!.queueNumber,
            position['estimated_wait_time'],
          );
        }
        
        // Update active queue with new estimated wait time
        _activeQueue = _activeQueue!.copyWith(
          estimatedWait: position['estimated_wait_time'],
        );
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadQueueHistory() async {
    try {
      _loading = true;
      notifyListeners();

      _queueHistory = await _queueService.getQueueHistory();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Admin/Petugas methods
  Future<void> loadActiveQueues() async {
    try {
      _loading = true;
      notifyListeners();

      _activeQueues = await _queueService.getActiveQueues();
      _statistics = await _queueService.getQueueStatistics();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> callNextQueue() async {
    try {
      _loading = true;
      notifyListeners();

      final nextQueue = await _queueService.callNextQueue();
      if (nextQueue != null) {
        _activeQueues = await _queueService.getActiveQueues();
        
        // Show notification for called queue
        await _notificationService.showQueueCalledNotification(
          nextQueue.queueNumber,
        );
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> skipCurrentQueue() async {
    try {
      _loading = true;
      notifyListeners();

      await _queueService.skipCurrentQueue();
      _activeQueues = await _queueService.getActiveQueues();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> checkActiveQueue() async {
    try {
      final queue = await _queueService.getActiveQueue();
      if (queue != null) {
        _activeQueue = queue;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> cancelQueue() async {
    try {
      _loading = true;
      notifyListeners();

      if (_activeQueue != null) {
        await _queueService.cancelQueue(_activeQueue!.id);
        _activeQueue = null;
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
