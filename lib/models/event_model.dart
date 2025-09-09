class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String type; // online, offline, hybrid
  final String organizerId;
  final String organizerName;
  final String department;
  final String? college;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String? venue;
  final String? onlineLink;
  final String? imageUrl;
  final List<String> tags;
  final int maxParticipants;
  final int currentParticipants;
  final List<String> registeredUsers;
  final bool isRegistrationRequired;
  final bool isApprovalRequired;
  final DateTime? registrationDeadline;
  final String? requirements;
  final String? contactInfo;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.organizerId,
    required this.organizerName,
    required this.department,
    this.college,
    required this.startDateTime,
    required this.endDateTime,
    this.venue,
    this.onlineLink,
    this.imageUrl,
    this.tags = const [],
    this.maxParticipants = 0,
    this.currentParticipants = 0,
    this.registeredUsers = const [],
    this.isRegistrationRequired = true,
    this.isApprovalRequired = false,
    this.registrationDeadline,
    this.requirements,
    this.contactInfo,
    this.latitude,
    this.longitude,
    this.isActive = true,
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      type: json['type'] ?? 'offline',
      organizerId: json['organizer_id'] ?? '',
      organizerName: json['organizer_name'] ?? '',
      department: json['department'] ?? '',
      college: json['college'],
      startDateTime: DateTime.parse(json['start_date_time'] ?? DateTime.now().toIso8601String()),
      endDateTime: DateTime.parse(json['end_date_time'] ?? DateTime.now().toIso8601String()),
      venue: json['venue'],
      onlineLink: json['online_link'],
      imageUrl: json['image_url'],
      tags: List<String>.from(json['tags'] ?? []),
      maxParticipants: json['max_participants'] ?? 0,
      currentParticipants: json['current_participants'] ?? 0,
      registeredUsers: List<String>.from(json['registered_users'] ?? []),
      isRegistrationRequired: json['is_registration_required'] ?? true,
      isApprovalRequired: json['is_approval_required'] ?? false,
      registrationDeadline: json['registration_deadline'] != null
          ? DateTime.parse(json['registration_deadline'])
          : null,
      requirements: json['requirements'],
      contactInfo: json['contact_info'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isActive: json['is_active'] ?? true,
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'type': type,
      'organizer_id': organizerId,
      'organizer_name': organizerName,
      'department': department,
      'college': college,
      'start_date_time': startDateTime.toIso8601String(),
      'end_date_time': endDateTime.toIso8601String(),
      'venue': venue,
      'online_link': onlineLink,
      'image_url': imageUrl,
      'tags': tags,
      'max_participants': maxParticipants,
      'current_participants': currentParticipants,
      'registered_users': registeredUsers,
      'is_registration_required': isRegistrationRequired,
      'is_approval_required': isApprovalRequired,
      'registration_deadline': registrationDeadline?.toIso8601String(),
      'requirements': requirements,
      'contact_info': contactInfo,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? type,
    String? organizerId,
    String? organizerName,
    String? department,
    String? college,
    DateTime? startDateTime,
    DateTime? endDateTime,
    String? venue,
    String? onlineLink,
    String? imageUrl,
    List<String>? tags,
    int? maxParticipants,
    int? currentParticipants,
    List<String>? registeredUsers,
    bool? isRegistrationRequired,
    bool? isApprovalRequired,
    DateTime? registrationDeadline,
    String? requirements,
    String? contactInfo,
    double? latitude,
    double? longitude,
    bool? isActive,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      department: department ?? this.department,
      college: college ?? this.college,
      startDateTime: startDateTime ?? this.startDateTime,
      endDateTime: endDateTime ?? this.endDateTime,
      venue: venue ?? this.venue,
      onlineLink: onlineLink ?? this.onlineLink,
      imageUrl: imageUrl ?? this.imageUrl,
      tags: tags ?? this.tags,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      currentParticipants: currentParticipants ?? this.currentParticipants,
      registeredUsers: registeredUsers ?? this.registeredUsers,
      isRegistrationRequired: isRegistrationRequired ?? this.isRegistrationRequired,
      isApprovalRequired: isApprovalRequired ?? this.isApprovalRequired,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      requirements: requirements ?? this.requirements,
      contactInfo: contactInfo ?? this.contactInfo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDateTime) && now.isBefore(endDateTime);
  }

  bool get isUpcoming {
    final now = DateTime.now();
    return now.isBefore(startDateTime);
  }

  bool get isPast {
    final now = DateTime.now();
    return now.isAfter(endDateTime);
  }

  bool get canRegister {
    if (!isRegistrationRequired) return false;
    if (isPast) return false;
    if (registrationDeadline != null && DateTime.now().isAfter(registrationDeadline!)) return false;
    if (maxParticipants > 0 && currentParticipants >= maxParticipants) return false;
    return true;
  }

  String get statusText {
    if (isPast) return 'Completed';
    if (isOngoing) return 'Ongoing';
    if (isUpcoming) return 'Upcoming';
    return 'Unknown';
  }

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, category: $category, startDateTime: $startDateTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}