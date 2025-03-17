import 'package:intl/intl.dart';
import 'user.dart';
import 'queue.dart';

class Feedback {
  final int id;
  final int userId;
  final int queueId;
  final int rating;
  final String? comment;
  final String? adminResponse;
  final DateTime? respondedAt;
  final DateTime createdAt;
  final User? user;
  final Queue? queue;

  Feedback({
    required this.id,
    required this.userId,
    required this.queueId,
    required this.rating,
    this.comment,
    this.adminResponse,
    this.respondedAt,
    required this.createdAt,
    this.user,
    this.queue,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      userId: json['user_id'],
      queueId: json['queue_id'],
      rating: json['rating'],
      comment: json['comment'],
      adminResponse: json['admin_response'],
      respondedAt: json['responded_at'] != null 
          ? DateTime.parse(json['responded_at']) 
          : null,
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      queue: json['queue'] != null ? Queue.fromJson(json['queue']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'queue_id': queueId,
      'rating': rating,
      'comment': comment,
      'admin_response': adminResponse,
      'responded_at': respondedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'user': user?.toJson(),
      'queue': queue?.toJson(),
    };
  }

  String get formattedCreatedAt => 
      DateFormat('dd MMM yyyy, HH:mm').format(createdAt);

  String get formattedRespondedAt => respondedAt != null 
      ? DateFormat('dd MMM yyyy, HH:mm').format(respondedAt!)
      : '-';

  String get ratingText {
    switch (rating) {
      case 1:
        return 'Sangat Tidak Puas';
      case 2:
        return 'Tidak Puas';
      case 3:
        return 'Cukup';
      case 4:
        return 'Puas';
      case 5:
        return 'Sangat Puas';
      default:
        return 'Tidak Valid';
    }
  }

  bool get hasResponse => adminResponse != null && adminResponse!.isNotEmpty;

  Feedback copyWith({
    int? id,
    int? userId,
    int? queueId,
    int? rating,
    String? comment,
    String? adminResponse,
    DateTime? respondedAt,
    DateTime? createdAt,
    User? user,
    Queue? queue,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      queueId: queueId ?? this.queueId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      adminResponse: adminResponse ?? this.adminResponse,
      respondedAt: respondedAt ?? this.respondedAt,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      queue: queue ?? this.queue,
    );
  }

  // Helper method to create feedback request body
  Map<String, dynamic> toRequestBody() {
    return {
      'queue_id': queueId,
      'rating': rating,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
    };
  }

  // Helper method to create admin response request body
  Map<String, dynamic> toAdminResponseBody() {
    return {
      'admin_response': adminResponse,
    };
  }
}
