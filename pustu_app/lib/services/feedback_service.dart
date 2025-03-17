import '../models/feedback.dart';
import 'api_service.dart';

class FeedbackService {
  final ApiService _api = ApiService();

  // Submit new feedback
  Future<Feedback> submitFeedback({
    required int queueId,
    required int rating,
    String? comment,
  }) async {
    final response = await _api.post(
      '/feedback',
      body: {
        'queue_id': queueId,
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    return Feedback.fromJson(response['feedback']);
  }

  // Get user's feedback history
  Future<List<Feedback>> getUserFeedbackHistory({int page = 1}) async {
    final response = await _api.get('/feedback/history?page=$page');
    return (response['data'] as List)
        .map((feedback) => Feedback.fromJson(feedback))
        .toList();
  }

  // Get feedback statistics (for admin/petugas)
  Future<Map<String, dynamic>> getFeedbackStatistics() async {
    final response = await _api.get('/feedback/statistics');
    return {
      'overall_rating': response['overall_rating'],
      'this_month': {
        'average_rating': response['this_month']['average_rating'],
        'total_feedbacks': response['this_month']['total_feedbacks'],
        'rating_distribution': response['this_month']['rating_distribution'],
      },
      'last_month': {
        'average_rating': response['last_month']['average_rating'],
        'total_feedbacks': response['last_month']['total_feedbacks'],
        'rating_distribution': response['last_month']['rating_distribution'],
      },
    };
  }

  // Get recent feedbacks (for admin/petugas)
  Future<List<Feedback>> getRecentFeedbacks({int page = 1}) async {
    final response = await _api.get('/feedback/recent?page=$page');
    return (response['data'] as List)
        .map((feedback) => Feedback.fromJson(feedback))
        .toList();
  }

  // Update feedback (admin response)
  Future<Feedback> updateFeedback({
    required int feedbackId,
    required String adminResponse,
  }) async {
    final response = await _api.put(
      '/feedback/$feedbackId',
      body: {'admin_response': adminResponse},
    );
    return Feedback.fromJson(response['feedback']);
  }

  // Delete feedback (admin only)
  Future<void> deleteFeedback(int feedbackId) async {
    await _api.delete('/feedback/$feedbackId');
  }

  // Get feedback details
  Future<Feedback> getFeedbackDetails(int feedbackId) async {
    final response = await _api.get('/feedback/$feedbackId');
    return Feedback.fromJson(response['feedback']);
  }

  // Get feedback summary by date range (for admin/petugas)
  Future<Map<String, dynamic>> getFeedbackSummary({
    required String startDate,
    required String endDate,
  }) async {
    final response = await _api.get(
      '/feedback/summary?start_date=$startDate&end_date=$endDate',
    );
    return {
      'average_rating': response['average_rating'],
      'total_feedbacks': response['total_feedbacks'],
      'rating_distribution': response['rating_distribution'],
      'common_comments': response['common_comments'],
      'response_rate': response['response_rate'],
    };
  }

  // Check if user can submit feedback for a queue
  Future<bool> canSubmitFeedback(int queueId) async {
    try {
      final response = await _api.get('/feedback/can-submit/$queueId');
      return response['can_submit'] ?? false;
    } on ApiException {
      return false;
    }
  }

  // Get pending feedbacks that need admin response
  Future<List<Feedback>> getPendingFeedbacks({int page = 1}) async {
    final response = await _api.get('/feedback/pending?page=$page');
    return (response['data'] as List)
        .map((feedback) => Feedback.fromJson(feedback))
        .toList();
  }

  // Get feedback trends (for admin/petugas)
  Future<Map<String, dynamic>> getFeedbackTrends({
    required String period, // 'daily', 'weekly', 'monthly'
    int? limit,
  }) async {
    final response = await _api.get(
      '/feedback/trends?period=$period${limit != null ? '&limit=$limit' : ''}',
    );
    return {
      'trends': response['trends'],
      'improvement_areas': response['improvement_areas'],
      'positive_aspects': response['positive_aspects'],
    };
  }

  // Export feedback data (for admin/petugas)
  Future<String> exportFeedbackData({
    required String format, // 'csv', 'excel'
    String? startDate,
    String? endDate,
  }) async {
    final response = await _api.get(
      '/feedback/export?format=$format'
      '${startDate != null ? '&start_date=$startDate' : ''}'
      '${endDate != null ? '&end_date=$endDate' : ''}',
    );
    return response['download_url'];
  }
}
