class AppConstants {
  // App Info
  static const String appName = 'Campus Connect';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'A mobile-based centralized event aggregator for college communities';

  // API Configuration
  static const String baseUrl = 'https://api.campusconnect.com/v1';
  static const String apiKey = 'your_api_key_here';

  // Firebase Configuration
  static const String firebaseProjectId = 'campus-connect-app';

  // SharedPreferences Keys
  static const String userTokenKey = 'user_token';
  static const String userIdKey = 'user_id';
  static const String userEmailKey = 'user_email';
  static const String isFirstLaunchKey = 'is_first_launch';
  static const String themeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';

  // Event Categories
  static const List<String> eventCategories = [
    'Academic',
    'Cultural',
    'Sports',
    'Workshop',
    'Seminar',
    'Hackathon',
    'Conference',
    'Social',
    'Career',
    'Technology',
    'Arts',
    'Music',
    'Dance',
    'Drama',
    'Competition',
    'Festival',
    'Guest Lecture',
    'Webinar',
    'Club Meeting',
    'Other',
  ];

  // Event Types
  static const List<String> eventTypes = [
    'Online',
    'Offline',
    'Hybrid',
  ];

  // Departments
  static const List<String> departments = [
    'Computer Science',
    'Information Technology',
    'Electronics & Communication',
    'Mechanical Engineering',
    'Civil Engineering',
    'Electrical Engineering',
    'Chemical Engineering',
    'Biotechnology',
    'Mathematics',
    'Physics',
    'Chemistry',
    'Biology',
    'Business Administration',
    'Commerce',
    'Economics',
    'Psychology',
    'Sociology',
    'English Literature',
    'Arts & Humanities',
    'General',
  ];

  // User Roles
  static const String studentRole = 'student';
  static const String organizerRole = 'organizer';
  static const String adminRole = 'admin';

  // Pagination
  static const int defaultPageSize = 10;
  static const int maxPageSize = 50;

  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Date Formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'dd MMM yyyy, hh:mm a';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxEventTitleLength = 100;
  static const int maxEventDescriptionLength = 1000;

  // Network
  static const int connectionTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);

  // Spacing
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 16.0;
  static const double largeSpacing = 24.0;
  static const double extraLargeSpacing = 32.0;

  // Border Radius
  static const double smallBorderRadius = 4.0;
  static const double mediumBorderRadius = 8.0;
  static const double largeBorderRadius = 12.0;
  static const double extraLargeBorderRadius = 16.0;

  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String authErrorMessage = 'Authentication failed. Please login again.';
  static const String permissionErrorMessage = 'Permission denied. Please grant necessary permissions.';

  // Success Messages
  static const String eventCreatedMessage = 'Event created successfully!';
  static const String eventUpdatedMessage = 'Event updated successfully!';
  static const String eventDeletedMessage = 'Event deleted successfully!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String registrationSuccessMessage = 'Registration successful!';
}