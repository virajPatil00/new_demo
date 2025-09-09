class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type; // event_reminder, event_update, registration_confirmed, etc.
  final String? eventId;
  final String? userId;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? scheduledAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.eventId,
    this.userId,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.scheduledAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      type: json['type'] ?? '',
      eventId: json['event_id'],
      userId: json['user_id'],
      data: json['data'],
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'event_id': eventId,
      'user_id': userId,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'scheduled_at': scheduledAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? type,
    String? eventId,
    String? userId,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? scheduledAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      eventId: eventId ?? this.eventId,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
    );
  }

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $type, isRead: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Notification types
class NotificationTypes {
  static const String eventReminder = 'event_reminder';
  static const String eventUpdate = 'event_update';
  static const String eventCancelled = 'event_cancelled';
  static const String registrationConfirmed = 'registration_confirmed';
  static const String registrationApproved = 'registration_approved';
  static const String registrationRejected = 'registration_rejected';
  static const String newEventPosted = 'new_event_posted';
  static const String eventStarting = 'event_starting';
  static const String eventEnding = 'event_ending';
  static const String general = 'general';
}