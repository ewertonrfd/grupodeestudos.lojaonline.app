import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../models/user.dart';
import 'package:dio/dio.dart';

class AuthProvider extends ChangeNotifier {
  final _api = ApiClient().dio;
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isLojista => _currentUser?.isLojista ?? false;

  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    
    if (token != null) {
      final userJsonString = prefs.getString('current_user');
      if (userJsonString != null) {
        _currentUser = User.fromJson(jsonDecode(userJsonString));
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['access_token'];
        
        final userData = data['user'] ?? data;
        _currentUser = User.fromJson(userData);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint("Login error: ${e.response?.data}");
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.post('/users', data: {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint("Register error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> updateProfile({String? name, String? password}) async {
    if (_currentUser == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (name != null && name.isNotEmpty) data['name'] = name;
      if (password != null && password.isNotEmpty) data['password'] = password;

      final response = await _api.put('/users/${_currentUser!.id}', data: data);

      if (response.statusCode == 200) {
        final userData = response.data;
        _currentUser = User.fromJson(userData);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('current_user', jsonEncode(_currentUser!.toJson()));
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on DioException catch (e) {
      debugPrint("Update profile error: ${e.response?.data}");
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout');
    } catch (e) {
      // Ignore if logout fails
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('current_user');
    _currentUser = null;
    notifyListeners();
  }
}
