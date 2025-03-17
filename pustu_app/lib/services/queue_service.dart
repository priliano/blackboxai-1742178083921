import '../models/queue.dart';
import 'api_service.dart';

class QueueService {
  final ApiService _api = ApiService();

  // Register a new queue
  Future<Queue> registerQueue() async {
    final response = await _api.post('/queues/register');
    return Queue.fromJson(response['queue']);
  }

  // Get current queue status
  Future<Map<String, dynamic>> getCurrentStatus() async {
    final response = await _api.get('/queues/current');
    return {
      'current_queue': response['current_queue'],
      'waiting_count': response['waiting_count'],
    };
  }

  // Get estimated wait time for a specific queue
  Future<int> getWaitTime(int queueId) async {
    final response = await _api.get('/queues/wait-time/$queueId');
    return response['estimated_wait_minutes'];
  }

  // Get user's queue history
  Future<List<Queue>> getQueueHistory({int page = 1}) async {
    final response = await _api.get('/queues/history?page=$page');
    return (response['data'] as List)
        .map((queue) => Queue.fromJson(queue))
        .toList();
  }

  // Get active queues (for admin/petugas)
  Future<List<Queue>> getActiveQueues() async {
    final response = await _api.get('/queues/active');
    return (response['data'] as List)
        .map((queue) => Queue.fromJson(queue))
        .toList();
  }

  // Call next queue (for admin/petugas)
  Future<Queue?> callNextQueue() async {
    final response = await _api.post('/queues/call-next');
    return response['next_queue'] != null 
        ? Queue.fromJson(response['next_queue']) 
        : null;
  }

  // Skip current queue (for admin/petugas)
  Future<void> skipCurrentQueue() async {
    await _api.post('/queues/skip-current');
  }

  // Get queue statistics (for admin/petugas)
  Future<Map<String, dynamic>> getQueueStatistics() async {
    final response = await _api.get('/queues/statistics');
    return {
      'total_today': response['total_today'],
      'completed_today': response['completed_today'],
      'waiting_count': response['waiting_count'],
      'average_wait_time': response['average_wait_time'],
    };
  }

  // Get specific queue details
  Future<Queue> getQueueDetails(int queueId) async {
    final response = await _api.get('/queues/$queueId');
    return Queue.fromJson(response['queue']);
  }

  // Cancel queue (if allowed by business rules)
  Future<void> cancelQueue(int queueId) async {
    await _api.post('/queues/$queueId/cancel');
  }

  // Get today's queue summary
  Future<Map<String, dynamic>> getTodaysSummary() async {
    final response = await _api.get('/queues/today-summary');
    return {
      'total_queues': response['total_queues'],
      'current_queue': response['current_queue'],
      'next_queue': response['next_queue'],
      'average_wait_time': response['average_wait_time'],
      'estimated_completion_time': response['estimated_completion_time'],
    };
  }

  // Subscribe to queue updates (returns WebSocket URL or topic for FCM)
  Future<String> subscribeToQueueUpdates() async {
    final response = await _api.post('/queues/subscribe');
    return response['subscription_channel'];
  }

  // Mark queue as completed (for admin/petugas)
  Future<void> markQueueAsCompleted(int queueId) async {
    await _api.post('/queues/$queueId/complete');
  }

  // Get queue position
  Future<Map<String, dynamic>> getQueuePosition(int queueId) async {
    final response = await _api.get('/queues/$queueId/position');
    return {
      'position': response['position'],
      'estimated_wait_time': response['estimated_wait_time'],
      'queues_ahead': response['queues_ahead'],
    };
  }

  // Check if user has active queue
  Future<Queue?> getActiveQueue() async {
    try {
      final response = await _api.get('/queues/active-queue');
      return response['queue'] != null 
          ? Queue.fromJson(response['queue']) 
          : null;
    } on NotFoundException {
      return null;
    }
  }
}
