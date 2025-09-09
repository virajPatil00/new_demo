import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../services/event_service.dart';
import '../core/constants/app_constants.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<EventModel> _events = [];
  List<EventModel> _featuredEvents = [];
  List<EventModel> _myEvents = [];
  List<EventModel> _registeredEvents = [];
  List<EventModel> _bookmarkedEvents = [];

  EventModel? _selectedEvent;
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  // Filter and search states
  String _searchQuery = '';
  String _selectedCategory = '';
  String _selectedDepartment = '';
  String _selectedType = '';
  DateTime? _startDate;
  DateTime? _endDate;

  // Getters
  List<EventModel> get events => _events;
  List<EventModel> get featuredEvents => _featuredEvents;
  List<EventModel> get myEvents => _myEvents;
  List<EventModel> get registeredEvents => _registeredEvents;
  List<EventModel> get bookmarkedEvents => _bookmarkedEvents;
  EventModel? get selectedEvent => _selectedEvent;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;
  String get selectedDepartment => _selectedDepartment;
  String get selectedType => _selectedType;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  List<EventModel> get filteredEvents {
    List<EventModel> filtered = List.from(_events);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) =>
      event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.organizerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
      ).toList();
    }

    // Apply category filter
    if (_selectedCategory.isNotEmpty) {
      filtered = filtered.where((event) => event.category == _selectedCategory).toList();
    }

    // Apply department filter
    if (_selectedDepartment.isNotEmpty) {
      filtered = filtered.where((event) => event.department == _selectedDepartment).toList();
    }

    // Apply type filter
    if (_selectedType.isNotEmpty) {
      filtered = filtered.where((event) => event.type == _selectedType).toList();
    }

    // Apply date range filter
    if (_startDate != null) {
      filtered = filtered.where((event) => event.startDateTime.isAfter(_startDate!)).toList();
    }
    if (_endDate != null) {
      filtered = filtered.where((event) => event.endDateTime.isBefore(_endDate!)).toList();
    }

    // Sort by start date
    filtered.sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    return filtered;
  }

  List<EventModel> get upcomingEvents {
    final now = DateTime.now();
    return _events.where((event) => event.startDateTime.isAfter(now)).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));
  }

  List<EventModel> get ongoingEvents {
    final now = DateTime.now();
    return _events.where((event) =>
    event.startDateTime.isBefore(now) && event.endDateTime.isAfter(now)
    ).toList();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCreating(bool creating) {
    _isCreating = creating;
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

  // Search and filter methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedDepartment(String department) {
    _selectedDepartment = department;
    notifyListeners();
  }

  void setSelectedType(String type) {
    _selectedType = type;
    notifyListeners();
  }

  void setDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = '';
    _selectedDepartment = '';
    _selectedType = '';
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  // Event operations
  Future<void> loadEvents() async {
    try {
      setLoading(true);
      setError(null);

      _events = await _eventService.getAllEvents();
      notifyListeners();
    } catch (e) {
      setError('Failed to load events: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadFeaturedEvents() async {
    try {
      _featuredEvents = await _eventService.getFeaturedEvents();
      notifyListeners();
    } catch (e) {
      setError('Failed to load featured events: $e');
    }
  }

  Future<void> loadMyEvents(String userId) async {
    try {
      _myEvents = await _eventService.getEventsByOrganizer(userId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load my events: $e');
    }
  }

  Future<void> loadRegisteredEvents(String userId) async {
    try {
      _registeredEvents = await _eventService.getRegisteredEvents(userId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load registered events: $e');
    }
  }

  Future<void> loadBookmarkedEvents(List<String> eventIds) async {
    try {
      _bookmarkedEvents = await _eventService.getEventsByIds(eventIds);
      notifyListeners();
    } catch (e) {
      setError('Failed to load bookmarked events: $e');
    }
  }

  Future<void> loadEventById(String eventId) async {
    try {
      setLoading(true);
      _selectedEvent = await _eventService.getEventById(eventId);
      notifyListeners();
    } catch (e) {
      setError('Failed to load event: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<bool> createEvent(EventModel event) async {
    try {
      setCreating(true);
      setError(null);

      final createdEvent = await _eventService.createEvent(event);
      if (createdEvent != null) {
        _events.insert(0, createdEvent);
        _myEvents.insert(0, createdEvent);
        notifyListeners();
        return true;
      }

      setError('Failed to create event');
      return false;
    } catch (e) {
      setError('Failed to create event: $e');
      return false;
    } finally {
      setCreating(false);
    }
  }

  Future<bool> updateEvent(EventModel event) async {
    try {
      setLoading(true);
      setError(null);

      final updatedEvent = await _eventService.updateEvent(event);
      if (updatedEvent != null) {
        final index = _events.indexWhere((e) => e.id == event.id);
        if (index != -1) {
          _events[index] = updatedEvent;
        }

        final myIndex = _myEvents.indexWhere((e) => e.id == event.id);
        if (myIndex != -1) {
          _myEvents[myIndex] = updatedEvent;
        }

        if (_selectedEvent?.id == event.id) {
          _selectedEvent = updatedEvent;
        }

        notifyListeners();
        return true;
      }

      setError('Failed to update event');
      return false;
    } catch (e) {
      setError('Failed to update event: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> deleteEvent(String eventId) async {
    try {
      setLoading(true);
      setError(null);

      final success = await _eventService.deleteEvent(eventId);
      if (success) {
        _events.removeWhere((e) => e.id == eventId);
        _myEvents.removeWhere((e) => e.id == eventId);
        _featuredEvents.removeWhere((e) => e.id == eventId);
        _registeredEvents.removeWhere((e) => e.id == eventId);
        _bookmarkedEvents.removeWhere((e) => e.id == eventId);

        if (_selectedEvent?.id == eventId) {
          _selectedEvent = null;
        }

        notifyListeners();
        return true;
      }

      setError('Failed to delete event');
      return false;
    } catch (e) {
      setError('Failed to delete event: $e');
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> registerForEvent(String eventId, String userId) async {
    try {
      final success = await _eventService.registerForEvent(eventId, userId);
      if (success) {
        // Update the event in local lists
        final eventIndex = _events.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final updatedEvent = _events[eventIndex].copyWith(
            registeredUsers: [..._events[eventIndex].registeredUsers, userId],
            currentParticipants: _events[eventIndex].currentParticipants + 1,
          );
          _events[eventIndex] = updatedEvent;
        }

        // Add to registered events if not already there
        final event = await _eventService.getEventById(eventId);
        if (event != null && !_registeredEvents.any((e) => e.id == eventId)) {
          _registeredEvents.insert(0, event);
        }

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      setError('Failed to register for event: $e');
      return false;
    }
  }

  Future<bool> unregisterFromEvent(String eventId, String userId) async {
    try {
      final success = await _eventService.unregisterFromEvent(eventId, userId);
      if (success) {
        // Update the event in local lists
        final eventIndex = _events.indexWhere((e) => e.id == eventId);
        if (eventIndex != -1) {
          final registeredUsers = List<String>.from(_events[eventIndex].registeredUsers);
          registeredUsers.remove(userId);

          final updatedEvent = _events[eventIndex].copyWith(
            registeredUsers: registeredUsers,
            currentParticipants: _events[eventIndex].currentParticipants - 1,
          );
          _events[eventIndex] = updatedEvent;
        }

        // Remove from registered events
        _registeredEvents.removeWhere((e) => e.id == eventId);

        notifyListeners();
        return true;
      }

      return false;
    } catch (e) {
      setError('Failed to unregister from event: $e');
      return false;
    }
  }

  bool isEventRegistered(String eventId, String userId) {
    final event = _events.firstWhere(
          (e) => e.id == eventId,
      orElse: () => _selectedEvent!,
    );
    return event.registeredUsers.contains(userId);
  }

  void refreshEvents() {
    loadEvents();
    loadFeaturedEvents();
  }
}