class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImage;
  final String role; // student, organizer, admin
  final String department;
  final String? college;
  final String? phone;
  final String? bio;
  final List<String> interests;
  final List<String> registeredEvents;
  final List<String> bookmarkedEvents;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImage,
    required this.role,
    required this.department,
    this.college,
    this.phone,
    this.bio,
    this.interests = const [],
    this.registeredEvents = const [],
    this.bookmarkedEvents = const [],
    this.notificationsEnabled = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      profileImage: json['profile_image'],
      role: json['role'] ?? 'student',
      department: json['department'] ?? '',
      college: json['college'],
      phone: json['phone'],
      bio: json['bio'],
      interests: List<String>.from(json['interests'] ?? []),
      registeredEvents: List<String>.from(json['registered_events'] ?? []),
      bookmarkedEvents: List<String>.from(json['bookmarked_events'] ?? []),
      notificationsEnabled: json['notifications_enabled'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profile_image': profileImage,
      'role': role,
      'department': department,
      'college': college,
      'phone': phone,
      'bio': bio,
      'interests': interests,
      'registered_events': registeredEvents,
      'bookmarked_events': bookmarkedEvents,
      'notifications_enabled': notificationsEnabled,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImage,
    String? role,
    String? department,
    String? college,
    String? phone,
    String? bio,
    List<String>? interests,
    List<String>? registeredEvents,
    List<String>? bookmarkedEvents,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      department: department ?? this.department,
      college: college ?? this.college,
      phone: phone ?? this.phone,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      registeredEvents: registeredEvents ?? this.registeredEvents,
      bookmarkedEvents: bookmarkedEvents ?? this.bookmarkedEvents,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, role: $role, department: $department)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}