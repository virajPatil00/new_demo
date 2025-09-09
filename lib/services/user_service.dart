import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Create a new user
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(user.toJson());
    } catch (e) {
      throw 'Failed to create user: $e';
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).update(
        user.copyWith(updatedAt: DateTime.now()).toJson(),
      );
    } catch (e) {
      throw 'Failed to update user: $e';
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).delete();
    } catch (e) {
      throw 'Failed to delete user: $e';
    }
  }

  // Get user by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        return UserModel.fromJson(query.docs.first.data());
      }
      return null;
    } catch (e) {
      throw 'Failed to get user by email: $e';
    }
  }

  // Update user interests
  Future<void> updateUserInterests(String userId, List<String> interests) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'interests': interests,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to update user interests: $e';
    }
  }

  // Add bookmarked event
  Future<void> addBookmarkedEvent(String userId, String eventId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'bookmarked_events': FieldValue.arrayUnion([eventId]),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to add bookmarked event: $e';
    }
  }

  // Remove bookmarked event
  Future<void> removeBookmarkedEvent(String userId, String eventId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'bookmarked_events': FieldValue.arrayRemove([eventId]),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to remove bookmarked event: $e';
    }
  }

  // Add registered event
  Future<void> addRegisteredEvent(String userId, String eventId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'registered_events': FieldValue.arrayUnion([eventId]),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to add registered event: $e';
    }
  }

  // Remove registered event
  Future<void> removeRegisteredEvent(String userId, String eventId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'registered_events': FieldValue.arrayRemove([eventId]),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to remove registered event: $e';
    }
  }

  // Update notification settings
  Future<void> updateNotificationSettings(String userId, bool enabled) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'notifications_enabled': enabled,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to update notification settings: $e';
    }
  }

  // Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final nameQuery = await _firestore
          .collection(_collection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + '\uf8ff')
          .limit(20)
          .get();

      final emailQuery = await _firestore
          .collection(_collection)
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + '\uf8ff')
          .limit(20)
          .get();

      final Set<String> userIds = {};
      final List<UserModel> users = [];

      // Add users from name query
      for (var doc in nameQuery.docs) {
        if (!userIds.contains(doc.id)) {
          users.add(UserModel.fromJson(doc.data()));
          userIds.add(doc.id);
        }
      }

      // Add users from email query
      for (var doc in emailQuery.docs) {
        if (!userIds.contains(doc.id)) {
          users.add(UserModel.fromJson(doc.data()));
          userIds.add(doc.id);
        }
      }

      return users;
    } catch (e) {
      throw 'Failed to search users: $e';
    }
  }

  // Get users by department
  Future<List<UserModel>> getUsersByDepartment(String department) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('department', isEqualTo: department)
          .get();

      return query.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get users by department: $e';
    }
  }

  // Get users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: role)
          .get();

      return query.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get users by role: $e';
    }
  }

  // Get event organizers
  Future<List<UserModel>> getEventOrganizers() async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('role', whereIn: ['organizer', 'admin'])
          .get();

      return query.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get event organizers: $e';
    }
  }

  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final query = await _firestore.collection(_collection).get();

      return query.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get all users: $e';
    }
  }

  // Update user role (admin only)
  Future<void> updateUserRole(String userId, String role) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'role': role,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw 'Failed to update user role: $e';
    }
  }
}