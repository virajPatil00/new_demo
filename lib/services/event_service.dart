import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'events';
  final Uuid _uuid = const Uuid();

  // Create a new event
  Future<EventModel?> createEvent(EventModel event) async {
    try {
      final eventId = _uuid.v4();
      final newEvent = event.copyWith(
        id: eventId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore.collection(_collection).doc(eventId).set(newEvent.toJson());
      return newEvent;
    } catch (e) {
      throw 'Failed to create event: $e';
    }
  }

  // Get event by ID
  Future<EventModel?> getEventById(String eventId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(eventId).get();
      if (doc.exists && doc.data() != null) {
        return EventModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to get event: $e';
    }
  }

  // Update event
  Future<EventModel?> updateEvent(EventModel event) async {
    try {
      final updatedEvent = event.copyWith(updatedAt: DateTime.now());
      await _firestore.collection(_collection).doc(event.id).update(updatedEvent.toJson());
      return updatedEvent;
    } catch (e) {
      throw 'Failed to update event: $e';
    }
  }

  // Delete event
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
      return true;
    } catch (e) {
      throw 'Failed to delete event: $e';
    }
  }

  // Get all events
  Future<List<EventModel>> getAllEvents() async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('is_active', isEqualTo: true)
          .orderBy('start_date_time')
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get all events: $e';
    }
  }

  // Get featured events
  Future<List<EventModel>> getFeaturedEvents() async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('is_featured', isEqualTo: true)
          .where('is_active', isEqualTo: true)
          .orderBy('start_date_time')
          .limit(10)
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get featured events: $e';
    }
  }

  // Get events by organizer
  Future<List<EventModel>> getEventsByOrganizer(String organizerId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('organizer_id', isEqualTo: organizerId)
          .orderBy('created_at', descending: true)
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get events by organizer: $e';
    }
  }

  // Get events by category
  Future<List<EventModel>> getEventsByCategory(String category) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('category', isEqualTo: category)
          .where('is_active', isEqualTo: true)
          .orderBy('start_date_time')
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get events by category: $e';
    }
  }

  // Get events by department
  Future<List<EventModel>> getEventsByDepartment(String department) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('department', isEqualTo: department)
          .where('is_active', isEqualTo: true)
          .orderBy('start_date_time')
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get events by department: $e';
    }
  }

  // Get upcoming events
  Future<List<EventModel>> getUpcomingEvents() async {
    try {
      final now = DateTime.now();
      final query = await _firestore
          .collection(_collection)
          .where('start_date_time', isGreaterThan: now.toIso8601String())
          .where('is_active', isEqualTo: true)
          .orderBy('start_date_time')
          .limit(20)
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get upcoming events: $e';
    }
  }

  // Get ongoing events
  Future<List<EventModel>> getOngoingEvents() async {
    try {
      final now = DateTime.now();
      final query = await _firestore
          .collection(_collection)
          .where('start_date_time', isLessThan: now.toIso8601String())
          .where('end_date_time', isGreaterThan: now.toIso8601String())
          .where('is_active', isEqualTo: true)
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get ongoing events: $e';
    }
  }

  // Get registered events for a user
  Future<List<EventModel>> getRegisteredEvents(String userId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('registered_users', arrayContains: userId)
          .orderBy('start_date_time')
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get registered events: $e';
    }
  }

  // Get events by IDs (for bookmarked events)
  Future<List<EventModel>> getEventsByIds(List<String> eventIds) async {
    try {
      if (eventIds.isEmpty) {
        return [];
      }

      // Firestore 'in' queries are limited to 10 items
      final List<EventModel> events = [];
      for (int i = 0; i < eventIds.length; i += 10) {
        final batch = eventIds.skip(i).take(10).toList();
        final query = await _firestore
            .collection(_collection)
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        events.addAll(
          query.docs.map((doc) => EventModel.fromJson(doc.data())).toList(),
        );
      }

      return events;
    } catch (e) {
      throw 'Failed to get events by IDs: $e';
    }
  }

  // Register for event
  Future<bool> registerForEvent(String eventId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'registered_users': FieldValue.arrayUnion([userId]),
        'current_participants': FieldValue.increment(1),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw 'Failed to register for event: $e';
    }
  }

  // Unregister from event
  Future<bool> unregisterFromEvent(String eventId, String userId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'registered_users': FieldValue.arrayRemove([userId]),
        'current_participants': FieldValue.increment(-1),
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw 'Failed to unregister from event: $e';
    }
  }

  // Search events
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      final titleQuery = await _firestore
          .collection(_collection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThan:'$query\uf8ff')
          .where('is_active', isEqualTo: true)
          .limit(20)
          .get();

      final descriptionQuery = await _firestore
          .collection(_collection)
          .where('description', isGreaterThanOrEqualTo: query)
          .where('description', isLessThan: '$query\uf8ff')
          .where('is_active', isEqualTo: true)
          .limit(20)
          .get();

      final Set<String> eventIds = {};
      final List<EventModel> events = [];

      // Add events from title query
      for (final doc in titleQuery.docs) {
        if (!eventIds.contains(doc.id)) {
          events.add(EventModel.fromJson(doc.data()));
          eventIds.add(doc.id);
        }
      }

      // Add events from description query
      for (final doc in descriptionQuery.docs) {
        if (!eventIds.contains(doc.id)) {
          events.add(EventModel.fromJson(doc.data()));
          eventIds.add(doc.id);
        }
      }

      return events;
    } catch (e) {
      throw 'Failed to search events: $e';
    }
  }

  // Get events by date range
  Future<List<EventModel>> getEventsByDateRange(
      DateTime startDate,
      DateTime endDate,
      ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('start_date_time', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('start_date_time', isLessThanOrEqualTo: endDate.toIso8601String())
          .where('is_active', isEqualTo: true)
          .orderBy('start_date_time')
          .get();

      return query.docs
          .map((doc) => EventModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw 'Failed to get events by date range: $e';
    }
  }

  // Get events count by organizer
  Future<int> getEventsCountByOrganizer(String organizerId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('organizer_id', isEqualTo: organizerId)
          .count()
          .get();

      return query.count ?? 0;
    } catch (e) {
      throw 'Failed to get events count: $e';
    }
  }

  // Toggle event featured status (admin only)
  Future<bool> toggleEventFeatured(String eventId, bool featured) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'is_featured': featured,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw 'Failed to toggle event featured status: $e';
    }
  }

  // Toggle event active status (admin only)
  Future<bool> toggleEventActive(String eventId, bool active) async {
    try {
      await _firestore.collection(_collection).doc(eventId).update({
        'is_active': active,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      throw 'Failed to toggle event active status: $e';
    }
  }
}