import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../core/constants/app_constants.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    setLoading(true);

    // Check if user is already signed in
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        final userData = await _userService.getUserById(currentUser.uid);
        if (userData != null) {
          _user = userData;
          _isAuthenticated = true;
        }
      } catch (e) {
        print('Error initializing auth: $e');
        await signOut();
      }
    }

    setLoading(false);
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      setLoading(true);
      setError(null);

      final userCredential = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userData = await _userService.getUserById(userCredential.user!.uid);
        if (userData != null) {
          _user = userData;
          _isAuthenticated = true;
          await _saveUserSession();
          setLoading(false);
          return true;
        }
      }

      setError('User data not found');
      setLoading(false);
      return false;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
    String? college,
    String role = AppConstants.studentRole,
  }) async {
    try {
      setLoading(true);
      setError(null);

      final userCredential = await _authService.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          name: name,
          role: role,
          department: department,
          college: college,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _userService.createUser(newUser);
        _user = newUser;
        _isAuthenticated = true;
        await _saveUserSession();
        setLoading(false);
        return true;
      }

      setError('Failed to create user');
      setLoading(false);
      return false;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      setLoading(true);
      setError(null);

      final userCredential = await _authService.signInWithGoogle();

      if (userCredential.user != null) {
        // Check if user exists in our database
        UserModel? userData = await _userService.getUserById(userCredential.user!.uid);

        if (userData == null) {
          // Create new user profile for Google sign-in
          final newUser = UserModel(
            id: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            name: userCredential.user!.displayName ?? '',
            profileImage: userCredential.user!.photoURL,
            role: AppConstants.studentRole,
            department: '', // User will need to set this
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await _userService.createUser(newUser);
          userData = newUser;
        }

        _user = userData;
        _isAuthenticated = true;
        await _saveUserSession();
        setLoading(false);
        return true;
      }

      setError('Google sign-in failed');
      setLoading(false);
      return false;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      setLoading(true);
      setError(null);

      await _authService.sendPasswordResetEmail(email);
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      await _clearUserSession();
      _user = null;
      _isAuthenticated = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      setError(e.toString());
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      setLoading(true);
      setError(null);

      await _userService.updateUser(updatedUser);
      _user = updatedUser;
      await _saveUserSession();
      setLoading(false);
      return true;
    } catch (e) {
      setError(e.toString());
      setLoading(false);
      return false;
    }
  }

  Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userIdKey, _user?.id ?? '');
    await prefs.setString(AppConstants.userEmailKey, _user?.email ?? '');
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userIdKey);
    await prefs.remove(AppConstants.userEmailKey);
    await prefs.remove(AppConstants.userTokenKey);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}