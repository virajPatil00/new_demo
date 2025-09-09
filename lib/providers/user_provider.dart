import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../services/user_service.dart';
import '../services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // User operations
  Future<UserModel?> getUserById(String userId) async {
    try {
      return await _userService.getUserById(userId);
    } catch (e) {
      setError('Failed to load user: $e');
      return null;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      setLoading(true);
      setError(null);

      await _userService.updateUser(user);
      setLoading(false);
      return true;
    } catch (e) {
      setError('Failed to update user: $e');
      setLoading(false);
      return false;
    }
  }

  Future<bool> updateUserInterests(String userId, List<String> interests) async {
    try {
      await _userService.updateUserInterests(userId, interests);
      return true;
    } catch (e) {
      setError('Failed to update interests: $e');
      return false;
    }
  }

  Future<bool> addBookmarkedEvent(String userId, String eventId) async {
    try {
      await _userService.addBookmarkedEvent(userId, eventId);
      return true;
    } catch (e) {
      setError('Failed to bookmark event: $e');
      return false;
    }
  }

  Future<bool> removeBookmarkedEvent(String userId, String eventId) async {
    try {
      await _userService.removeBookmarkedEvent(userId, eventId);
      return true;
    } catch (e) {
      setError('Failed to remove bookmark: $e');
      return false;
    }
  }

  Future<bool> updateNotificationSettings(String userId, bool enabled) async {
    try {
      await _userService.updateNotificationSettings(userId, enabled);
      return true;
    } catch (e) {
      setError('Failed to update notification settings: $e');
      return false;
    }
  }

  // Notification operations
  Future<void> loadNotifications(String userId) async {
    try {
      setLoading(true);
      setError(null);

      _notifications = await _notificationService.getUserNotifications(userId);
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      setError('Failed to load notifications: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      setError('Failed to mark notification as read: $e');
      return false;
    }
  }

  Future<bool> markAllNotificationsAsRead(String userId) async {
    try {
      final success = await _notificationService.markAllAsRead(userId);
      if (success) {
        for (int i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('Failed to mark all notifications as read: $e');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('Failed to delete notification: $e');
      return false;
    }
  }

  Future<bool> clearAllNotifications(String userId) async {
    try {
      final success = await _notificationService.clearAllNotifications(userId);
      if (success) {
        _notifications.clear();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('Failed to clear notifications: $e');
      return false;
    }
  }

  // Add a new notification (for real-time updates)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Search users (for admin features)
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      return await _userService.searchUsers(query);
    } catch (e) {
      setError('Failed to search users: $e');
      return [];
    }
  }

  // Get users by department
  Future<List<UserModel>> getUsersByDepartment(String department) async {
    try {
      return await _userService.getUsersByDepartment(department);
    } catch (e) {
      setError('Failed to load users by department: $e');
      return [];
    }
  }

  // Get event organizers
  Future<List<UserModel>> getEventOrganizers() async {
    try {
      return await _userService.getEventOrganizers();
    } catch (e) {
      setError('Failed to load organizers: $e');
      return [];
    }
  }
}