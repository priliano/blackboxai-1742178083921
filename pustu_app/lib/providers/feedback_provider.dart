import 'package:flutter/foundation.dart';
import '../models/feedback.dart';
import '../services/feedback_service.dart';
import '../services/notification_service.dart';

class FeedbackProvider with ChangeNotifier {
  final FeedbackService _feedbackService = FeedbackService();
  final NotificationService _notificationService = NotificationService();

  List<Feedback> _userFeedbacks = [];
  List<Feedback> _recentFeedbacks = [];
  Map<String, dynamic>? _statistics;
  bool _loading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMorePages = true;

  // Getters
  List<Feedback> get userFeedbacks => _userFeedbacks;
  List<Feedback> get recentFeedbacks => _recentFeedbacks;
  Map<String, dynamic>? get statistics => _statistics;
  bool get loading => _loading;
  String? get error => _error;
  bool get hasMorePages => _hasMorePages;

  Future<void> submitFeedback({
    required int queueId,
    required int rating,
    String? comment,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final feedback = await _feedbackService.submitFeedback(
        queueId: queueId,
        rating: rating,
        comment: comment,
      );

      _userFeedbacks.insert(0, feedback);

      // Show thank you notification
      await _notificationService.showNotification(
        title: 'Terima Kasih',
        body: 'Terima kasih atas penilaian Anda!',
        payload: 'feedback_submitted:${feedback.id}',
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

  Future<void> loadUserFeedbacks({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMorePages = true;
      }

      if (!_hasMorePages) return;

      _loading = true;
      if (refresh) {
        _userFeedbacks.clear();
      }
      notifyListeners();

      final feedbacks = await _feedbackService.getUserFeedbackHistory(
        page: _currentPage,
      );

      if (feedbacks.isEmpty) {
        _hasMorePages = false;
      } else {
        _userFeedbacks.addAll(feedbacks);
        _currentPage++;
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Admin/Petugas methods
  Future<void> loadRecentFeedbacks({bool refresh = false}) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMorePages = true;
      }

      if (!_hasMorePages) return;

      _loading = true;
      if (refresh) {
        _recentFeedbacks.clear();
      }
      notifyListeners();

      final feedbacks = await _feedbackService.getRecentFeedbacks(
        page: _currentPage,
      );

      if (feedbacks.isEmpty) {
        _hasMorePages = false;
      } else {
        _recentFeedbacks.addAll(feedbacks);
        _currentPage++;
      }

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFeedbackStatistics() async {
    try {
      _loading = true;
      notifyListeners();

      _statistics = await _feedbackService.getFeedbackStatistics();

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> respondToFeedback({
    required int feedbackId,
    required String response,
  }) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final updatedFeedback = await _feedbackService.updateFeedback(
        feedbackId: feedbackId,
        adminResponse: response,
      );

      // Update feedback in lists
      final recentIndex = _recentFeedbacks.indexWhere((f) => f.id == feedbackId);
      if (recentIndex != -1) {
        _recentFeedbacks[recentIndex] = updatedFeedback;
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

  Future<void> deleteFeedback(int feedbackId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _feedbackService.deleteFeedback(feedbackId);

      // Remove feedback from lists
      _recentFeedbacks.removeWhere((f) => f.id == feedbackId);
      _userFeedbacks.removeWhere((f) => f.id == feedbackId);

      _loading = false;
      notifyListeners();
    } catch (e) {
      _loading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> canSubmitFeedback(int queueId) async {
    try {
      return await _feedbackService.canSubmitFeedback(queueId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> getFeedbackTrends({
    required String period,
    int? limit,
  }) async {
    try {
      _loading = true;
      notifyListeners();

      final trends = await _feedbackService.getFeedbackTrends(
        period: period,
        limit: limit,
      );

      _loading = false;
      notifyListeners();

      return trends;
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

  void resetPagination() {
    _currentPage = 1;
    _hasMorePages = true;
  }
}
