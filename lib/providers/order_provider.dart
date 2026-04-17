import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final _api = ApiClient().dio;
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/orders');
      if (response.statusCode == 200) {
        final rawData = response.data;
        final List<dynamic> dataList = rawData is List ? rawData : (rawData['data'] ?? []);
        _orders = dataList.map((json) => Order.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching orders: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createOrder(List<Map<String, dynamic>> items) async {
    try {
      final response = await _api.post('/orders', data: {
        'items': items,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchOrders();
        return true;
      }
    } catch (e) {
      debugPrint("Error creating order: $e");
    }
    return false;
  }
}
