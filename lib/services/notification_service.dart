import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final String _collection = 'notifications';
  final Uuid _uuid = const Uuid();

  // Initialize notifications
  Future<void> initialize() async {
    // Request permission for notifications
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Create notification
  Future<NotificationModel?> createNotification(NotificationModel notification) async {
    try {
      final notificationId = _uuid.v4();
      final newNotification = notification.copyWith(
        id: notificationId,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection(_collection)
          .doc(notificationId)
          .set(newNotification.toJson());

      return newNotification;
    } catch (e) {
      throw 'Failed to create notification: $e';
    }
  }

  // Get notifications for a user
  Future<List<NotificationModel>> getUserNotifications(String userId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .orderBy('created_at', descending: true)
          .limit(50)
          .get();

      return query.docs
          .map((doc) => NotificationModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get user notifications: $e';
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'is_read': true,
      });
      return true;
    } catch (e) {
      throw 'Failed to mark notification as read: $e';
    }
  }

  // Mark all notifications as read for a user
  Future<bool> markAllAsRead(String userId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.update(doc.reference, {'is_read': true});
      }

      await batch.commit();
      return true;
    } catch (e) {
      throw 'Failed to mark all notifications as read: $e';
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
      return true;
    } catch (e) {
      throw 'Failed to delete notification: $e';
    }
  }

  // Clear all notifications for a user
  Future<bool> clearAllNotifications(String userId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      return true;
    } catch (e) {
      throw 'Failed to clear all notifications: $e';
    }
  }

  // Send notification to user
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? eventId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = NotificationModel(
        id: _uuid.v4(),
        title: title,
        body: body,
        type: type,
        userId: userId,
        eventId: eventId,
        data: data,
        createdAt: DateTime.now(),
      );

      await createNotification(notification);
    } catch (e) {
      print('Error sending notification to user: $e');
    }
  }

  // Send notification to multiple users
  Future<void> sendNotificationToUsers({
    required List<String> userIds,
    required String title,
    required String body,
    required String type,
    String? eventId,
    Map<String, dynamic>? data,
  }) async {
    try {
      final batch = _firestore.batch();

      for (String userId in userIds) {
        final notificationId = _uuid.v4();
        final notification = NotificationModel(
          id: notificationId,
          title: title,
          body: body,
          type: type,
          userId: userId,
          eventId: eventId,
          data: data,
          createdAt: DateTime.now(),
        );

        final docRef = _firestore.collection(_collection).doc(notificationId);
        batch.set(docRef, notification.toJson());
      }

      await batch.commit();
    } catch (e) {
      print('Error sending notifications to users: $e');
    }
  }

  // Send event reminder notifications
  Future<void> sendEventReminder({
    required String eventId,
    required String eventTitle,
    required List<String> registeredUsers,
    required DateTime eventDateTime,
  }) async {
    final title = 'Event Reminder';
    final body = 'Don\'t forget! "$eventTitle" starts in 1 hour.';

    await sendNotificationToUsers(
      userIds: registeredUsers,
      title: title,
      body: body,
      type: NotificationTypes.eventReminder,
      eventId: eventId,
      data: {
        'event_title': eventTitle,
        'event_date_time': eventDateTime.toIso8601String(),
      },
    );
  }

  // Send event update notifications
  Future<void> sendEventUpdate({
    required String eventId,
    required String eventTitle,
    required List<String> registeredUsers,
    required String updateMessage,
  }) async {
    final title = 'Event Update';
    final body = 'Update for "$eventTitle": $updateMessage';

    await sendNotificationToUsers(
      userIds: registeredUsers,
      title: title,
      body: body,
      type: NotificationTypes.eventUpdate,
      eventId: eventId,
      data: {
        'event_title': eventTitle,
        'update_message': updateMessage,
      },
    );
  }

  // Send registration confirmation
  Future<void> sendRegistrationConfirmation({
    required String userId,
    required String eventId,
    required String eventTitle,
    required DateTime eventDateTime,
  }) async {
    final title = 'Registration Confirmed';
    final body = 'You have successfully registered for "$eventTitle".';

    await sendNotificationToUser(
      userId: userId,
      title: title,
      body: body,
      type: NotificationTypes.registrationConfirmed,
      eventId: eventId,
      data: {
        'event_title': eventTitle,
        'event_date_time': eventDateTime.toIso8601String(),
      },
    );
  }

  // Get unread notification count for user
  Future<int> getUnreadCount(String userId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('user_id', isEqualTo: userId)
          .where('is_read', isEqualTo: false)
          .count()
          .get();

      return query.count ?? 0;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}