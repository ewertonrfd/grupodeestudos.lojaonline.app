import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/api/api_client.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final _api = ApiClient().dio;
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get('/products');
      if (response.statusCode == 200) {
        final rawData = response.data;
        final List<dynamic> dataList = rawData is List ? rawData : (rawData['data'] ?? []);
        _products = dataList.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching products: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // Lojista only
  Future<bool> createProduct(Product product) async {
    try {
      final response = await _api.post('/products', data: {
        'nome': product.nome,
        'descricao': product.descricao,
        'preco': product.preco,
        'estoque': product.estoque,
      });
      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchProducts();
        return true;
      }
    } catch (e) {
      debugPrint("Error creating product: $e");
    }
    return false;
  }

  // Lojista only
  Future<bool> updateProduct(int id, {
    required String nome,
    required String descricao,
    required double preco,
    required int estoque,
  }) async {
    try {
      final response = await _api.put('/products/$id', data: {
        'nome': nome,
        'descricao': descricao,
        'preco': preco,
        'estoque': estoque,
      });
      if (response.statusCode == 200) {
        await fetchProducts();
        return true;
      }
    } catch (e) {
      debugPrint("Error updating product: $e");
    }
    return false;
  }

  // Lojista only
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await _api.delete('/products/$id');
      if (response.statusCode == 200 || response.statusCode == 204) {
        _products.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Error deleting product: $e");
    }
    return false;
  }
}
