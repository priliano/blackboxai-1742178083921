import 'package:intl/intl.dart';
import 'user.dart';

class Queue {
  final int id;
  final int userId;
  final int queueNumber;
  final String status;
  final DateTime arrivalTime;
  final DateTime? calledAt;
  final int estimatedWait;
  final DateTime createdAt;
  final User? user;

  Queue({
    required this.id,
    required this.userId,
    required this.queueNumber,
    required this.status,
    required this.arrivalTime,
    this.calledAt,
    required this.estimatedWait,
    required this.createdAt,
    this.user,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    return Queue(
      id: json['id'],
      userId: json['user_id'],
      queueNumber: json['queue_number'],
      status: json['status'],
      arrivalTime: DateTime.parse(json['arrival_time']),
      calledAt: json['called_at'] != null ? DateTime.parse(json['called_at']) : null,
      estimatedWait: json['estimated_wait'],
      createdAt: DateTime.parse(json['created_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'queue_number': queueNumber,
      'status': status,
      'arrival_time': arrivalTime.toIso8601String(),
      'called_at': calledAt?.toIso8601String(),
      'estimated_wait': estimatedWait,
      'created_at': createdAt.toIso8601String(),
      'user': user?.toJson(),
    };
  }

  bool get isWaiting => status == 'waiting';
  bool get isCalled => status == 'called';
  bool get isCompleted => status == 'completed';

  String get formattedArrivalTime => 
      DateFormat('HH:mm, dd MMM yyyy').format(arrivalTime);

  String get formattedCalledTime => calledAt != null 
      ? DateFormat('HH:mm, dd MMM yyyy').format(calledAt!)
      : '-';

  String get estimatedWaitText {
    if (estimatedWait < 60) {
      return '$estimatedWait menit';
    }
    final hours = estimatedWait ~/ 60;
    final minutes = estimatedWait % 60;
    if (minutes == 0) {
      return '$hours jam';
    }
    return '$hours jam $minutes menit';
  }

  String get statusText {
    switch (status) {
      case 'waiting':
        return 'Menunggu';
      case 'called':
        return 'Dipanggil';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Queue copyWith({
    int? id,
    int? userId,
    int? queueNumber,
    String? status,
    DateTime? arrivalTime,
    DateTime? calledAt,
    int? estimatedWait,
    DateTime? createdAt,
    User? user,
  }) {
    return Queue(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      calledAt: calledAt ?? this.calledAt,
      estimatedWait: estimatedWait ?? this.estimatedWait,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }
}
